import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/components/custom_appBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _messages = [];
  Map<String, List<Map<String, dynamic>>> _replies = {};
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<QuerySnapshot>? _repliesSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    // Set up real-time listener for messages
    _messagesSubscription = _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (messagesSnapshot) {
            setState(() {
              _messages =
                  messagesSnapshot.docs.map((doc) {
                    final data = doc.data();
                    return {
                      'id': doc.id,
                      ...data,
                      'timestamp': data['timestamp']?.toDate(),
                    };
                  }).toList();
              _isLoading = false;
            });
          },
          onError: (e) {
            setState(() {
              _error = 'Failed to load messages: ${e.toString()}';
              _isLoading = false;
            });
          },
        );

    // Set up real-time listener for replies
    _repliesSubscription = _firestore
        .collection('message_replies')
        .snapshots()
        .listen((repliesSnapshot) {
          final repliesMap = <String, List<Map<String, dynamic>>>{};
          for (var replyDoc in repliesSnapshot.docs) {
            final replyData = replyDoc.data();
            final messageId = replyData['messageId'] as String?;
            if (messageId != null) {
              repliesMap.putIfAbsent(messageId, () => []).add({
                'id': replyDoc.id,
                ...replyData,
                'timestamp': replyData['timestamp']?.toDate(),
              });
            }
          }
          setState(() {
            _replies = repliesMap;
          });
        });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesSubscription?.cancel();
    _repliesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send messages')),
      );
      return;
    }

    try {
      // Get user name from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('admins').doc(user.uid).get();

      if (!userDoc.exists) {
        userDoc = await _firestore.collection('users').doc(user.uid).get();
      }

      final userName = userDoc.exists ? userDoc['name'] ?? 'Admin' : 'Admin';

      await _firestore.collection('messages').add({
        'senderId': user.uid,
        'senderName': userName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Message'),
            content: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_messageController.text.isNotEmpty) {
                    Navigator.pop(context);
                    await _sendMessage(_messageController.text);
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Messages",
        leftIcon: Icons.arrow_back_ios,
        onLeftIconPressed: () => context.go('/home'),
        backgroundColor: const Color(0xFFF7F7F9),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMessageDialog,
        child: const Icon(Icons.message_sharp, color: Colors.white),
        backgroundColor: Colors.blue,
        tooltip: 'New Message',
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _messages.isEmpty
              ? const Center(child: Text('No messages found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final messageReplies = _replies[message['id']] ?? [];
                  final timestamp =
                      message['timestamp'] != null
                          ? DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(message['timestamp'] as DateTime)
                          : 'Unknown date';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                message['senderName'] ?? 'Unknown sender',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                timestamp,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(message['message'] ?? 'No message content'),
                          const SizedBox(height: 16),
                          if (messageReplies.isNotEmpty) ...[
                            const Divider(),
                            const Text(
                              'Replies:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...messageReplies.map((reply) {
                              final replyTimestamp =
                                  reply['timestamp'] != null
                                      ? DateFormat(
                                        'MMM dd, yyyy - hh:mm a',
                                      ).format(reply['timestamp'] as DateTime)
                                      : '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Admin:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(reply['reply'] ?? ''),
                                        Spacer(),
                                        Text(
                                          replyTimestamp,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

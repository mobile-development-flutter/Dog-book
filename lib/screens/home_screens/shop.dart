import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/components/custom_appBar.dart';
import 'package:dog_book/components/custom_shop_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Shops extends StatefulWidget {
  const Shops({super.key});

  @override
  State<Shops> createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  List<Map<String, dynamic>> shopItems = [];
  StreamSubscription<QuerySnapshot>? _shopSubscription;

  @override
  void initState() {
    super.initState();
    _setupShopListener();
  }

  @override
  void dispose() {
    _shopSubscription
        ?.cancel(); // Cancel the subscription when widget is disposed
    super.dispose();
  }

  void _setupShopListener() {
    _shopSubscription = FirebaseFirestore.instance
        .collection('shops')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (mounted) {
              // Check if widget is still mounted
              setState(() {
                shopItems =
                    snapshot.docs.map((doc) {
                      return {
                        'id': doc.id,
                        'name': doc['name'],
                        'type': doc['type'],
                        'price': doc['price'],
                        // Add any other fields you need
                      };
                    }).toList();
              });
            }
          },
          onError: (error) {
            // Handle any errors that might occur
            debugPrint("Error listening to shops: $error");
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Items for Sale",
        leftIcon: Icons.arrow_back_ios,
        onLeftIconPressed: () => context.go('/home'),
        backgroundColor: const Color(0xFFF7F7F9),
      ),
      body:
          shopItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: shopItems.length,
                itemBuilder: (context, index) {
                  return CustomShopCard(
                    shopItem: shopItems[index],
                    onCartUpdate: (item, qty) {
                      // Handle cart logic
                    },
                    onBuyNow: (item, qty) {
                      // Handle buy now logic
                    },
                    onAddToCart: (Map<String, dynamic> item, int quantity) {},
                  );
                },
              ),
    );
  }
}

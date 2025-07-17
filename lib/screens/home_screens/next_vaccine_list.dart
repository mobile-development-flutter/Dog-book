// screens/home_screens/next_vaccine_list.dart
import 'package:dog_book/model/next_vaccine.dart';
import 'package:dog_book/screens/home_screens/next_vaccine.dart';
import 'package:dog_book/services/notification_services.dart';
import 'package:dog_book/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PetsListScreen extends StatefulWidget {
  final bool isNotificationEnabled;

  const PetsListScreen({super.key, required this.isNotificationEnabled});

  @override
  State<PetsListScreen> createState() => _PetsListScreenState();
}

class _PetsListScreenState extends State<PetsListScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  List<NextVaccine> _NextVaccine = [];
  bool _isLoading = true;
  bool _isNotificationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _isNotificationPermissionGranted = widget.isNotificationEnabled;
    _loadPets();

    if (!_isNotificationPermissionGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionDialog();
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notification Permission Required'),
            content: const Text(
              'This app needs notification permission to remind you about your pet\'s vaccination dates. '
              'Would you like to enable notifications?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Not Now'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Try requesting permission
                  final status = await Permission.notification.request();
                  setState(() {
                    _isNotificationPermissionGranted = status.isGranted;
                  });

                  // If still not granted after request, open settings
                  if (!status.isGranted && status.isPermanentlyDenied) {
                    await openAppSettings();

                    // Check if permission granted after returning from settings
                    final newStatus = await Permission.notification.status;
                    setState(() {
                      _isNotificationPermissionGranted = newStatus.isGranted;
                    });
                  }
                },
                child: const Text('Enable'),
              ),
            ],
          ),
    );
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    final pets = await _storageService.getPets();

    setState(() {
      _NextVaccine = pets;
      _isLoading = false;
    });
  }

  Future<void> _deletePet(NextVaccine pet) async {
    // Delete pet from storage
    await _storageService.deletePet(pet.id);

    // Cancel notification
    await _notificationService.cancelNotification(
      int.parse(pet.id.substring(pet.id.length - 9)),
    );

    // Reload pets
    await _loadPets();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${pet.name} deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => context.go('/profile'), // Navigate to home using GoRouter
        ),
        title: const Text('Pet Vaccination Reminder'),
        actions: [
          IconButton(
            icon: Icon(
              _isNotificationPermissionGranted
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color:
                  _isNotificationPermissionGranted ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              if (_isNotificationPermissionGranted) {
                await _notificationService.showTestNotification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification sent')),
                  );
                }
              } else {
                _showPermissionDialog();
              }
            },
            tooltip:
                _isNotificationPermissionGranted
                    ? 'Test Notification'
                    : 'Notification Permission Required',
          ),
        ],
      ),
      body: Column(
        children: [
          // Notification permission status bar
          if (!_isNotificationPermissionGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Notifications are disabled. Reminders will not work.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await openAppSettings();

                      // Check permission after returning from settings
                      final status = await Permission.notification.status;
                      setState(() {
                        _isNotificationPermissionGranted = status.isGranted;
                      });
                    },
                    child: const Text('ENABLE'),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _NextVaccine.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "No pet's next vaccinations added yet",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => NextVaccineScreen(
                                        isNotificationEnabled:
                                            _isNotificationPermissionGranted,
                                      ),
                                ),
                              );
                              if (result == true) {
                                _loadPets();
                              }
                            },
                            child: const Text(
                              'Add Next Vaccination for your pet',
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _NextVaccine.length,
                      itemBuilder: (context, index) {
                        final pet = _NextVaccine[index];
                        return Dismissible(
                          key: Key(pet.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _deletePet(pet);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                pet.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Age: ${pet.age}'),
                                  Row(
                                    children: [
                                      Text(
                                        'Vaccine Date: ${DateFormat('MMM dd, yyyy').format(pet.vaccineDate)}',
                                        style: TextStyle(
                                          color:
                                              pet.vaccineDate.isBefore(
                                                    DateTime.now().subtract(
                                                      const Duration(days: 1),
                                                    ),
                                                  )
                                                  ? Colors.red
                                                  : (isToday(pet.vaccineDate)
                                                      ? Colors.orange
                                                      : Colors.green),
                                        ),
                                      ),
                                      if (isToday(pet.vaccineDate))
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'TODAY',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Show notification status for today's vaccines
                                  if (isToday(pet.vaccineDate) &&
                                      !_isNotificationPermissionGranted)
                                    const Text(
                                      '⚠️ Notification disabled',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deletePet(pet),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => NextVaccineScreen(
                    isNotificationEnabled: _isNotificationPermissionGranted,
                  ),
            ),
          );
          if (result == true) {
            _loadPets();

            // Refresh notification permission status
            final status = await Permission.notification.status;
            setState(() {
              _isNotificationPermissionGranted = status.isGranted;
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper function to check if a date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

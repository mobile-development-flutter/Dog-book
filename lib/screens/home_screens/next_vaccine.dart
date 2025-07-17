// screens/home_screens/next_vaccine.dart
import 'package:dog_book/model/next_vaccine.dart';
import 'package:dog_book/services/notification_services.dart';
import 'package:dog_book/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NextVaccineScreen extends StatefulWidget {
  final bool isNotificationEnabled;

  const NextVaccineScreen({super.key, required this.isNotificationEnabled});

  @override
  State<NextVaccineScreen> createState() => _NextVaccineScreenState();
}

class _NextVaccineScreenState extends State<NextVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  DateTime? _selectedDate;
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();
  bool _isNotificationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _isNotificationPermissionGranted = widget.isNotificationEnabled;

    // Check permission status if initially not granted
    if (!_isNotificationPermissionGranted) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final isGranted =
        await _notificationService.isNotificationPermissionGranted();
    setState(() {
      _isNotificationPermissionGranted = isGranted;
    });

    if (!isGranted) {
      // Show permission dialog with slight delay
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
              'Please enable notifications in the app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings();

                  // Check if permission was granted after returning from settings
                  await _checkPermission();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _savePet() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      // Generate a unique ID based on timestamp
      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new pet
      final NextVaccine nextVaccine = NextVaccine(
        id: id,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        vaccineDate: _selectedDate!,
      );

      // Save pet to storage
      await _storageService.addPet(nextVaccine);

      // Schedule notification if permission is granted
      if (_isNotificationPermissionGranted) {
        await _notificationService.scheduleVaccinationReminder(
          int.parse(
            id.substring(id.length - 9),
          ), // Use part of the ID as notification ID
          nextVaccine.name,
          nextVaccine.vaccineDate,
        );
      } else {
        // Permission is not granted, show dialog
        if (mounted) {
          _showPermissionDialog();
        }
      }

      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isNotificationPermissionGranted
                  ? 'Pet added successfully with reminder'
                  : 'Pet added successfully (no reminder - permission denied)',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => context.go('/home'), // Navigate to home using GoRouter
        ),
        title: const Text('Enter Next vaccine date'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      // Changed to allow current day and future dates
                      minTime: DateTime.now(), // Changed from adding 1 day
                      maxTime: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      onConfirm: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      currentTime: DateTime.now(),
                      locale: LocaleType.en,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Select Vaccination Date'
                              : 'Vaccination Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                          style: TextStyle(
                            color:
                                _selectedDate == null
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _savePet,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                // Permission status indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _isNotificationPermissionGranted
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isNotificationPermissionGranted
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            _isNotificationPermissionGranted
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isNotificationPermissionGranted
                              ? 'Notification permission granted'
                              : 'Notification permission denied - reminders will not work',
                          style: TextStyle(
                            color:
                                _isNotificationPermissionGranted
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                          ),
                        ),
                      ),
                      if (!_isNotificationPermissionGranted)
                        TextButton(
                          onPressed: () async {
                            await openAppSettings();
                            await _checkPermission();
                          },
                          child: const Text('Enable'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Test button for notifications
                // ElevatedButton(
                //   onPressed: () async {
                //     if (_isNotificationPermissionGranted) {
                //       await _notificationService.showTestNotification();
                //       if (mounted) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //               content: Text('Test notification sent')),
                //         );
                //       }
                //     } else {
                //       _showPermissionDialog();
                //     }
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.orange,
                //   ),
                //   child: const Padding(
                //     padding: EdgeInsets.symmetric(vertical: 12),
                //     child: Text('Test Notification',
                //         style: TextStyle(fontSize: 16)),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

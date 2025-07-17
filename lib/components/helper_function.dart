// components/helper_function.dart
import 'package:flutter/material.dart';


void displayMessagToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}

import 'package:flutter/material.dart';

class User extends StatelessWidget {
  final String user;
  final String rssi;

  const User({super.key, required this.user, required this.rssi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$user ($rssi)', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ),
        ),
      ],
    );
  }
}
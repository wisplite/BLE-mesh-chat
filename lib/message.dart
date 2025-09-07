import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final String sender;
  final bool isMe;

  const Message({super.key, required this.message, required this.sender, required this.isMe});

  
  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Container(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message, style: TextStyle(color: Colors.black)),
          ),
        ),
      );
    } else {
      if (sender == 'server') {
        return Container(
          alignment: Alignment.center,
          child: Text(message, style: TextStyle(color: Colors.white)),
        );
      }
      return Container(        
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$sender: $message', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
  }
}
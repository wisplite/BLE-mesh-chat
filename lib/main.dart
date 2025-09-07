import 'package:flutter/material.dart';
import 'package:ble_mesh_chat/message.dart';
import 'package:ble_mesh_chat/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesh Chat Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      home: MyHomePage(title: 'Mesh Chat Demo Home Page', messages: [], connectedUsers: []),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.messages, required this.connectedUsers});

  final String title;
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> connectedUsers;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket _socket;
  late List<Map<String, dynamic>> _messages;
  late List<Map<String, dynamic>> _connectedUsers;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(widget.messages);
    _connectedUsers = List<Map<String, dynamic>>.from(widget.connectedUsers);

    _socket = IO.io('http://127.0.0.1:8000', IO.OptionBuilder().setTransports(['websocket']).build());
    _socket.on('connect', (_) {

    });
    _socket.on('disconnect', (_) {
      _appendMessage('disconnected from server', 'server', false);
    });
    _socket.on('message', (data) {
      // Handle payloads that may arrive as a raw JSON string, a Map, or a List of args
      final dynamic payload = (data is List && data.isNotEmpty) ? data[0] : data;

      Map<String, dynamic>? messageMap;
      if (payload is String && payload.isNotEmpty) {
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            messageMap = decoded;
          }
        } catch (_) {}
      } else if (payload is Map) {
        messageMap = Map<String, dynamic>.from(payload);
      }

      if (messageMap != null) {
        _appendMessage(messageMap['message'] ?? '', messageMap['sender'] ?? '', messageMap['isMe'] ?? false);
      }
    });
  }

  @override
  void dispose() {
    try {
      _socket.dispose();
    } catch (_) {}
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _appendMessage(text, 'Me', true);
    });
    _messageController.clear();
    _socket.emit('send_message', jsonEncode({'message': text}));
  }

  void _appendMessage(String message, String sender, bool isMe) {
    setState(() {
      _messages.add({'message': message, 'sender': sender, 'isMe': isMe});
    });
  }

  void addOrUpdateUser(String user, String rssi) {
    setState(() {
      final int existingIndex = _connectedUsers.indexWhere((u) => u['user'] == user);
      if (existingIndex >= 0) {
        _connectedUsers[existingIndex] = {'user': user, 'rssi': rssi};
      } else {
        _connectedUsers.add({'user': user, 'rssi': rssi});
      }
    });
  }

  void removeUser(String user) {
    setState(() {
      _connectedUsers.removeWhere((u) => u['user'] == user);
    });
  }

  void receiveMessage(String message, String sender) {
    setState(() {
      _messages.add({'message': message, 'sender': sender, 'isMe': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Message(message: _messages[index]['message'] ?? '', sender: _messages[index]['sender'] ?? '', isMe: _messages[index]['isMe'] ?? true),
                            SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(hintText: 'Message', hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            onSubmitted: (value) {
                              _sendMessage();
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(onPressed: _sendMessage, icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
              ),
            ),
          ),
          Container(
            width: 280,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [                
                Expanded(
                  child: ListView.builder(
                    itemCount: _connectedUsers.length,
                    itemBuilder: (context, index) {
                      return User(user: _connectedUsers[index]['user'] ?? '', rssi: _connectedUsers[index]['rssi'] ?? '');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

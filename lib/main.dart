import 'package:flutter/material.dart';
import 'package:ble_mesh_chat/message.dart';
import 'package:ble_mesh_chat/user.dart';

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
      home: const MyHomePage(title: 'Mesh Chat Demo Home Page', messages: [{'message': 'Hello, world!', 'sender': 'John Doe', 'isMe': true}, {'message': 'Hello, world!', 'sender': 'Jane Doe', 'isMe': false}], connectedUsers: [{'user': 'John Doe', 'rssi': '100%'}, {'user': 'Jane Doe', 'rssi': '90%'}]),
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
  late List<Map<String, dynamic>> _messages;
  late List<Map<String, dynamic>> _connectedUsers;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(widget.messages);
    _connectedUsers = List<Map<String, dynamic>>.from(widget.connectedUsers);
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'message': text, 'sender': 'Me', 'isMe': true});
    });
    _messageController.clear();
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

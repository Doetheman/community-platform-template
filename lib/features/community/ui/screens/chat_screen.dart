import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String title;
  const ChatScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Chat UI goes here')),
    );
  }
}

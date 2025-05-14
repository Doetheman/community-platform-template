import 'package:flutter/material.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start New Chat')),
      body: const Center(child: Text('New chat UI goes here')),
    );
  }
}

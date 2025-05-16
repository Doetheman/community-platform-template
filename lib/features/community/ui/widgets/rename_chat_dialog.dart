import 'package:flutter/material.dart';

class RenameChatDialog extends StatefulWidget {
  final String currentName;
  final String title;
  final String? hintText;
  final String? labelText;

  const RenameChatDialog({
    super.key,
    required this.currentName,
    this.title = 'Rename Chat',
    this.hintText = 'Enter new name',
    this.labelText = 'Chat Name',
  });

  @override
  State<RenameChatDialog> createState() => _RenameChatDialogState();
}

class _RenameChatDialogState extends State<RenameChatDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Rename')),
      ],
    );
  }

  void _submit() {
    final newName = _controller.text.trim();
    if (newName.isNotEmpty) {
      Navigator.pop(context, newName);
    }
  }
}

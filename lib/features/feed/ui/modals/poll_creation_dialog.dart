import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/poll.dart';
import '../polls_screen.dart';

class PollCreationDialog extends ConsumerStatefulWidget {
  final String? spaceId;

  const PollCreationDialog({super.key, this.spaceId});

  @override
  ConsumerState<PollCreationDialog> createState() => _PollCreationDialogState();

  static Future<bool?> show(BuildContext context, {String? spaceId}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PollCreationDialog(spaceId: spaceId),
    );
  }
}

class _PollCreationDialogState extends ConsumerState<PollCreationDialog> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isMultipleChoice = false;
  final List<int> _expireOptions = [1, 3, 7, 14];
  int _selectedExpireDays = 7;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Poll'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'Ask something...',
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              const Text('Options:'),
              for (var i = 0; i < _optionControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _optionControllers[i],
                    decoration: InputDecoration(
                      labelText: 'Option ${i + 1}',
                      hintText: i < 2 ? 'Required' : 'Optional',
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Poll Type:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<bool>(
                      isExpanded: true,
                      value: _isMultipleChoice,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('Single Choice'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Multiple Choice'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _isMultipleChoice = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Expires in:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedExpireDays,
                      items:
                          _expireOptions.map((days) {
                            return DropdownMenuItem(
                              value: days,
                              child: Text(
                                '$days ${days == 1 ? 'day' : 'days'}',
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedExpireDays = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _createPoll, child: const Text('Create Poll')),
      ],
    );
  }

  void _createPoll() {
    final question = _questionController.text.trim();
    final options =
        _optionControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    // Validate inputs
    if (question.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a question')));
      return;
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 2 options')),
      );
      return;
    }

    // Create poll options
    final pollOptions =
        options.asMap().entries.map((entry) {
          return PollOption(
            id: entry.key.toString(),
            text: entry.value,
            voterIds: [],
          );
        }).toList();

    // Create poll
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final poll = Poll(
      id: const Uuid().v4(),
      authorId: userId,
      question: question,
      options: pollOptions,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: _selectedExpireDays)),
      isMultipleChoice: _isMultipleChoice,
      spaceId: widget.spaceId,
    );

    // Add poll to the provider
    ref.read(pollsProvider.notifier).createPoll(poll);

    // Close dialog
    Navigator.pop(context, true);
  }
}

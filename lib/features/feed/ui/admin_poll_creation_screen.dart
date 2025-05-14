import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/poll.dart';
import '../ui/polls_screen.dart';

class AdminPollCreationScreen extends ConsumerStatefulWidget {
  final String? spaceId;
  final String? spaceName;

  const AdminPollCreationScreen({super.key, this.spaceId, this.spaceName});

  @override
  ConsumerState<AdminPollCreationScreen> createState() =>
      _AdminPollCreationScreenState();
}

class _AdminPollCreationScreenState
    extends ConsumerState<AdminPollCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool _isMultipleChoice = false;
  int _selectedExpireDays = 7;
  bool _isSubmitting = false;

  final List<int> _expirationOptions = [1, 3, 7, 14, 30];

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A poll must have at least 2 options')),
      );
      return;
    }

    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final question = _questionController.text.trim();
      final options =
          _optionControllers
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();

      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least 2 options')),
        );
        setState(() {
          _isSubmitting = false;
        });
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

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating poll: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.spaceName != null
              ? 'Create Poll in ${widget.spaceName}'
              : 'Create Poll',
        ),
        actions: [
          _isSubmitting
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
              : TextButton.icon(
                onPressed: _createPoll,
                icon: const Icon(Icons.check),
                label: const Text('Create'),
              ),
        ],
      ),
      body:
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Poll question section
                    _buildQuestionSection(),

                    const SizedBox(height: 24),

                    // Poll options section
                    _buildOptionsSection(),

                    const SizedBox(height: 24),

                    // Poll settings section
                    _buildSettingsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildQuestionSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Question',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                hintText: 'Ask your question here...',
                filled: true,
                border: OutlineInputBorder(),
              ),
              maxLength: 150,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Poll Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            for (int i = 0; i < _optionControllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[i],
                        decoration: InputDecoration(
                          hintText:
                              i < 2 ? 'Required option' : 'Optional option',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator:
                            i < 2
                                ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                }
                                : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeOption(i),
                      tooltip: 'Remove option',
                    ),
                  ],
                ),
              ),

            // Add button
            Center(
              child: OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Poll Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Poll type
            Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 12),
                const Text('Selection type:'),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Single choice'),
                        icon: Icon(Icons.radio_button_checked),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Multiple choice'),
                        icon: Icon(Icons.check_box),
                      ),
                    ],
                    selected: {_isMultipleChoice},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _isMultipleChoice = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Poll expiration
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 12),
                const Text('Poll expires after:'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedExpireDays,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _expirationOptions.map((days) {
                          return DropdownMenuItem(
                            value: days,
                            child: Text('$days ${days == 1 ? 'day' : 'days'}'),
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

            if (widget.spaceName != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 20),
                  const SizedBox(width: 12),
                  const Text('Created in space:'),
                  const SizedBox(width: 16),
                  Chip(
                    label: Text(widget.spaceName!),
                    avatar: const Icon(Icons.group),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

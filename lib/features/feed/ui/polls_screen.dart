import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/poll.dart';
import 'widgets/poll_card.dart';

// Sample polls provider for demo purposes
final pollsProvider = StateNotifierProvider<PollsNotifier, List<Poll>>((ref) {
  return PollsNotifier();
});

class PollsNotifier extends StateNotifier<List<Poll>> {
  PollsNotifier() : super(_generateSamplePolls());

  static List<Poll> _generateSamplePolls() {
    return [
      Poll(
        id: '1',
        authorId: 'admin',
        question:
            'What feature would you most like to see added to our platform?',
        options: [
          PollOption(
            id: '1',
            text: 'Group video chat',
            voterIds: ['user1', 'user2', 'user3'],
          ),
          PollOption(
            id: '2',
            text: 'Integration with other platforms',
            voterIds: ['user4', 'user5'],
          ),
          PollOption(
            id: '3',
            text: 'Advanced search functionality',
            voterIds: ['user6', 'user7', 'user8', 'user9'],
          ),
          PollOption(
            id: '4',
            text: 'Enhanced privacy controls',
            voterIds: ['user10'],
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
      Poll(
        id: '2',
        authorId: 'techguru',
        question: 'How often do you attend community events?',
        options: [
          PollOption(id: '1', text: 'Weekly', voterIds: ['user1']),
          PollOption(id: '2', text: 'Monthly', voterIds: ['user2', 'user3']),
          PollOption(id: '3', text: 'Quarterly', voterIds: ['user4']),
          PollOption(id: '4', text: 'Rarely or never', voterIds: []),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Poll(
        id: '3',
        authorId: 'admin',
        question: 'Which content type do you prefer?',
        options: [
          PollOption(
            id: '1',
            text: 'Short videos',
            voterIds: ['user1', 'user2'],
          ),
          PollOption(id: '2', text: 'Long-form articles', voterIds: ['user3']),
          PollOption(
            id: '3',
            text: 'Audio/podcasts',
            voterIds: ['user4', 'user5'],
          ),
          PollOption(id: '4', text: 'Interactive content', voterIds: ['user6']),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
        isMultipleChoice: true,
      ),
    ];
  }

  void vote(String pollId, String optionId) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? const Uuid().v4();

    state =
        state.map((poll) {
          if (poll.id == pollId) {
            // For single choice polls, remove user from all other options first
            if (!poll.isMultipleChoice) {
              final updatedOptions =
                  poll.options.map((option) {
                    return PollOption(
                      id: option.id,
                      text: option.text,
                      voterIds:
                          option.voterIds
                              .where((id) => id != currentUserId)
                              .toList(),
                    );
                  }).toList();

              // Update the selected option with the user's vote
              return Poll(
                id: poll.id,
                authorId: poll.authorId,
                question: poll.question,
                options:
                    updatedOptions.map((option) {
                      if (option.id == optionId) {
                        return PollOption(
                          id: option.id,
                          text: option.text,
                          voterIds: [...option.voterIds, currentUserId],
                        );
                      }
                      return option;
                    }).toList(),
                createdAt: poll.createdAt,
                expiresAt: poll.expiresAt,
                isMultipleChoice: poll.isMultipleChoice,
                spaceId: poll.spaceId,
              );
            } else {
              // For multiple choice, toggle vote for the specific option
              return Poll(
                id: poll.id,
                authorId: poll.authorId,
                question: poll.question,
                options:
                    poll.options.map((option) {
                      if (option.id == optionId) {
                        final hasVoted = option.voterIds.contains(
                          currentUserId,
                        );
                        return PollOption(
                          id: option.id,
                          text: option.text,
                          voterIds:
                              hasVoted
                                  ? option.voterIds
                                      .where((id) => id != currentUserId)
                                      .toList()
                                  : [...option.voterIds, currentUserId],
                        );
                      }
                      return option;
                    }).toList(),
                createdAt: poll.createdAt,
                expiresAt: poll.expiresAt,
                isMultipleChoice: poll.isMultipleChoice,
                spaceId: poll.spaceId,
              );
            }
          }
          return poll;
        }).toList();
  }

  void createPoll(Poll poll) {
    state = [poll, ...state];
  }

  void deletePoll(String pollId) {
    state = state.where((poll) => poll.id != pollId).toList();
  }
}

class PollsScreen extends ConsumerWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polls = ref.watch(pollsProvider);

    return Scaffold(
      body:
          polls.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.poll_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No polls yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a poll to gather community feedback',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showCreatePollDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Poll'),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                children: [
                  for (final poll in polls)
                    PollCard(
                      poll: poll,
                      onVote:
                          (poll, optionId) => ref
                              .read(pollsProvider.notifier)
                              .vote(poll.id, optionId),
                    ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePollDialog(context, ref),
        tooltip: 'Create Poll',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePollDialog(BuildContext context, WidgetRef ref) {
    final questionController = TextEditingController();
    final optionControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    var isMultipleChoice = false;
    final expireOptions = [1, 3, 7, 14];
    var selectedExpireDays = 7;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Create Poll'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: questionController,
                        decoration: const InputDecoration(
                          labelText: 'Question',
                          hintText: 'Ask something...',
                        ),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),

                      const Text('Options:'),
                      for (var i = 0; i < optionControllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField(
                            controller: optionControllers[i],
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
                              value: isMultipleChoice,
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
                                    isMultipleChoice = value;
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
                              value: selectedExpireDays,
                              items:
                                  expireOptions.map((days) {
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
                                    selectedExpireDays = value;
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
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final question = questionController.text.trim();
                      final options =
                          optionControllers
                              .map((c) => c.text.trim())
                              .where((text) => text.isNotEmpty)
                              .toList();

                      // Validate inputs
                      if (question.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a question'),
                          ),
                        );
                        return;
                      }

                      if (options.length < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter at least 2 options'),
                          ),
                        );
                        return;
                      }

                      // Create poll
                      final pollOptions =
                          options.asMap().entries.map((entry) {
                            return PollOption(
                              id: entry.key.toString(),
                              text: entry.value,
                              voterIds: [],
                            );
                          }).toList();

                      final poll = Poll(
                        id: const Uuid().v4(),
                        authorId:
                            FirebaseAuth.instance.currentUser?.uid ??
                            'anonymous',
                        question: question,
                        options: pollOptions,
                        createdAt: DateTime.now(),
                        expiresAt: DateTime.now().add(
                          Duration(days: selectedExpireDays),
                        ),
                        isMultipleChoice: isMultipleChoice,
                      );

                      // Add poll to the list
                      ref.read(pollsProvider.notifier).createPoll(poll);

                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Poll created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Create Poll'),
                  ),
                ],
              );
            },
          ),
    );
  }
}

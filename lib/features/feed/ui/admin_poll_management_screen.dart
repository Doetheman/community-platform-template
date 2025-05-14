import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/poll.dart';
import 'polls_screen.dart';
import 'widgets/poll_card.dart';
import 'admin_poll_creation_screen.dart';

class AdminPollManagementScreen extends ConsumerStatefulWidget {
  const AdminPollManagementScreen({super.key});

  @override
  ConsumerState<AdminPollManagementScreen> createState() =>
      _AdminPollManagementScreenState();
}

class _AdminPollManagementScreenState
    extends ConsumerState<AdminPollManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final polls = ref.watch(pollsProvider);
    final activePolls =
        polls.where((poll) => poll.expiresAt.isAfter(DateTime.now())).toList();
    final expiredPolls =
        polls.where((poll) => !poll.expiresAt.isAfter(DateTime.now())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Polls'),
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create New Poll',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPollCreationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  // All Polls Tab
                  _buildPollList(polls),

                  // Active Polls Tab
                  _buildPollList(activePolls),

                  // Expired Polls Tab
                  _buildPollList(expiredPolls),
                ],
              ),
    );
  }

  Widget _buildPollList(List<Poll> polls) {
    if (polls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.poll_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No polls found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: polls.length,
      itemBuilder: (context, index) {
        final poll = polls[index];
        return Dismissible(
          key: Key(poll.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Poll'),
                    content: const Text(
                      'Are you sure you want to delete this poll?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (direction) {
            // Remove the poll using the provider
            ref.read(pollsProvider.notifier).deletePoll(poll.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Poll deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Re-add the poll - for a real app, we would need to store the poll
                    // and re-add it here
                  },
                ),
              ),
            );
          },
          child: Stack(
            children: [
              PollCard(
                poll: poll,
                onVote: (poll, optionId) {
                  ref.read(pollsProvider.notifier).vote(poll.id, optionId);
                },
              ),
              Positioned(
                top: 8,
                right: 24,
                child: Row(
                  children: [
                    // Poll analytics button
                    IconButton(
                      icon: const Icon(Icons.analytics, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () => _showPollAnalytics(poll),
                    ),
                    const SizedBox(width: 8),
                    // Edit poll button
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      onPressed: () => _editPoll(poll),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPollAnalytics(Poll poll) {
    // Calculate total votes
    final totalVotes = poll.options.fold<int>(
      0,
      (sum, option) => sum + option.voteCount,
    );

    // Get the option with the most votes
    PollOption? topOption;
    if (poll.options.isNotEmpty) {
      topOption = poll.options.reduce(
        (a, b) => a.voteCount > b.voteCount ? a : b,
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Poll Analytics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                poll.question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Total votes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.how_to_vote, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Votes'),
                          Text(
                            '$totalVotes',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Most popular option
              if (topOption != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Most Popular Option'),
                        const SizedBox(height: 8),
                        Text(
                          topOption.text,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${topOption.voteCount} votes',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                            totalVotes > 0
                                ? Text(
                                  '(${(topOption.voteCount / totalVotes * 100).round()}%)',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // All options breakdown
              const Text(
                'Vote Distribution',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              for (var option in poll.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(option.text)),
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            if (totalVotes > 0)
                              Container(
                                height: 20,
                                width: (option.voteCount / totalVotes) * 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child:
                            totalVotes > 0
                                ? Text(
                                  '${(option.voteCount / totalVotes * 100).round()}%',
                                  textAlign: TextAlign.right,
                                )
                                : const Text('0%', textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Close button
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPoll(Poll poll) {
    // This would typically navigate to an edit screen or show a dialog
    // For simplicity, we'll show a dialog mentioning that this feature
    // would be implemented in a full version
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Poll'),
            content: const Text(
              'In a complete implementation, this would allow you to edit the poll question, options, and settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

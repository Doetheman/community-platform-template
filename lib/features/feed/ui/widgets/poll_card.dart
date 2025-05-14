import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/poll.dart';

class PollCard extends ConsumerStatefulWidget {
  final Poll poll;
  final Function(Poll, String optionId)? onVote;

  const PollCard({super.key, required this.poll, this.onVote});

  @override
  ConsumerState<PollCard> createState() => _PollCardState();
}

class _PollCardState extends ConsumerState<PollCard> {
  List<String> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeUserVotes();
  }

  void _initializeUserVotes() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _selectedOptions =
          widget.poll.options
              .where((option) => option.voterIds.contains(currentUserId))
              .map((option) => option.id)
              .toList();
    }
  }

  bool get _hasVoted => _selectedOptions.isNotEmpty;
  bool get _canVote => widget.poll.expiresAt.isAfter(DateTime.now());

  void _handleVote(String optionId) {
    // For multiple choice polls, toggle selection
    if (widget.poll.isMultipleChoice) {
      setState(() {
        if (_selectedOptions.contains(optionId)) {
          _selectedOptions.remove(optionId);
        } else {
          _selectedOptions.add(optionId);
        }
      });
    } else {
      // For single choice polls, replace selection
      setState(() {
        _selectedOptions = [optionId];
      });
    }

    if (widget.onVote != null) {
      widget.onVote!(widget.poll, optionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final expiringSoon =
        widget.poll.expiresAt.difference(DateTime.now()).inDays < 1;

    // Calculate total votes
    final totalVotes = widget.poll.options.fold<int>(
      0,
      (sum, option) => sum + option.voteCount,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.poll, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Poll',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (expiringSoon && _canVote)
                  Chip(
                    label: const Text('Ending Soon'),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.orange),
                  )
                else if (!_canVote)
                  Chip(
                    label: const Text('Closed'),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          // Poll question
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.poll.question,
              style: theme.textTheme.titleLarge,
            ),
          ),

          // Poll options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var option in widget.poll.options)
                  _buildPollOption(
                    context,
                    option,
                    totalVotes,
                    _selectedOptions.contains(option.id),
                  ),
              ],
            ),
          ),

          // Poll footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('$totalVotes votes', style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  'Expires: ${dateFormat.format(widget.poll.expiresAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: expiringSoon ? Colors.orange : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(
    BuildContext context,
    PollOption option,
    int totalVotes,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final percentage =
        totalVotes > 0 ? (option.voteCount / totalVotes * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _canVote ? () => _handleVote(option.id) : null,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: _canVote ? 1.0 : 0.7,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Option text and checkbox
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      _buildSelectionIndicator(isSelected),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                if (_hasVoted || !_canVote)
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      Container(
                        height: 8,
                        width:
                            percentage *
                            MediaQuery.of(context).size.width /
                            100,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary.withOpacity(
                                    0.5,
                                  ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return widget.poll.isMultipleChoice
        ? Checkbox(
          value: isSelected,
          onChanged:
              _canVote
                  ? (value) => _handleVote(
                    widget
                        .poll
                        .options[widget.poll.options.indexWhere(
                          (o) => isSelected,
                        )]
                        .id,
                  )
                  : null,
        )
        : Radio<bool>(
          value: true,
          groupValue: isSelected ? true : null,
          onChanged: _canVote ? (value) => {} : null,
        );
  }
}

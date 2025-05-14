import 'package:flutter/material.dart';

class EventCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const EventCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryChip(context, 'All'),
          _buildCategoryChip(context, 'Workshops'),
          _buildCategoryChip(context, 'Social'),
          _buildCategoryChip(context, 'Music'),
          _buildCategoryChip(context, 'Food'),
          _buildCategoryChip(context, 'Fitness'),
          _buildCategoryChip(context, 'Business'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    final isSelected = selectedCategory == category;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onCategorySelected(category);
          } else if (isSelected) {
            // If deselecting the current filter, go back to 'All'
            onCategorySelected('All');
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
      ),
    );
  }

  // Helper method to get icon for each category
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Workshops':
        return Icons.school;
      case 'Social':
        return Icons.people;
      case 'Music':
        return Icons.music_note;
      case 'Food':
        return Icons.restaurant;
      case 'Fitness':
        return Icons.fitness_center;
      case 'Business':
        return Icons.business;
      case 'All':
      default:
        return Icons.event;
    }
  }
}

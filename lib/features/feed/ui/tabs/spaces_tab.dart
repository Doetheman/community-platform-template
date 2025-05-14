import 'package:flutter/material.dart';
import '../widgets/space_card.dart';
import '../space_view_screen.dart';

class SpacesTab extends StatelessWidget {
  final List<Map<String, dynamic>> spaces;

  const SpacesTab({super.key, required this.spaces});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        return SpaceCard(
          space: space,
          onTap: (space) => _navigateToSpaceView(context, space),
        );
      },
    );
  }

  void _navigateToSpaceView(BuildContext context, Map<String, dynamic> space) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SpaceViewScreen(space: space)),
    );
  }
}

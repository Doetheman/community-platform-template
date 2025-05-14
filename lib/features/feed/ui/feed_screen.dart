import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/feed_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:white_label_community_app/features/auth/state/user_role_provider.dart';
import 'create_post_screen.dart';
import 'admin_poll_creation_screen.dart';
import 'admin_poll_management_screen.dart';
import 'tabs/feed_tab.dart';
import 'tabs/spaces_tab.dart';
import 'tabs/polls_tab.dart';
import 'tabs/qa_tab.dart';
import 'modals/create_options_sheet.dart';
import 'modals/poll_creation_dialog.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSpace;
  final List<Map<String, dynamic>> _dummySpaces = [
    {
      'name': 'General',
      'description': 'The main community space for general discussions',
      'creator': 'Admin',
      'members': 345,
      'color': Colors.blue,
    },
    {
      'name': 'Tech Talk',
      'description': 'Discussions about technology, coding, and digital trends',
      'creator': 'TechGuru',
      'members': 182,
      'color': Colors.purple,
    },
    {
      'name': 'Creative Corner',
      'description': 'Share your art, writing, music, and creative projects',
      'creator': 'ArtistInResidence',
      'members': 97,
      'color': Colors.orange,
    },
    {
      'name': 'Events Discussion',
      'description': 'Talk about upcoming and past community events',
      'creator': 'EventPlanner',
      'members': 156,
      'color': Colors.green,
    },
    {
      'name': 'Support Group',
      'description': 'A safe space for support and encouragement',
      'creator': 'Counselor',
      'members': 78,
      'color': Colors.pink,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedStreamProvider);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userRoleAsync = ref.watch(userRoleByUidProvider(user?.uid ?? ''));

    // Default to user role until the actual role loads
    final isAdmin = userRoleAsync.value == 'admin';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: const Text('Community'),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                // Admin tools popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin Tools',
                  onSelected: (value) {
                    if (value == 'manage_polls') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const AdminPollManagementScreen(),
                        ),
                      );
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'manage_polls',
                          child: Row(
                            children: [
                              Icon(Icons.poll),
                              SizedBox(width: 8),
                              Text('Manage Polls'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Feed'),
                  Tab(text: 'Spaces'),
                  Tab(text: 'Polls'),
                  Tab(text: 'Q&A'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Feed tab
            const FeedTab(),

            // Spaces tab
            SpacesTab(spaces: _dummySpaces),

            // Polls tab
            const PollsTab(),

            // Q&A tab
            const QATab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptionsBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateOptionsBottomSheet() {
    CreateOptionsBottomSheet.show(
      context,
      onCreatePost: _navigateToCreatePost,
      onCreatePoll: _showPollCreationDialog,
      onCreateAdminPoll: _navigateToAdminPollCreation,
    );
  }

  void _navigateToCreatePost(String type) {
    // Find the space details if a space is selected
    Map<String, dynamic>? spaceDetails;
    if (_selectedSpace != null) {
      spaceDetails = _dummySpaces.firstWhere(
        (space) => space['name'] == _selectedSpace,
        orElse: () => <String, dynamic>{},
      );
    }

    // Navigate to the create post screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CreatePostScreen(
              mediaType: type,
              space: _selectedSpace,
              spaceDetails: spaceDetails,
            ),
      ),
    );
  }

  void _showPollCreationDialog() {
    PollCreationDialog.show(context, spaceId: _selectedSpace).then((created) {
      // If poll was created successfully, show success message and switch to polls tab
      if (created == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _tabController.animateTo(2); // Switch to Polls tab
      }
    });
  }

  void _navigateToAdminPollCreation() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminPollCreationScreen()),
    );
  }
}

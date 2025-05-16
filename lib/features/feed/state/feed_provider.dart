import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/core/helper/parser_utils.dart';
import 'package:white_label_community_app/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:white_label_community_app/features/feed/data/repositories_impl/feed_repository_impl.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/domain/entities/comment.dart';
import 'package:white_label_community_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/create_post.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/delete_post.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/get_feed.dart';
import 'feed_controller.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart'
    as profile;

/// Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Data source
final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FeedRemoteDataSource(firestore);
});

/// Repository
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final remote = ref.watch(feedRemoteDataSourceProvider);
  return FeedRepositoryImpl(remote);
});

final getFeedProvider = Provider<GetFeed>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  return GetFeed(repo);
});

final createPostProvider = Provider<CreatePost>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  return CreatePost(repo);
});

final deletePostProvider = Provider<DeletePost>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  return DeletePost(repo);
});

/// Stream of posts (real-time updates)
final feedStreamProvider = StreamProvider<List<FeedPost>>((ref) {
  final getFeed = ref.watch(getFeedProvider);
  final bannedWords = ['scam', 'spam', 'hate'];
  return getFeed().map((posts) {
    return posts
        .where((post) => !containsBannedWords(post.content, bannedWords))
        .toList();
  });
});

/// Controller for posting/deleting
final feedControllerProvider =
    NotifierProvider<FeedController, AsyncValue<List<FeedPost>>>(
      FeedController.new,
    );

final commentsProvider = StreamProvider.family<List<Comment>, String>((
  ref,
  postId,
) {
  return ref.watch(feedRepositoryProvider).getComments(postId);
});

// Provider for sharing posts
final sharePostProvider = Provider.family<Future<void>, FeedPost>((
  ref,
  post,
) async {
  final authorProfile = await ref.read(
    profile.userProfileByUidProvider(post.authorId).future,
  );
  final authorName = authorProfile?.name ?? 'Unknown User';
  final date = DateFormat.yMMMd().add_jm().format(post.createdAt);

  // Build the share text
  final shareText = StringBuffer();
  shareText.writeln('Check out this post by $authorName');
  shareText.writeln();
  shareText.writeln(post.content);
  shareText.writeln();
  shareText.writeln('Posted on $date');

  // Add media URL if available
  if (post.mediaUrl != null) {
    shareText.writeln();
    shareText.writeln('Media: ${post.mediaUrl}');
  }

  // Add tags if available
  if (post.tags.isNotEmpty) {
    shareText.writeln();
    shareText.writeln('Tags: ${post.tags.map((tag) => '#$tag').join(' ')}');
  }

  try {
    await SharePlus.instance.share(
      ShareParams(text: shareText.toString(), subject: 'Post by $authorName'),
    );
  } catch (e) {
    throw Exception('Failed to share post: $e');
  }
});

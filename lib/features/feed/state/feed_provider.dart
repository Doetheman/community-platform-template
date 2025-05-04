import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/core/helper/parser_utils.dart';
import 'package:white_label_community_app/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:white_label_community_app/features/feed/data/repositories_impl/feed_repository_impl.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/create_post.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/delete_post.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/get_feed.dart';
import 'feed_controller.dart';

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

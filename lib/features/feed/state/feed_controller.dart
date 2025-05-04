import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/create_post.dart';
import 'package:white_label_community_app/features/feed/domain/usecases/delete_post.dart';
import 'package:white_label_community_app/features/feed/state/feed_provider.dart';

class FeedController extends Notifier<AsyncValue<List<FeedPost>>> {
  late final CreatePost _createPost;
  late final DeletePost _deletePost;

  @override
  AsyncValue<List<FeedPost>> build() {
    _createPost = ref.read(createPostProvider);
    _deletePost = ref.read(deletePostProvider);
    // This controller itself doesn't manage the stream; it's just for side effects
    return const AsyncValue.data([]);
  }

  Future<void> addPost(FeedPost post) async {
    try {
      await _createPost(post);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removePost(String postId) async {
    try {
      await _deletePost(postId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool containsBannedWords(String message, List<String> bannedWords) {
    final pattern = RegExp(
      '\\b(${bannedWords.join('|')})\\b',
      caseSensitive: false,
    );
    return pattern.hasMatch(message);
  }
}

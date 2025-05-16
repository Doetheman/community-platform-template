import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/domain/entities/comment.dart';

abstract class FeedRepository {
  Stream<List<FeedPost>> getFeed();
  Future<void> createPost(FeedPost post);
  Future<void> deletePost(String id);
  Future<void> toggleLike(String postId, String userId);
  Future<void> toggleReaction(String postId, String userId, String emoji);

  // Comment methods
  Stream<List<Comment>> getComments(String postId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
  Future<void> toggleCommentLike(
    String postId,
    String commentId,
    String userId,
  );
}

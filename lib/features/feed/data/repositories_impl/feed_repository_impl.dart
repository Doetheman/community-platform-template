import 'package:white_label_community_app/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:white_label_community_app/features/feed/data/models/comment_model.dart';
import 'package:white_label_community_app/features/feed/data/models/feed_post_model.dart';
import 'package:white_label_community_app/features/feed/domain/entities/comment.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<FeedPost>> getFeed() {
    return remoteDataSource.getFeed().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<void> createPost(FeedPost post) {
    final model = FeedPostModel.fromEntity(post);
    return remoteDataSource.createPost(model);
  }

  @override
  Future<void> deletePost(String postId) {
    return remoteDataSource.deletePost(postId);
  }

  @override
  Future<void> toggleLike(String postId, String userId) {
    return remoteDataSource.toggleLike(postId, userId);
  }

  @override
  Future<void> toggleReaction(String postId, String userId, String emoji) {
    return remoteDataSource.toggleReaction(postId, userId, emoji);
  }

  @override
  Future<void> deleteComment(String postId, String commentId) {
    return remoteDataSource.deleteComment(postId, commentId);
  }

  @override
  Future<void> toggleCommentLike(
    String postId,
    String commentId,
    String userId,
  ) {
    return remoteDataSource.toggleCommentLike(postId, commentId, userId);
  }

  @override
  Stream<List<Comment>> getComments(String postId) {
    return remoteDataSource
        .getComments(postId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> addComment(String postId, Comment comment) {
    final model = CommentModel.fromEntity(comment);
    return remoteDataSource.addComment(postId, model);
  }
}

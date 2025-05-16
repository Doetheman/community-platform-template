import 'package:white_label_community_app/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:white_label_community_app/features/feed/data/models/feed_post_model.dart';
import 'package:white_label_community_app/features/feed/data/models/comment_model.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/domain/entities/comment.dart';
import 'package:white_label_community_app/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<FeedPost>> getFeed() {
    return remoteDataSource.getFeed().map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> createPost(FeedPost post) async {
    await remoteDataSource.createPost(FeedPostModel.fromEntity(post));
  }

  @override
  Future<void> deletePost(String id) async {
    await remoteDataSource.deletePost(id);
  }

  @override
  Future<void> toggleLike(String postId, String userId) async {
    await remoteDataSource.toggleLike(postId, userId);
  }

  @override
  Future<void> toggleReaction(
    String postId,
    String userId,
    String emoji,
  ) async {
    await remoteDataSource.toggleReaction(postId, userId, emoji);
  }

  @override
  Stream<List<Comment>> getComments(String postId) {
    return remoteDataSource.getComments(postId).map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    await remoteDataSource.addComment(postId, CommentModel.fromEntity(comment));
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await remoteDataSource.deleteComment(postId, commentId);
  }

  @override
  Future<void> toggleCommentLike(
    String postId,
    String commentId,
    String userId,
  ) async {
    await remoteDataSource.toggleCommentLike(postId, commentId, userId);
  }
}

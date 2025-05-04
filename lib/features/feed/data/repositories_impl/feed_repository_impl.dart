import 'package:white_label_community_app/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:white_label_community_app/features/feed/data/models/feed_post_model.dart';
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
}

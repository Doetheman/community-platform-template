import '../entities/feed_post.dart';

abstract class FeedRepository {
  Stream<List<FeedPost>> getFeed();
  Future<void> createPost(FeedPost post);
  Future<void> deletePost(String postId);
}

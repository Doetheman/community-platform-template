import '../entities/feed_post.dart';
import '../repositories/feed_repository.dart';

class CreatePost {
  final FeedRepository repository;

  CreatePost(this.repository);

  Future<void> call(FeedPost post) {
    return repository.createPost(post);
  }
}

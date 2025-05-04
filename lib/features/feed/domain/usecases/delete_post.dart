import '../repositories/feed_repository.dart';

class DeletePost {
  final FeedRepository repository;

  DeletePost(this.repository);

  Future<void> call(String postId) {
    return repository.deletePost(postId);
  }
}

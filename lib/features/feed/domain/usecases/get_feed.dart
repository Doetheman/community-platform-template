import '../entities/feed_post.dart';
import '../repositories/feed_repository.dart';

class GetFeed {
  final FeedRepository repository;

  GetFeed(this.repository);

  Stream<List<FeedPost>> call() {
    return repository.getFeed();
  }
}

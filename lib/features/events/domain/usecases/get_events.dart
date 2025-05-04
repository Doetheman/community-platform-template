import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEvents {
  final EventRepository repository;

  GetEvents(this.repository);

  Future<List<Event>> call() async {
    try {
      return await repository.getEvents();
    } catch (e) {
      rethrow;
    }
  }
}

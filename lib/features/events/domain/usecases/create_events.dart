import '../entities/event.dart';
import '../repositories/event_repository.dart';

class CreateEvents {
  final EventRepository repository;

  CreateEvents(this.repository);

  Future<void> call(Event event) async {
    try {
      await repository.createEvent(event);
    } catch (e) {
      rethrow;
    }
  }
}

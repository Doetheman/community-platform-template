import '../repositories/event_repository.dart';

class DeleteEvents {
  final EventRepository repository;

  DeleteEvents(this.repository);

  Future<void> call(String eventId) async {
    try {
      await repository.deleteEvent(eventId);
    } catch (e) {
      rethrow;
    }
  }
}

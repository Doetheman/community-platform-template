import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<void> createEvent(Event event);
  Future<void> deleteEvent(String eventId);
}

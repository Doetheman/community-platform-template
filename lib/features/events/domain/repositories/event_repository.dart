import 'package:white_label_community_app/features/events/data/models/rsvp/rsvp_model.dart';

import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<void> createEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<void> updateEvent(Event event);
  Future<void> rsvpToEvent(String eventId, RSVPModel model);
  Future<void> deleteRSVP(String eventId, String uid);
  Future<List<RSVPModel>> getRSVPs(String eventId);
  Future<RSVPModel?> getUserRSVP(String eventId, String uid);
  Future<void> updateRSVP(String eventId, RSVPModel model);
}

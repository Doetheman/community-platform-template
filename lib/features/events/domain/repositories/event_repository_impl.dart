import 'package:white_label_community_app/features/events/data/event_remote_data_source.dart';
import 'package:white_label_community_app/features/events/data/models/event/event_model.dart';
import 'package:white_label_community_app/features/events/data/models/rsvp/rsvp_model.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Event>> getEvents() async {
    final models = await remoteDataSource.fetchEvents();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createEvent(Event event) async {
    final model = EventModel.fromEntity(event);
    await remoteDataSource.createEvent(model);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await remoteDataSource.deleteEvent(eventId);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final model = EventModel.fromEntity(event);
    await remoteDataSource.updateEvent(model);
  }

  @override
  Future<void> rsvpToEvent(String eventId, RSVPModel model) async {
    await remoteDataSource.rsvpToEvent(eventId, model);
  }

  @override
  Future<void> deleteRSVP(String eventId, String uid) async {
    await remoteDataSource.deleteRSVP(eventId, uid);
  }

  @override
  Future<List<RSVPModel>> getRSVPs(String eventId) async {
    return await remoteDataSource.getRSVPs(eventId);
  }

  @override
  Future<RSVPModel?> getUserRSVP(String eventId, String uid) async {
    return await remoteDataSource.getUserRSVP(eventId, uid);
  }

  @override
  Future<void> updateRSVP(String eventId, RSVPModel model) async {
    await remoteDataSource.updateRSVP(eventId, model);
  }
}

import 'package:white_label_community_app/features/events/data/event_model.dart';
import 'package:white_label_community_app/features/events/data/event_remote_data_source.dart';
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
}

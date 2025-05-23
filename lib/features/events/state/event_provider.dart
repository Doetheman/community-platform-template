import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/events/data/event_remote_data_source.dart';
import 'package:white_label_community_app/features/events/data/models/rsvp/rsvp_model.dart';
import 'package:white_label_community_app/features/events/domain/repositories/event_repository_impl.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/domain/repositories/event_repository.dart';
import 'package:white_label_community_app/features/events/domain/usecases/create_events.dart';
import 'package:white_label_community_app/features/events/domain/usecases/delete_events.dart';
import 'package:white_label_community_app/features/events/domain/usecases/get_events.dart';
import 'package:white_label_community_app/features/events/state/rsvp_controller.dart';
import 'event_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data Source
final eventRemoteDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return EventRemoteDataSource(firestore);
});

// Repository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final remote = ref.watch(eventRemoteDataSourceProvider);
  return EventRepositoryImpl(remote);
});

final eventByIdProvider = FutureProvider.family<Event, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEventById(eventId);
});


// Use Cases
final getEventsProvider = Provider<GetEvents>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return GetEvents(repo);
});

final createEventProvider = Provider<CreateEvents>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return CreateEvents(repo);
});

final deleteEventProvider = Provider<DeleteEvents>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return DeleteEvents(repo);
});

final eventPageLoaderProvider = StateProvider<bool>((ref) {
  return false;
});

// Controller
final eventControllerProvider =
    AsyncNotifierProvider<EventController, List<Event>>(EventController.new);

// RSVP Controllers
final rsvpControllerProvider =
    StateNotifierProvider.family<RSVPController, RSVPModel?, String>((
      ref,
      eventId,
    ) {
      return RSVPController(
        eventRemoteDataSource: ref.read(eventRemoteDataSourceProvider),
        eventId: eventId,
      );
    });

final rsvpCountsProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((ref, eventId) async {
      return ref.read(eventRemoteDataSourceProvider).getRSVPCounts(eventId);
    });

final rsvpListProvider = FutureProvider.family<List<RSVPModel>, String>((
  ref,
  eventId,
) async {
  return ref.read(eventRemoteDataSourceProvider).getRSVPs(eventId);
});

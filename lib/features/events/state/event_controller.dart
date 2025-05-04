import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/domain/usecases/create_events.dart';
import 'package:white_label_community_app/features/events/domain/usecases/delete_events.dart';
import 'package:white_label_community_app/features/events/domain/usecases/get_events.dart';
import 'package:white_label_community_app/features/events/state/event_provider.dart';


class EventController extends AsyncNotifier<List<Event>> {
  late final GetEvents _getEvents;
  late final CreateEvents _createEvent;
  late final DeleteEvents _deleteEvent;

  @override
  FutureOr<List<Event>> build() async {
    _getEvents = ref.read(getEventsProvider);
    _createEvent = ref.read(createEventProvider);
    _deleteEvent = ref.read(deleteEventProvider);
    return _getEvents();
  }

  Future<void> refreshEvents() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getEvents());
  }

  Future<void> addEvent(Event event) async {
    await _createEvent(event);
    await refreshEvents();
  }

  Future<void> removeEvent(String eventId) async {
    await _deleteEvent(eventId);
    await refreshEvents();
  }
}

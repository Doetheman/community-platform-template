import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/events/data/event_remote_data_source.dart';
import 'package:white_label_community_app/features/events/data/models/rsvp/rsvp_model.dart';

class RSVPController extends StateNotifier<RSVPModel?> {
  final EventRemoteDataSource _eventRemoteDataSource;
  final String eventId;

  RSVPController({
    required EventRemoteDataSource eventRemoteDataSource,
    required this.eventId,
  }) : _eventRemoteDataSource = eventRemoteDataSource,
       super(null) {
    _loadUserRSVP();
  }

  void _loadUserRSVP() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final rsvp = await _eventRemoteDataSource.getUserRSVP(eventId, uid);
    state = rsvp;
  }

  Future<void> submitRSVP(String response) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final model = RSVPModel(
      uid: uid,
      response: response,
      timestamp: DateTime.now(),
    );

    await _eventRemoteDataSource.rsvpToEvent(eventId, model);
    state = model;
  }

  Future<void> deleteRSVP(String eventId, String uid) async {
    await _eventRemoteDataSource.deleteRSVP(eventId, uid);
  }

  Future<List<RSVPModel>> getRSVPs(String eventId) async {
    return await _eventRemoteDataSource.getRSVPs(eventId);
  }

  Future<RSVPModel?> getUserRSVP(String eventId, String uid) async {
    return await _eventRemoteDataSource.getUserRSVP(eventId, uid);
  }

  Future<void> updateRSVP(String eventId, RSVPModel model) async {
    await _eventRemoteDataSource.updateRSVP(eventId, model);
  }
}

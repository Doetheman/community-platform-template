import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/events/data/models/event/event_model.dart';
import 'package:white_label_community_app/features/events/data/models/rsvp/rsvp_model.dart';

class EventRemoteDataSource {
  final FirebaseFirestore firestore;

  EventRemoteDataSource(this.firestore);

  Future<List<EventModel>> fetchEvents() async {
    final snapshot = await firestore.collection('events').get();
    return snapshot.docs
        .map((doc) => EventModel.fromJson(doc.data()).copyWith(id: doc.id))
        .toList();
  }

  Future<void> createEvent(EventModel model) async {
    await firestore.collection('events').add(model.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await firestore.collection('events').doc(id).delete();
  }

  Future<void> updateEvent(EventModel model) async {
    await firestore.collection('events').doc(model.id).update(model.toJson());
  }

  Future<RSVPModel?> getUserRSVP(String eventId, String uid) async {
    final ref = firestore
        .collection('events')
        .doc(eventId)
        .collection('rsvps')
        .doc(uid);

    final doc = await ref.get();
    if (!doc.exists) return null;
    return RSVPModel.fromJson(doc.data()!).copyWith(uid: doc.id);
  }

  Future<void> rsvpToEvent(String eventId, RSVPModel model) async {
    await firestore
        .collection('events')
        .doc(eventId)
        .collection('rsvps')
        .doc(model.uid)
        .set(model.toJson());
  }

  Future<void> deleteRSVP(String eventId, String uid) async {
    await firestore
        .collection('events')
        .doc(eventId)
        .collection('rsvps')
        .doc(uid)
        .delete();
  }

  Future<List<RSVPModel>> getRSVPs(String eventId) async {
    final snapshot =
        await firestore
            .collection('events')
            .doc(eventId)
            .collection('rsvps')
            .where('response', isEqualTo: 'yes')
            .get();
    return snapshot.docs
        .map((doc) => RSVPModel.fromJson(doc.data()).copyWith(uid: doc.id))
        .toList();
  }

  Future<void> updateRSVP(String eventId, RSVPModel model) async {
    await firestore
        .collection('events')
        .doc(eventId)
        .collection('rsvps')
        .doc(model.uid)
        .update(model.toJson());
  }

  Future<Map<String, int>> getRSVPCounts(String eventId) async {
    final snapshot =
        await firestore
            .collection('events')
            .doc(eventId)
            .collection('rsvps')
            .get();

    final counts = {'yes': 0, 'interested': 0, 'no': 0};

    for (var doc in snapshot.docs) {
      final rsvp = RSVPModel.fromJson(doc.data()).copyWith(uid: doc.id);
      if (counts.containsKey(rsvp.response)) {
        counts[rsvp.response] = counts[rsvp.response]! + 1;
      }
    }

    return counts;
  }
}

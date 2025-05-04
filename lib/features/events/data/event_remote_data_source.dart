import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/events/data/event_model.dart';

class EventRemoteDataSource {
  final FirebaseFirestore firestore;

  EventRemoteDataSource(this.firestore);

  Future<List<EventModel>> fetchEvents() async {
    final snapshot = await firestore.collection('events').get();
    return snapshot.docs
        .map((doc) => EventModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> createEvent(EventModel model) async {
    await firestore.collection('events').add(model.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await firestore.collection('events').doc(id).delete();
  }
}

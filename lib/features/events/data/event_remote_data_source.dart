import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/events/data/models/event/event_model.dart';
import 'package:white_label_community_app/features/events/data/models/rsvp/rsvp_model.dart';
import 'package:uuid/uuid.dart';

class EventRemoteDataSource {
  final FirebaseFirestore firestore;

  EventRemoteDataSource(this.firestore);

  Future<List<EventModel>> fetchEvents() async {
    final snapshot = await firestore.collection('events').get();

    // If there are events in Firestore, return them
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()).copyWith(id: doc.id))
          .toList();
    }

    // Otherwise, return sample events
    return _generateSampleEvents();
  }

  List<EventModel> _generateSampleEvents() {
    final uuid = Uuid();
    final now = DateTime.now();

    return [
      EventModel(
        id: uuid.v4(),
        title: 'Community Meetup',
        description:
            'Join us for our monthly community meetup with networking and discussions. This is a great opportunity to meet other community members, share ideas, and learn from each other. We\'ll have refreshments and snacks available throughout the event.\n\nSchedule:\n- 6:00 PM: Networking and welcome drinks\n- 6:30 PM: Community announcements\n- 7:00 PM: Guest speaker presentation\n- 8:00 PM: Open networking and discussions',
        dateTime: now.add(const Duration(days: 2)),
        location: 'Community Center, 123 Main Street',
        hostId: 'admin',
        isPaid: false,
        price: null,
        capacity: 50,
        imageUrl:
            'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=1000',
        category: 'Social',
        galleryImageUrls: [
          'https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=1000',
          'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=1000',
          'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=1000',
        ],
        additionalInfo: {
          'contactEmail': 'community@example.com',
          'contactPhone': '555-123-4567',
          'website': 'https://example.com/meetup',
          'parking': 'Free parking available in the community center lot',
          'accessibility': 'Wheelchair accessible venue',
        },
      ),
      EventModel(
        id: uuid.v4(),
        title: 'Workshop: Mobile App Development',
        description:
            'Learn the fundamentals of building mobile apps with Flutter. This hands-on workshop will cover everything from setup to building your first functional app. Bring your laptop with Flutter development environment already installed.\n\nTopics covered:\n- Flutter basics and Dart language\n- UI components and layouts\n- State management\n- Working with APIs\n- Building and deploying your app',
        dateTime: now.add(const Duration(days: 5)),
        location: 'Tech Hub, 456 Innovation Avenue',
        hostId: 'admin',
        isPaid: true,
        price: 19.99,
        capacity: 20,
        imageUrl:
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=1000',
        category: 'Workshops',
        galleryImageUrls: [
          'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?q=80&w=1000',
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=1000',
        ],
        additionalInfo: {
          'contactEmail': 'workshops@techhub.com',
          'prerequisites':
              'Basic programming knowledge, laptop with Flutter installed',
          'includes':
              'Workshop materials, lunch, and certificate of completion',
          'maxParticipants': 20,
        },
      ),
      EventModel(
        id: uuid.v4(),
        title: 'Networking Breakfast',
        description:
            'Start your day with good food and great connections! Join local professionals for a casual networking breakfast. This is a perfect opportunity to expand your professional network in a relaxed atmosphere.\n\nThe breakfast buffet includes:\n- Fresh pastries and bagels\n- Seasonal fruit selection\n- Yogurt and granola\n- Coffee and tea\n- Fresh juices',
        dateTime: now.add(const Duration(days: 1, hours: 8)),
        location: 'Sunrise Cafe, 789 Sunrise Boulevard',
        hostId: 'admin',
        isPaid: true,
        price: 9.99,
        capacity: 30,
        imageUrl:
            'https://images.unsplash.com/photo-1628191081676-a39b37b4d68e?q=80&w=1000',
        category: 'Business',
        galleryImageUrls: [
          'https://images.unsplash.com/photo-1517705008128-361805f42e86?q=80&w=1000',
          'https://images.unsplash.com/photo-1517705008128-361805f42e86?q=80&w=1000',
        ],
        additionalInfo: {
          'contactEmail': 'events@sunrisecafe.com',
          'contactPhone': '555-987-6543',
          'dresscode': 'Business casual',
          'parking': 'Street parking available',
          'duration': '7:30 AM - 9:00 AM',
        },
      ),
      EventModel(
        id: uuid.v4(),
        title: 'Yoga in the Park',
        description:
            'Outdoor yoga session for all skill levels. Join us for a refreshing yoga session in the beautiful Central Park. This event is suitable for beginners and experienced practitioners alike.\n\nWhat to bring:\n- Yoga mat\n- Water bottle\n- Towel\n- Comfortable clothing\n\nIn case of rain, the event will be rescheduled.',
        dateTime: now.add(const Duration(days: 3, hours: 17)),
        location: 'Central Park, Main Lawn',
        hostId: 'admin',
        isPaid: false,
        price: null,
        capacity: 25,
        imageUrl:
            'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?q=80&w=1000',
        category: 'Fitness',
        galleryImageUrls: [
          'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=1000',
          'https://images.unsplash.com/photo-1599447292461-74c3d5c4503a?q=80&w=1000',
        ],
        additionalInfo: {
          'contactEmail': 'yoga@example.com',
          'instructor': 'Sarah Johnson',
          'experience': 'All levels welcome',
          'duration': '60 minutes',
          'weatherPolicy': 'Event will be rescheduled in case of rain',
        },
      ),
      EventModel(
        id: uuid.v4(),
        title: 'Tech Conference 2023',
        description:
            'Annual tech conference with industry speakers and workshops. Join us for our flagship technology conference featuring renowned speakers, cutting-edge demos, and networking opportunities with industry leaders.\n\nConference tracks:\n- AI and Machine Learning\n- Web Development\n- Mobile Technologies\n- DevOps and Infrastructure\n- Entrepreneurship and Startups\n\nTicket includes full access to all sessions, lunch, and evening networking reception.',
        dateTime: now.add(const Duration(days: 14)),
        location: 'Convention Center, 1000 Tech Boulevard',
        hostId: 'admin',
        isPaid: true,
        price: 49.99,
        capacity: 200,
        imageUrl:
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000',
        category: 'Business',
        galleryImageUrls: [
          'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?q=80&w=1000',
          'https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=1000',
          'https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=1000',
        ],
        additionalInfo: {
          'contactEmail': 'info@techconference2023.com',
          'website': 'https://techconference2023.com',
          'schedule': 'Available on the conference website',
          'speakers': '25+ industry experts and thought leaders',
          'accommodation': 'Special rates available at partner hotels',
        },
      ),
    ];
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

  Future<EventModel> getEventById(String eventId) async {
    final snapshot = await firestore.collection('events').doc(eventId).get();
    return EventModel.fromJson(snapshot.data()!).copyWith(id: eventId);
  }
}

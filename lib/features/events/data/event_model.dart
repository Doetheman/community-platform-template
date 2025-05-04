
import 'package:white_label_community_app/features/events/domain/entities/event.dart';

class EventModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;
  final bool isPaid;

  EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.isPaid,
  });

  factory EventModel.fromEntity(Event event) => EventModel(
        id: event.id,
        title: event.title,
        dateTime: event.dateTime,
        location: event.location,
        description: event.description,
        isPaid: event.isPaid,
      );

  Event toEntity() => Event(
        id: id,
        title: title,
        dateTime: dateTime,
        location: location,
        description: description,
        isPaid: isPaid,
      );

  factory EventModel.fromJson(Map<String, dynamic> json, String id) =>
      EventModel(
        id: id,
        title: json['title'],
        dateTime: DateTime.parse(json['dateTime']),
        location: json['location'],
        description: json['description'],
        isPaid: json['isPaid'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'location': location,
        'description': description,
        'isPaid': isPaid,
      };
}

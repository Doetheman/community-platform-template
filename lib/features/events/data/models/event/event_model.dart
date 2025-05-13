import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class EventModel with _$EventModel {
  const EventModel({
    this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.isPaid,
    this.price,
    required this.hostId,
  });

  @override
  final String? id;
  @override
  final String? title;
  @override
  final DateTime? dateTime;
  @override
  final String? location;
  @override
  final String? description;
  @override
  final bool? isPaid;
  @override
  final double? price;
  @override
  final String? hostId;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  Event toEntity() => Event(
    id: id ?? '',
    title: title ?? '',
    dateTime: dateTime ?? DateTime.now(),
    location: location ?? '',
    description: description ?? '',
    isPaid: isPaid ?? false,
    price: price,
    hostId: hostId ?? '',
  );

  factory EventModel.fromEntity(Event event) => EventModel(
    id: event.id,
    title: event.title,
    dateTime: event.dateTime,
    location: event.location,
    description: event.description,
    isPaid: event.isPaid,
    price: event.price,
    hostId: event.hostId,
  );
}

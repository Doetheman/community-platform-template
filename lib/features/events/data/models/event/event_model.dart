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
    required this.capacity,
    this.imageUrl,
    this.galleryImageUrls,
    this.category,
    this.additionalInfo,
  });

  @override
  final String? id; // Document ID (not stored in Firestore)
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
  @override
  final int? capacity;
  @override
  final String? imageUrl;
  @override
  final List<String>? galleryImageUrls;
  @override
  final String? category;
  @override
  final Map<String, dynamic>? additionalInfo;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$EventModelToJson(this);
    json.remove('id'); // Remove id from json as it's the document ID
    return json;
  }

  Event toEntity() => Event(
    id: id ?? '',
    title: title ?? '',
    dateTime: dateTime ?? DateTime.now(),
    location: location ?? '',
    description: description ?? '',
    isPaid: isPaid ?? false,
    price: price,
    hostId: hostId ?? '',
    capacity: capacity ?? 0,
    imageUrl: imageUrl,
    galleryImageUrls: galleryImageUrls,
    category: category,
    additionalInfo: additionalInfo,
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
    capacity: event.capacity,
    imageUrl: event.imageUrl,
    galleryImageUrls: event.galleryImageUrls,
    category: event.category,
    additionalInfo: event.additionalInfo,
  );
}

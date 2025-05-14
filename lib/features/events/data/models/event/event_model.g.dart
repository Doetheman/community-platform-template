// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: json['id'] as String?,
  title: json['title'] as String?,
  dateTime:
      json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
  location: json['location'] as String?,
  description: json['description'] as String?,
  isPaid: json['isPaid'] as bool?,
  price: (json['price'] as num?)?.toDouble(),
  hostId: json['hostId'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  galleryImageUrls:
      (json['galleryImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  category: json['category'] as String?,
  additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'dateTime': instance.dateTime?.toIso8601String(),
      'location': instance.location,
      'description': instance.description,
      'isPaid': instance.isPaid,
      'price': instance.price,
      'hostId': instance.hostId,
      'capacity': instance.capacity,
      'imageUrl': instance.imageUrl,
      'galleryImageUrls': instance.galleryImageUrls,
      'category': instance.category,
      'additionalInfo': instance.additionalInfo,
    };

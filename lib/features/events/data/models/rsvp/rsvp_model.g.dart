// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsvp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RSVPModel _$RSVPModelFromJson(Map<String, dynamic> json) => RSVPModel(
  uid: json['uid'] as String,
  response: json['response'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  paid: json['paid'] as bool? ?? false,
);

Map<String, dynamic> _$RSVPModelToJson(RSVPModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'response': instance.response,
  'timestamp': instance.timestamp.toIso8601String(),
  'paid': instance.paid,
};

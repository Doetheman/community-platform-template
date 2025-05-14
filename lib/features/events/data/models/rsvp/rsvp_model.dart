import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rsvp_model.freezed.dart';
part 'rsvp_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

@freezed
@JsonSerializable(explicitToJson: true)
class RSVPModel with _$RSVPModel {
  const RSVPModel({
    required this.uid,
    required this.response,
    @TimestampConverter() required this.timestamp,
    this.paid = false,
  });

  @override
  final String uid;
  @override
  final String response;
  @override
  @TimestampConverter()
  final DateTime timestamp;
  @override
  final bool paid;

  factory RSVPModel.fromJson(Map<String, dynamic> json) =>
      _$RSVPModelFromJson(json);

  Map<String, dynamic> toJson() => _$RSVPModelToJson(this);
}

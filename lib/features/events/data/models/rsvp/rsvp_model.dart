import 'package:freezed_annotation/freezed_annotation.dart';

part 'rsvp_model.freezed.dart';
part 'rsvp_model.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class RSVPModel with _$RSVPModel {
  const RSVPModel({
    required this.uid,
    required this.response,
    required this.timestamp,
    this.paid = false,
  });

  @override
  final String uid;
  @override
  final String response;
  @override
  final DateTime timestamp;
  @override
  final bool paid;

  factory RSVPModel.fromJson(Map<String, dynamic> json) =>
      _$RSVPModelFromJson(json);

  Map<String, dynamic> toJson() => _$RSVPModelToJson(this);
}

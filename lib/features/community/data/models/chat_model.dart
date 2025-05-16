import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:white_label_community_app/features/community/domain/entities/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class ChatModel with _$ChatModel {
  const ChatModel({
    this.id,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
    this.isGroup = false,
    this.name,
    this.unreadCounts = const {},
  });

  @override
  final String? id;
  @override
  final List<String> participants;
  @override
  final String? lastMessage;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime? updatedAt;
  @override
  final bool isGroup;
  @override
  final String? name;
  @override
  final Map<String, int> unreadCounts;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatModelToJson(this);

  Chat toEntity() => Chat(
    id: id ?? '',
    participants: participants,
    lastMessage: lastMessage,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isGroup: isGroup,
    name: name,
    unreadCounts: unreadCounts,
  );

  factory ChatModel.fromEntity(Chat chat) => ChatModel(
    id: chat.id,
    participants: chat.participants,
    lastMessage: chat.lastMessage,
    createdAt: chat.createdAt,
    updatedAt: chat.updatedAt,
    isGroup: chat.isGroup,
    name: chat.name,
    unreadCounts: chat.unreadCounts,
  );

  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _dateTimeToTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

enum MessageType { text, video, image }

enum MessageStatus {
  sending, // Message is being sent
  sent, // Message has been sent to the server
  delivered, // Message has been delivered to recipient's device
  read, // Message has been read by recipient
  error, // Message failed to send
}

@freezed
@JsonSerializable(explicitToJson: true)
class ChatMessageModel with _$ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.timestamp,
    required this.type,
    this.text,
    this.videoUrl,
    this.thumbnailUrl,
    this.imageUrl,
    this.status = MessageStatus.sending,
    this.readBy = const {},
    this.deliveredTo = const {},
  });

  @override
  final String id;
  @override
  final String senderId;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime timestamp;
  @override
  final MessageType type;
  @override
  final String? text;
  @override
  final String? videoUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String? imageUrl;
  @override
  @JsonKey(defaultValue: MessageStatus.sending)
  final MessageStatus status;
  @override
  @JsonKey(defaultValue: {})
  final Set<String> readBy; // Set of user IDs who have read the message
  @override
  @JsonKey(defaultValue: {})
  final Set<String> deliveredTo; // Set of user IDs who have received the message

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) json['id'] = '';
    return _$ChatMessageModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    if (data['id'] == null) data['id'] = '';
    return ChatMessageModel.fromJson(data).copyWith(id: doc.id ?? '');
  }

  ChatMessageModel copyWithStatus(MessageStatus newStatus) =>
      copyWith(status: newStatus);

  ChatMessageModel markAsDelivered(String userId) => copyWith(
    deliveredTo: {...deliveredTo, userId},
    status: deliveredTo.length + 1 >= 2 ? MessageStatus.delivered : status,
  );

  ChatMessageModel markAsRead(String userId) => copyWith(
    readBy: {...readBy, userId},
    status: readBy.length + 1 >= 2 ? MessageStatus.read : status,
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

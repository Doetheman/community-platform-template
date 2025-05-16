import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the upload state of a message
class MessageUploadState {
  final String messageId;
  final double progress;
  final bool isUploading;
  final String? error;

  const MessageUploadState({
    required this.messageId,
    this.progress = 0.0,
    this.isUploading = false,
    this.error,
  });

  MessageUploadState copyWith({
    String? messageId,
    double? progress,
    bool? isUploading,
    String? error,
  }) {
    return MessageUploadState(
      messageId: messageId ?? this.messageId,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
    );
  }
}

/// Provider to manage upload states for messages
final messageUploadStateProvider = StateNotifierProvider.family<
  MessageUploadNotifier,
  MessageUploadState?,
  String
>((ref, messageId) => MessageUploadNotifier(messageId));

/// Notifier to handle message upload state changes
class MessageUploadNotifier extends StateNotifier<MessageUploadState?> {
  final String messageId;

  MessageUploadNotifier(this.messageId) : super(null);

  void startUpload() {
    state = MessageUploadState(
      messageId: messageId,
      isUploading: true,
      progress: 0.0,
    );
  }

  void updateProgress(double progress) {
    if (state != null) {
      state = state!.copyWith(progress: progress);
    }
  }

  void completeUpload() {
    if (state != null) {
      state = state!.copyWith(isUploading: false, progress: 1.0);
    }
  }

  void setError(String error) {
    if (state != null) {
      state = state!.copyWith(isUploading: false, error: error);
    }
  }

  void reset() {
    state = null;
  }
}

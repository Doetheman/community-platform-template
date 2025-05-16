import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that provides a text input field with send and video upload buttons
/// for chat messages.
class ChatInputBar extends StatefulWidget {
  /// The controller for the text input field.
  final TextEditingController controller;

  /// Callback when the send button is pressed.
  final VoidCallback onSendMessage;

  /// Callback when the video upload button is pressed.
  final VoidCallback? onSendVideo;

  /// Callback when the image upload button is pressed.
  final VoidCallback? onSendImage;

  /// Callback when the stored video upload button is pressed.
  final VoidCallback? onSendStoredVideo;

  /// Callback when the text input changes.
  final VoidCallback? onTextChanged;

  /// Whether the input bar is enabled.
  final bool enabled;

  /// Whether to show the video upload button.
  final bool showVideoButton;

  /// Whether to show the image upload button.
  final bool showImageButton;

  /// Whether the input bar is in the process of sending a message.
  final bool isSending;

  /// Creates a chat input bar.
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.onSendVideo,
    this.onSendImage,
    this.onSendStoredVideo,
    this.onTextChanged,
    this.enabled = true,
    this.showVideoButton = true,
    this.showImageButton = true,
    this.isSending = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onTextChanged?.call();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      widget.onSendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.showImageButton) ...[
              IconButton(
                onPressed: widget.enabled ? widget.onSendImage : null,
                icon: const Icon(Icons.image),
                color:
                    widget.enabled
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                tooltip: 'Send image',
              ),
              const SizedBox(width: 8),
            ],
            if (widget.showVideoButton) ...[
              PopupMenuButton<String>(
                icon: const Icon(Icons.videocam),
                tooltip: 'Send Video',
                enabled: !widget.isSending,
                onSelected: (value) {
                  switch (value) {
                    case 'record':
                      if (widget.onSendVideo != null) widget.onSendVideo!();
                      break;
                    case 'device':
                      if (widget.onSendVideo != null) widget.onSendVideo!();
                      break;
                    case 'stored':
                      if (widget.onSendStoredVideo != null)
                        widget.onSendStoredVideo!();
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'record',
                        child: ListTile(
                          leading: Icon(Icons.videocam),
                          title: Text('Record Video'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'device',
                        child: ListTile(
                          leading: Icon(Icons.video_library),
                          title: Text('Pick from Device Gallery'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'stored',
                        child: ListTile(
                          leading: Icon(Icons.collections),
                          title: Text('Pick from App Gallery'),
                        ),
                      ),
                    ],
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon:
                      _hasText
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed:
                                widget.enabled
                                    ? () {
                                      widget.controller.clear();
                                      _handleTextChange();
                                    }
                                    : null,
                            tooltip: 'Clear message',
                          )
                          : null,
                ),
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => _handleTextChange(),
                onSubmitted: _handleSubmitted,
                textInputAction: TextInputAction.send,
                inputFormatters: [
                  // Prevent newlines in the text field
                  FilteringTextInputFormatter.deny(RegExp(r'\n')),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  widget.enabled && _hasText ? widget.onSendMessage : null,
              icon: const Icon(Icons.send),
              color:
                  widget.enabled && _hasText
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
              tooltip: 'Send message',
            ),
          ],
        ),
      ),
    );
  }
}

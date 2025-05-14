import 'dart:io';

import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_thumbnail.dart';

/// A reusable form for media uploads with common fields like caption, tags, and visibility.
class MediaUploadForm extends StatefulWidget {
  /// The media file to upload
  final File mediaFile;

  /// The type of media (image or video)
  final MediaType mediaType;

  /// Initial caption value (for editing)
  final String? initialCaption;

  /// Initial tags (for editing)
  final List<String>? initialTags;

  /// Initial visibility setting (for editing)
  final bool initialIsPublic;

  /// Callback when form is submitted
  final void Function({
    required File mediaFile,
    required MediaType mediaType,
    required String caption,
    required List<String> tags,
    required bool isPublic,
  })
  onSubmit;

  /// Label for the submit button
  final String submitButtonLabel;

  /// Callback when form is cancelled
  final VoidCallback? onCancel;

  const MediaUploadForm({
    super.key,
    required this.mediaFile,
    required this.mediaType,
    this.initialCaption,
    this.initialTags,
    this.initialIsPublic = true,
    required this.onSubmit,
    this.submitButtonLabel = 'UPLOAD',
    this.onCancel,
  });

  @override
  State<MediaUploadForm> createState() => _MediaUploadFormState();
}

class _MediaUploadFormState extends State<MediaUploadForm> {
  late final TextEditingController _captionController;
  late final TextEditingController _tagsController;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.initialCaption);
    _tagsController = TextEditingController(
      text:
          widget.initialTags?.isNotEmpty == true
              ? widget.initialTags!.join(', ')
              : '',
    );
    _isPublic = widget.initialIsPublic;
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _handleSubmit() {
    final caption = _captionController.text.trim();
    final tags = _parseTags();

    widget.onSubmit(
      mediaFile: widget.mediaFile,
      mediaType: widget.mediaType,
      caption: caption,
      tags: tags,
      isPublic: _isPublic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MediaThumbnail(
            file: widget.mediaFile,
            type: widget.mediaType,
            height: 200,
            width: double.infinity,
            borderRadius: 8,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              hintText: 'Add a caption...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'Separated by commas (e.g., tag1, tag2)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Public'),
            subtitle: const Text('Allow others to see this media'),
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('CANCEL'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(widget.submitButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

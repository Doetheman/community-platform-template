import 'dart:io';

import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';

/// A reusable widget for displaying media thumbnails consistently across the app.
/// Handles both network images, file images, and video thumbnails with appropriate styling.
class MediaThumbnail extends StatelessWidget {
  /// The URL of the media, used for network images/videos
  final String? url;

  /// Optional local file for the media (for uploads/previews)
  final File? file;

  /// The type of media (image or video)
  final MediaType type;

  /// Optional thumbnail URL for videos
  final String? thumbnailUrl;

  /// Height of the thumbnail
  final double? height;

  /// Width of the thumbnail
  final double? width;

  /// Border radius of the thumbnail
  final double borderRadius;

  /// How the image should be inscribed into the box
  final BoxFit fit;

  /// Whether to show a play icon for videos
  final bool showPlayIcon;

  /// Size of the play icon (if shown)
  final double playIconSize;

  /// Optional onTap callback
  final VoidCallback? onTap;

  const MediaThumbnail({
    super.key,
    this.url,
    this.file,
    required this.type,
    this.thumbnailUrl,
    this.height,
    this.width,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
    this.showPlayIcon = true,
    this.playIconSize = 48.0,
    this.onTap,
  }) : assert(
         url != null || file != null,
         'Either url or file must be provided',
       );

  /// Convenience constructor for creating a thumbnail from a MediaItem
  factory MediaThumbnail.fromMediaItem(
    MediaItem item, {
    double? height,
    double? width,
    double borderRadius = 8.0,
    BoxFit fit = BoxFit.cover,
    bool showPlayIcon = true,
    double playIconSize = 48.0,
    VoidCallback? onTap,
  }) {
    return MediaThumbnail(
      url: item.thumbnailUrl ?? item.url,
      type: item.type,
      height: height,
      width: width,
      borderRadius: borderRadius,
      fit: fit,
      showPlayIcon: showPlayIcon,
      playIconSize: playIconSize,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget mediaWidget = _buildMediaWidget();

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          width: width,
          color: Colors.grey.shade300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              mediaWidget,
              if (type == MediaType.video && showPlayIcon)
                Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: playIconSize,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaWidget() {
    // Use file if available (local preview), otherwise use network image
    if (file != null) {
      return Image.file(
        file!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    // Use network image for remote media
    if (url != null && url!.isNotEmpty) {
      if (type == MediaType.video &&
          thumbnailUrl != null &&
          thumbnailUrl!.isNotEmpty) {
        // Use thumbnail for video if available
        return Image.network(
          thumbnailUrl!,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      }

      // Use the primary URL
      return Image.network(
        url!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    // Fallback placeholder
    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          type == MediaType.image
              ? Icons.image_not_supported
              : Icons.video_library,
          color: Colors.grey.shade400,
          size: 24,
        ),
      ),
    );
  }
}

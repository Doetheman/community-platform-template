import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_thumbnail.dart';

typedef MediaItemBuilder =
    Widget Function(BuildContext context, MediaItem mediaItem, int index);
typedef MediaItemCallback = void Function(MediaItem mediaItem);

/// A reusable grid for displaying media items with consistent styling and interaction
class MediaGrid extends ConsumerWidget {
  /// The list of media items to display
  final List<MediaItem> mediaItems;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Spacing between items horizontally
  final double crossAxisSpacing;

  /// Spacing between items vertically
  final double mainAxisSpacing;

  /// Aspect ratio of each item (width / height)
  final double childAspectRatio;

  /// Padding around the grid
  final EdgeInsetsGeometry padding;

  /// Callback when an item is tapped
  final MediaItemCallback? onTap;

  /// Callback when an item is long pressed
  final MediaItemCallback? onLongPress;

  /// Builder for custom item content
  final MediaItemBuilder? itemBuilder;

  /// Builder for overlay content (like edit/delete buttons)
  final Widget Function(BuildContext, MediaItem, int)? overlayBuilder;

  /// Builder for the empty state when no media items are available
  final Widget Function(BuildContext)? emptyBuilder;

  /// Whether to shrink wrap the grid (useful for embedding in CustomScrollView)
  final bool shrinkWrap;

  /// The scroll physics to use
  final ScrollPhysics? physics;

  /// The scroll controller to use
  final ScrollController? scrollController;

  const MediaGrid({
    super.key,
    required this.mediaItems,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.onLongPress,
    this.itemBuilder,
    this.overlayBuilder,
    this.emptyBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaItems.isEmpty) {
      return emptyBuilder?.call(context) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'No media items found',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    return GridView.builder(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final mediaItem = mediaItems[index];
        return itemBuilder?.call(context, mediaItem, index) ??
            _buildDefaultItem(context, mediaItem, index);
      },
    );
  }

  Widget _buildDefaultItem(
    BuildContext context,
    MediaItem mediaItem,
    int index,
  ) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(mediaItem) : null,
      onLongPress: onLongPress != null ? () => onLongPress!(mediaItem) : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (mediaItem.thumbnailUrl != null || mediaItem.url != null)
              Image.network(
                mediaItem.thumbnailUrl ?? mediaItem.url!,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, size: 40)),
              ),
            if (mediaItem.type == MediaType.video)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            if (overlayBuilder != null)
              overlayBuilder!(context, mediaItem, index),
          ],
        ),
      ),
    );
  }
}

/// A sliver version of the MediaGrid that works in CustomScrollView
class SliverMediaGrid extends ConsumerWidget {
  /// The list of media items to display
  final List<MediaItem> mediaItems;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Spacing between items horizontally
  final double crossAxisSpacing;

  /// Spacing between items vertically
  final double mainAxisSpacing;

  /// Aspect ratio of each item (width / height)
  final double childAspectRatio;

  /// Padding around the grid
  final EdgeInsetsGeometry padding;

  /// Callback when an item is tapped
  final MediaItemCallback? onTap;

  /// Callback when an item is long pressed
  final MediaItemCallback? onLongPress;

  /// Builder for custom item content
  final MediaItemBuilder? itemBuilder;

  /// Builder for overlay content (like edit/delete buttons)
  final Widget Function(BuildContext, MediaItem, int)? overlayBuilder;

  /// Builder for the empty state when no media items are available
  final Widget Function(BuildContext)? emptyBuilder;

  const SliverMediaGrid({
    super.key,
    required this.mediaItems,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.onLongPress,
    this.itemBuilder,
    this.overlayBuilder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaItems.isEmpty) {
      return SliverFillRemaining(
        child:
            emptyBuilder?.call(context) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'No media items found',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      );
    }

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final mediaItem = mediaItems[index];
          return itemBuilder?.call(context, mediaItem, index) ??
              _buildDefaultItem(context, mediaItem, index);
        }, childCount: mediaItems.length),
      ),
    );
  }

  Widget _buildDefaultItem(
    BuildContext context,
    MediaItem mediaItem,
    int index,
  ) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(mediaItem) : null,
      onLongPress: onLongPress != null ? () => onLongPress!(mediaItem) : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (mediaItem.thumbnailUrl != null || mediaItem.url != null)
              Image.network(
                mediaItem.thumbnailUrl ?? mediaItem.url!,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, size: 40)),
              ),
            if (mediaItem.type == MediaType.video)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            if (overlayBuilder != null)
              overlayBuilder!(context, mediaItem, index),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A scrollable list that features smooth, interactive animations based on touch position.
///
/// [SmoothListView] provides a unique scrolling experience where list items react
/// dynamically to the user's interaction point. The animation duration for each
/// item is calculated based on its distance from the current touch position ([_touchPos]),
/// creating a "fluid" or "organic" movement effect.
///
/// This widget uses an optimized [Stack] to render only the items within or near
/// the visible viewport (a simple form of virtualization), ensuring performance
/// stability even with a large [itemCount].
///
/// Key Features:
///  * Supports both [Axis.vertical] and [Axis.horizontal] orientations.
///  * Custom spacing between items via the [spacing] parameter.
///  * Dynamic animation lag controlled by [delayFactor].
///  * Built-in [onTopReached] and [onEndReached] callbacks for seamless infinite
///  scrolling and pagination.
///  * Support pull-to-refresh with callback [onRefresh], allow to custom [refreshThreshold],
///  [refreshIndicator] and [loadingIndicator].
///
/// See also:
///  * [ListView], the standard Flutter scrollable list.
///  * [AnimatedPositioned], the underlying widget used for smooth transitions.
class SmoothListView extends StatefulWidget {
  /// Creates a [SmoothListView].
  const SmoothListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
    this.axis = Axis.vertical,
    this.delayFactor = 2,
    this.spacing = 0,
    this.onEndReached,
    this.onTopReached,
    this.refreshThreshold = 80.0,
    this.onRefresh,
    this.loadingIndicator,
    this.refreshIndicator,
  });

  /// The total number of items in the list.
  final int itemCount;

  /// A function that creates the list items based on their index.
  final Widget Function(BuildContext, int) itemBuilder;

  /// The axis along which the list scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis axis;

  /// The fixed size of each item along the main axis.
  ///
  /// (Height if [axis] is vertical, Width if horizontal).
  final double itemSize;

  /// A multiplier that determines the animation delay based on distance.
  ///
  /// Higher values make items further from the touch point appear "lazier"
  /// or slower to catch up. Default value is `2`.
  final double delayFactor;

  /// The amount of empty space to place between adjacent items.
  final double spacing;

  /// Called when the user scrolls to the end of the list.
  ///
  /// This is triggered once when the scroll offset reaches the maximum extent,
  /// making it ideal for triggering "load more" logic or pagination.
  final VoidCallback? onEndReached;

  /// Called when the user scrolls back to the very top (or start) of the list.
  ///
  /// This is triggered when the scroll offset returns to zero, useful for
  /// refreshing content or hiding specific UI elements.
  final VoidCallback? onTopReached;

  /// Callback triggered when the user performs a pull-to-refresh gesture.
  ///
  /// When provided, the widget will enable pull-to-refresh functionality.
  /// It must return a [Future] to signal when the refreshing process is complete.
  final Future<void> Function()? onRefresh;

  /// The distance threshold that must be dragged to trigger [onRefresh].
  ///
  /// This defines the sensitivity of the pull gesture. If not specified,
  /// a default value based on the platform's standard behavior will be used.
  final double refreshThreshold;

  /// A custom widget displayed while the user is actively pulling down.
  ///
  /// Typically used to show a dynamic icon or text that responds to the drag
  /// distance. If null, a default system indicator will be shown.
  final Widget? refreshIndicator;

  /// A custom widget displayed while the [onRefresh] future is executing.
  ///
  /// This represents the active loading state (e.g., a spinning progress bar).
  /// If null, the widget will fall back to a default loading animation.
  final Widget? loadingIndicator;

  @override
  State<SmoothListView> createState() => _SmoothListViewState();
}

class _SmoothListViewState extends State<SmoothListView> {
  /// The current scroll position of the list.
  double _scrollOffset = 0.0;

  /// The current interaction point (touch or drag) along the main axis.
  double _touchPos = 0.0;

  /// A flag indicating whether the list is currently refreshing.
  bool _isRefreshing = false;

  /// The current displacement of the pull-to-refresh gesture.
  double _pullDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the available viewing area based on the scroll axis.
        final double stackSize = widget.axis == Axis.vertical
            ? constraints.maxHeight
            : constraints.maxWidth;

        return GestureDetector(
          onPanStart: (details) {
            setState(() {
              _touchPos = widget.axis == Axis.vertical
                  ? details.localPosition.dy
                  : details.localPosition.dx;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _touchPos = widget.axis == Axis.vertical
                  ? details.localPosition.dy
                  : details.localPosition.dx;

              final delta = widget.axis == Axis.vertical
                  ? details.delta.dy
                  : details.delta.dx;

              if (_scrollOffset >= 0 && delta > 0) {
                _pullDistance += delta * 0.5;
              } else if (_pullDistance > 0 && delta < 0) {
                _pullDistance += delta;
                if (_pullDistance < 0) _pullDistance = 0;
              } else {
                // Calculate new offset based on user drag delta.
                double newOffset = _scrollOffset + delta;

                // Calculate the total theoretical size of the list content.
                double totalListSize =
                    (widget.itemCount * widget.itemSize) +
                    ((widget.itemCount - 1) * widget.spacing);

                // Clamp the scroll offset to prevent scrolling out of bounds.
                double maxScroll = (totalListSize > stackSize)
                    ? -(totalListSize - stackSize)
                    : 0.0;

                // Trigger edge callbacks only when the boundary is first crossed.
                if (newOffset >= 0 && _scrollOffset < 0) {
                  widget.onTopReached?.call();
                }

                if (newOffset <= maxScroll && _scrollOffset > maxScroll) {
                  widget.onEndReached?.call();
                }

                _scrollOffset = newOffset.clamp(maxScroll, 0.0);
              }
            });
          },
          onPanEnd: (_) async {
            if (_pullDistance > widget.refreshThreshold &&
                widget.onRefresh != null &&
                !_isRefreshing) {
              setState(() {
                _isRefreshing = true;
                _pullDistance = widget.refreshThreshold;
              });

              await widget.onRefresh!();

              if (mounted) {
                setState(() {
                  _isRefreshing = false;
                  _pullDistance = 0;
                });
              }
            } else {
              setState(() => _pullDistance = 0);
            }
          },
          child: Container(
            color: Colors
                .transparent, // Ensure the GestureDetector hits even on empty areas.
            child: Stack(
              children: [
                Positioned.fill(
                  top: widget.axis == Axis.vertical ? _pullDistance : 0,
                  left: widget.axis == Axis.horizontal ? _pullDistance : 0,
                  child: _buildOptimizedStack(stackSize),
                ),
                if (_pullDistance > 0)
                  Positioned(
                    top: widget.axis == Axis.vertical ? 20 : null,
                    left: widget.axis == Axis.vertical ? 0 : 20,
                    right: widget.axis == Axis.vertical ? 0 : null,
                    child: Center(
                      child: _isRefreshing
                          ? widget.loadingIndicator ??
                                const CircularProgressIndicator()
                          : Opacity(
                              opacity: (_pullDistance / widget.refreshThreshold)
                                  .clamp(0, 1),
                              child:
                                  widget.refreshIndicator ??
                                  const Icon(Icons.arrow_downward),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a [Stack] containing only the items currently within the viewport.
  ///
  /// This implements basic virtualization by calculating which indices are
  /// visible based on the current [_scrollOffset] and rendering only those,
  /// plus a small buffer.
  Widget _buildOptimizedStack(double stackSize) {
    // Calculate how many items can fit in the viewport.
    int visibleCount = (stackSize / (widget.itemSize + widget.spacing)).ceil();

    // Determine the index of the first item in the viewport.
    int currentLeadingIndex =
        (-_scrollOffset / (widget.itemSize + widget.spacing)).floor();

    // Define a range (with buffer) to render.
    int startIndex = (currentLeadingIndex - visibleCount).clamp(
      0,
      widget.itemCount,
    );
    int endIndex = (currentLeadingIndex + visibleCount * 2).clamp(
      0,
      widget.itemCount,
    );

    return Stack(
      children: [
        for (int i = startIndex; i < endIndex; i++)
          _buildAnimatedItem(i, stackSize),
      ],
    );
  }

  /// Builds an individual item wrapped in an [AnimatedPositioned] widget.
  ///
  /// [i] is the item index, and [containerSize] is used to normalize the
  /// distance calculation for the animation duration.
  Widget _buildAnimatedItem(int i, double containerHeight) {
    // Target position of the item based on the current scroll offset.
    double target = (i * (widget.itemSize + widget.spacing)) + _scrollOffset;

    // Absolute distance from the item to the user's touch point.
    double distanceToTouch = (target - _touchPos).abs();

    // Normalize distance to a 0.0 - 1.0 range.
    double normalizedDistance = (distanceToTouch / containerHeight).clamp(
      0.0,
      1.0,
    );

    // Calculate duration: items closer to the touch move faster, further move slower.
    final durationValue = 1.0 + (normalizedDistance * widget.delayFactor);

    return AnimatedPositioned(
      key: ValueKey('item_$i'),
      duration: Duration(milliseconds: (200 * durationValue).toInt()),
      curve: Curves.easeOutQuart,
      // Handle positioning logic for both vertical and horizontal axes.
      top: widget.axis == Axis.vertical ? target : 0,
      bottom: widget.axis == Axis.vertical ? null : 0,
      left: widget.axis == Axis.vertical ? 0 : target,
      right: widget.axis == Axis.vertical ? 0 : null,
      height: widget.axis == Axis.vertical
          ? widget.itemSize + (i == 0 ? 0 : widget.spacing)
          : null,
      width: widget.axis == Axis.horizontal
          ? widget.itemSize + (i == 0 ? 0 : widget.spacing)
          : null,
      child: Padding(
        padding: widget.axis == Axis.vertical
            ? EdgeInsets.only(bottom: i == 0 ? 0 : widget.spacing)
            : EdgeInsets.only(right: i == 0 ? 0 : widget.spacing),
        child: widget.itemBuilder(context, i),
      ),
    );
  }
}

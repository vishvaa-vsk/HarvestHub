import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Skeleton loading widgets for better perceived performance
class SkeletonWidgets {
  /// Post card skeleton
  static Widget postCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Avatar Skeleton
          _buildShimmerCircle(radius: 22),
          const SizedBox(width: 12),
          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row Skeleton
                Row(
                  children: [
                    _buildShimmerContainer(width: 80, height: 16),
                    const SizedBox(width: 8),
                    _buildShimmerContainer(width: 60, height: 16),
                    const SizedBox(width: 8),
                    _buildShimmerContainer(width: 30, height: 16),
                  ],
                ),
                const SizedBox(height: 8),
                // Content Skeleton
                _buildShimmerContainer(width: double.infinity, height: 16),
                const SizedBox(height: 4),
                _buildShimmerContainer(width: 200, height: 16),
                const SizedBox(height: 16),
                // Action Buttons Row Skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerContainer(width: 40, height: 20),
                    _buildShimmerContainer(width: 40, height: 20),
                    _buildShimmerContainer(width: 40, height: 20),
                    _buildShimmerContainer(width: 40, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Comment tile skeleton
  static Widget commentTileSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7E7E8), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Skeleton
          _buildShimmerCircle(radius: 16),
          const SizedBox(width: 12),
          // Content Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Skeleton
                Row(
                  children: [
                    _buildShimmerContainer(width: 60, height: 14),
                    const SizedBox(width: 4),
                    _buildShimmerContainer(width: 50, height: 14),
                    const SizedBox(width: 4),
                    _buildShimmerContainer(width: 20, height: 14),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment Text Skeleton
                _buildShimmerContainer(width: double.infinity, height: 14),
                const SizedBox(height: 2),
                _buildShimmerContainer(width: 150, height: 14),
                const SizedBox(height: 8),
                // Actions Skeleton
                Row(
                  children: [
                    _buildShimmerContainer(width: 20, height: 16),
                    const SizedBox(width: 24),
                    _buildShimmerContainer(width: 20, height: 16),
                    const SizedBox(width: 24),
                    _buildShimmerContainer(width: 20, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Generic shimmer container
  static Widget _buildShimmerContainer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: const _ShimmerEffect(),
    );
  }

  /// Shimmer circle for avatars
  static Widget _buildShimmerCircle({required double radius}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const _ShimmerEffect(),
    );
  }

  /// Grid of post card skeletons
  static Widget postCardSkeletonList({int count = 3}) {
    return Column(
      children: List.generate(count, (index) => postCardSkeleton()),
    );
  }

  /// Grid of comment skeletons
  static Widget commentSkeletonList({int count = 5}) {
    return Column(
      children: List.generate(count, (index) => commentTileSkeleton()),
    );
  }
}

/// Shimmer effect widget
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops:
                  [
                    _animation.value - 0.3,
                    _animation.value,
                    _animation.value + 0.3,
                  ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Loading state manager for complex widgets
class LoadingStateManager {
  static Widget buildLoadingState({
    required bool isLoading,
    required Widget loadingWidget,
    required Widget contentWidget,
    Duration fadeDuration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSwitcher(
      duration: fadeDuration,
      child: isLoading ? loadingWidget : contentWidget,
    );
  }

  static Widget buildErrorState({
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState({
    required String title,
    required String subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}

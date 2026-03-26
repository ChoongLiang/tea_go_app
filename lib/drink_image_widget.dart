import 'package:flutter/material.dart';

class DrinkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const DrinkImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _FallbackPlaceholder(height: height, width: width);
    }
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _ShimmerPlaceholder(height: height, width: width);
      },
      errorBuilder: (context, error, stackTrace) =>
          _FallbackPlaceholder(height: height, width: width),
    );
  }
}

// Pulsing shimmer skeleton shown while loading
class _ShimmerPlaceholder extends StatefulWidget {
  final double? height;
  final double? width;
  const _ShimmerPlaceholder({this.height, this.width});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: Colors.grey.shade100,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (_, _) => Container(
        height: widget.height,
        width: widget.width,
        color: _colorAnimation.value,
      ),
    );
  }
}

// Shown if URL is empty or load fails
class _FallbackPlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  const _FallbackPlaceholder({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(Icons.emoji_food_beverage, color: Color(0xFF66BB6A), size: 32),
      ),
    );
  }
}

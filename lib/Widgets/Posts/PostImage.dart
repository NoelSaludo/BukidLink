import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/common/BouncingDotsLoader.dart';

class PostImage extends StatelessWidget {
  final String? imagePath; // allow null
  final String? heroTag; // optional custom hero tag to avoid collisions
  final double? width;
  final double? height;
  final BoxFit fit;

  const PostImage({
    super.key,
    required this.imagePath,
    this.heroTag,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Return nothing if imagePath is null or empty
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if the path is a URL
    Widget imageWidget;

    if (imagePath!.toLowerCase().startsWith('http')) {
      imageWidget = Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.withOpacity(0.05),
            child: const Center(
              child: BouncingDotsLoader(
                color: AppColors.ACCENT_LIME,
                size: 8.0,
              ),
            ),
          );
        },
      );
    } else {
      // Fallback to asset image
      final assetPath = 'assets/images/' + imagePath!;
      imageWidget = Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    final tag = heroTag ?? imagePath!;

    // Make the image tappable and provide a full-screen viewer using a Hero for a smooth transition.
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: animation,
              child: FullScreenImageViewer(
                imagePath: imagePath!,
                tag: tag,
                isNetwork: imagePath!.toLowerCase().startsWith('http'),
              ),
            );
          },
        ));
      },
      child: Hero(
        tag: tag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME.withOpacity(0.2),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: AppColors.ACCENT_LIME,
        size: 32,
      ),
    );
  }
}

// Full screen viewer that scales the entire overlay (background + image).
class FullScreenImageViewer extends StatefulWidget {
  final String imagePath;
  final String tag;
  final bool isNetwork;

  const FullScreenImageViewer({Key? key, required this.imagePath, required this.tag, this.isNetwork = true}) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
    _previousOffset = _offset;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_baseScale * details.scale).clamp(1.0, 4.0);
      // Move according to focal point delta to allow panning while zoomed.
      _offset = _previousOffset + details.focalPointDelta / (_scale);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Optionally, you could add bounds checking or animate back to valid area.
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.isNetwork ? Image.network(widget.imagePath) : Image.asset('assets/images/' + widget.imagePath);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Transform.translate(
                  offset: _offset,
                  child: Transform.scale(
                    scale: _scale,
                    child: Hero(
                      tag: widget.tag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: image,
                      ),
                    ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                right: 12,
                top: 12,
                child: SafeArea(
                  child: Material(
                    color: Colors.black.withOpacity(0.3),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
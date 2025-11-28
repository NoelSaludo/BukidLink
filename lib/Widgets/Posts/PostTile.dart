import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Widgets/Posts/PostIcon.dart';
import 'package:bukidlink/Widgets/Posts/PostContent.dart';
import 'package:bukidlink/Widgets/Posts/PostUsername.dart';
import 'package:bukidlink/Widgets/Posts/PostTimestamp.dart';
import 'package:bukidlink/Pages/ProfilePage.dart';
import 'package:bukidlink/Pages/farmer/FarmerProfilePage.dart'; // <-- Only if needed
import 'package:bukidlink/utils/constants/AppColors.dart';

class PostTile extends StatefulWidget {
  final Post post;

  PostTile({Key? key, required this.post}) : super(key: key);

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  final Duration _duration = const Duration(milliseconds: 120);
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  Future<Map<String, dynamic>> _fetchData() async {
    final poster = await UserService().getUserById(widget.post.posterID);
    Farm? farm;

    if (poster != null && poster.farmId != null) {
      farm = await UserService().getFarmByReference(poster.farmId);
    }

    final currentUser = await UserService().getCurrentUser();

    return {
      'poster': poster,
      'farm': farm,
      'currentUser': currentUser,
    };
  }

  void _onPointerDown(_) {
    setState(() => _scale = 0.985);
  }

  void _onPointerUp(_) {
    setState(() => _scale = 1.0);
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM d, yyyy · h:mm a');

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Animated skeleton while loading
          return AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _Shimmer(
                  gradientPosition: _shimmerAnimation.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 12, width: double.infinity, color: Colors.grey[300]),
                                const SizedBox(height: 6),
                                Container(height: 10, width: 120, color: Colors.grey[300]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 0.5, color: Colors.grey[200]),
                      const SizedBox(height: 12),
                      Container(height: 10, width: double.infinity, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(height: 10, width: MediaQuery.of(context).size.width * 0.6, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        final poster = snapshot.data!['poster'] as User?;
        final farm = snapshot.data!['farm'] as Farm?;
        final currentUser = snapshot.data!['currentUser'] as User?;

        if (poster == null) return const SizedBox();

        final imageUrl = poster.profilePic.isEmpty
            ? 'assets/images/default_profile.png'
            : poster.profilePic;

        final farmName = farm?.name ?? '';
        final currentType = currentUser?.type?.trim().toLowerCase() ?? 'user';

        final card = Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PostIcon(
                    imageUrl: imageUrl,
                    onTapped: () {
                      if (currentType == 'farmer') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FarmerProfilePage(profileID: poster.id),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(profileID: poster.id),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostUsername(
                          username: poster.username,
                          farmName: farmName,
                        ),
                        const SizedBox(height: 2),
                        PostTimestamp(
                          timestamp: formatter.format(widget.post.createdAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 8),

              PostContent(
                textContent: widget.post.textContent,
                imageUrl: widget.post.imageContent,
                heroTag: widget.post.id,
              ),
            ],
          ),
        );

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: AnimatedScale(
            scale: _scale,
            duration: _duration,
            curve: Curves.easeOut,
            child: card,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
}

// Simple shimmer widget using ShaderMask and an animated gradient position
class _Shimmer extends StatelessWidget {
  final Widget child;
  final double gradientPosition;

  const _Shimmer({Key? key, required this.child, required this.gradientPosition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        final width = bounds.width;
        final gradient = LinearGradient(
          begin: Alignment(-1.0, -0.3),
          end: Alignment(1.0, 0.3),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: [
            (gradientPosition - 0.3).clamp(0.0, 1.0),
            gradientPosition.clamp(0.0, 1.0),
            (gradientPosition + 0.3).clamp(0.0, 1.0),
          ],
        );
        return gradient.createShader(Rect.fromLTWH(0, 0, width, bounds.height));
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}

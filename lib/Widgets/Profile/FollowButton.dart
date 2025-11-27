import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';
import 'package:bukidlink/services/follow_service.dart';
import 'package:bukidlink/services/UserService.dart';

class FollowButton extends StatefulWidget {
  final String farmId;
  final double? width;
  const FollowButton({super.key, required this.farmId, this.width});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final FollowService _followService = FollowService();
  bool _isFollowing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initFollowingState();
  }

  void _initFollowingState() async {
    final currentUser = UserService.currentUser;
    if (currentUser == null) {
      setState(() {
        _isFollowing = false;
        _loading = false;
      });
      return;
    }

    // subscribe once to check
    final following = await _followService.isFollowing(
      farmId: widget.farmId,
      userId: currentUser.id,
    );
    if (mounted) {
      setState(() {
        _isFollowing = following;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = UserService.currentUser;
    if (currentUser == null) {
      // Not logged in - show a simple snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to follow farms')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _isFollowing = !_isFollowing; // optimistic
    });

    try {
      if (_isFollowing) {
        final int updated = await _followService.follow(
          farmId: widget.farmId,
          userId: currentUser.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Followed — $updated followers')),
          );
        }
      } else {
        final int updated = await _followService.unfollow(
          farmId: widget.farmId,
          userId: currentUser.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unfollowed — $updated followers')),
          );
        }
      }
    } catch (e) {
      // revert optimistic change
      setState(() {
        _isFollowing = !_isFollowing;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update follow: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isFollowing ? 'Following' : 'Follow';
    final bg = _isFollowing ? Colors.white : AppColors.primaryGreen;
    final fg = _isFollowing ? AppColors.primaryGreen : Colors.white;

    return SizedBox(
      width: widget.width ?? 110,
      height: 42,
      child: ElevatedButton(
        onPressed: _loading ? null : _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: _isFollowing ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _isFollowing
                ? BorderSide(color: AppColors.primaryGreen)
                : BorderSide.none,
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: AppTextStyles.BUTTON_TEXT.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

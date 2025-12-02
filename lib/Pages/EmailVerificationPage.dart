import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/Utils/PageNavigator.dart';

class EmailVerificationPage extends StatefulWidget {
  final String userType;
  final String emailAddress;
  final User pendingUser;
  final Farm? pendingFarm;

  const EmailVerificationPage({
    super.key,
    required this.userType,
    required this.emailAddress,
    required this.pendingUser,
    this.pendingFarm,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;
  bool _isSending = false;
  bool _isChecking = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Send initial verification email (safe even if already sent)
    _sendVerificationEmail(initial: true);
    _startPolling();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _checkVerified();
    });
  }

  Future<void> _checkVerified() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final verified = await UserService().isFirebaseCurrentUserEmailVerified(
        reloadFirst: true,
      );
      if (verified) {
        _pollTimer?.cancel();
        // After verification, persist the pending user/farm to Firestore.
        try {
          if (widget.pendingFarm != null) {
            await UserService().saveFarmToFirestore(
              widget.pendingUser,
              widget.pendingFarm!,
            );
          } else {
            await UserService().saveUserToFirestore(widget.pendingUser);
          }
        } catch (e) {
          debugPrint('Error saving user data after verification: $e');
          if (!_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save account data: ${e.toString()}'),
              ),
            );
          }
          // Even if saving fails, stop polling and let user proceed to login or retry.
        }

        if (!_isDisposed) {
          PageNavigator().goTo(context, LoadingPage(userType: widget.userType));
        }
      }
    } catch (e) {
      // ignore - we'll just try again on next tick
      debugPrint('Error checking verification status: $e');
    } finally {
      if (!_isDisposed) setState(() => _isChecking = false);
    }
  }

  Future<void> _sendVerificationEmail({bool initial = false}) async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      await UserService().sendEmailVerificationToCurrentUser();
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              initial
                  ? 'Verification email sent.'
                  : 'Verification email resent.',
            ),
          ),
        );
        _startResendCooldown();
      }
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (!_isDisposed) setState(() => _isSending = false);
    }
  }

  void _startResendCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownRemaining = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldownRemaining <= 1) {
        t.cancel();
        if (!_isDisposed) setState(() => _cooldownRemaining = 0);
        return;
      }
      if (!_isDisposed) setState(() => _cooldownRemaining -= 1);
    });
  }

  Future<void> _handleCancel() async {
    try {
      await UserService().signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
    if (!_isDisposed) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read, size: 96, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                'A verification link has been sent to',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                widget.emailAddress,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              if (_isChecking) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                const Text('Checking verification status...'),
              ] else ...[
                const SizedBox(height: 8),
                const Text(
                  'Waiting for email confirmation. Keep this screen open while you verify.',
                ),
              ],
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: (_cooldownRemaining == 0 && !_isSending)
                    ? () => _sendVerificationEmail()
                    : null,
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _cooldownRemaining > 0
                            ? 'Resend (${_cooldownRemaining}s)'
                            : 'Resend verification',
                      ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _isChecking
                    ? null
                    : () async {
                        await _checkVerified();
                      },
                child: const Text("I've verified — Check now"),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _handleCancel,
                child: const Text('Cancel and sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

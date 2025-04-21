import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/services/auth_services.dart';
import 'package:app/widgets/custom_toast.dart';

enum EmailVerificationState { initial, codeSent, verified, failed }

class EmailVerificationWidget extends StatefulWidget {
  final String email;
  final Function(bool isVerified) onVerificationComplete;
  final bool showSkipButton;

  const EmailVerificationWidget({
    Key? key,
    required this.email,
    required this.onVerificationComplete,
    this.showSkipButton = false,
  }) : super(key: key);

  @override
  State<EmailVerificationWidget> createState() =>
      _EmailVerificationWidgetState();
}

class _EmailVerificationWidgetState extends State<EmailVerificationWidget> {
  final AuthService _authService = AuthService();

  EmailVerificationState _verificationState = EmailVerificationState.initial;
  bool _isLoading = false;
  String _errorMessage = '';

  // For resend timer
  int _resendSeconds = 60;
  Timer? _resendTimer;
  bool _canResend = false;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _authService.cleanupEmailVerification();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (widget.email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await _authService.sendEmailVerification(
      widget.email,
      onEmailSent: () {
        setState(() {
          _isLoading = false;
          _verificationState = EmailVerificationState.codeSent;
        });

        _startResendTimer();

        // Start checking for verification
        _authService.startEmailVerificationCheck(onVerified: () {
          setState(() {
            _verificationState = EmailVerificationState.verified;
          });

          CustomToast.show(context,
              message: "Email verified successfully!", isError: false);

          widget.onVerificationComplete(true);
        }, onTimeout: () {
          // Only show timeout message if still in codeSent state
          if (_verificationState == EmailVerificationState.codeSent &&
              mounted) {
            CustomToast.show(context,
                message: "Email verification timed out. Please try again.",
                isError: true);
          }
        });

        CustomToast.show(context,
            message: "Verification email sent to ${widget.email}",
            isError: false);
      },
      onError: (message) {
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      },
    );
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await _authService.resendEmailVerification(
      onEmailSent: () {
        setState(() {
          _isLoading = false;
        });

        _startResendTimer();

        CustomToast.show(context,
            message: "Verification email resent to ${widget.email}",
            isError: false);
      },
      onError: (message) {
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      },
    );
  }

  void _skip() {
    _authService.cleanupEmailVerification();
    widget.onVerificationComplete(false);
  }

  Widget _buildInitialStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify Your Email Address",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF303030),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll send a verification link to ${widget.email}",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Verification helps us confirm that you own this email address and keeps your account secure.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Color(0xFFE0313B), fontSize: 12),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendVerificationEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0313B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Send Verification Email"),
          ),
        ),
        if (widget.showSkipButton)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  "Skip for now",
                  style: TextStyle(color: Color(0xFF757575)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCodeSentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Check Your Email",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF303030),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "We've sent a verification link to ${widget.email}. Please check your inbox and click the link to verify your email address.",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Icon(
            Icons.mark_email_unread_outlined,
            color: Color(0xFFE0313B),
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Once you've clicked the link, we'll automatically detect your verification. No need to return to this screen.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 16),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Color(0xFFE0313B), fontSize: 12),
            ),
          ),
        Center(
          child: _canResend
              ? TextButton(
                  onPressed: _isLoading ? null : _resendEmail,
                  child: const Text(
                    "Resend Email",
                    style: TextStyle(color: Color(0xFFE0313B)),
                  ),
                )
              : Text(
                  "Resend email in $_resendSeconds seconds",
                  style: const TextStyle(color: Color(0xFF757575)),
                ),
        ),
        if (widget.showSkipButton)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  "Skip for now",
                  style: TextStyle(color: Color(0xFF757575)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerifiedStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        const SizedBox(height: 16),
        const Text(
          "Email Verified Successfully!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF303030),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your email address ${widget.email} has been verified.",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_verificationState) {
      case EmailVerificationState.initial:
        content = _buildInitialStep();
        break;
      case EmailVerificationState.codeSent:
        content = _buildCodeSentStep();
        break;
      case EmailVerificationState.verified:
        content = _buildVerifiedStep();
        break;
      case EmailVerificationState.failed:
        content = _buildInitialStep(); // Show initial step again on failure
        break;
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

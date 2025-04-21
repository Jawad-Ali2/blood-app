import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/services/auth_services.dart';
import 'package:app/widgets/custom_toast.dart';
import 'package:get_it/get_it.dart';

enum VerificationState { inputPhone, verifyOtp, verified, failed }

class PhoneVerificationWidget extends StatefulWidget {
  final Function(bool isVerified) onVerificationComplete;
  final String initialPhoneNumber;
  final bool showSkipButton;

  const PhoneVerificationWidget({
    Key? key,
    required this.onVerificationComplete,
    this.initialPhoneNumber = '',
    this.showSkipButton = false,
  }) : super(key: key);

  @override
  State<PhoneVerificationWidget> createState() =>
      _PhoneVerificationWidgetState();
}

class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {
  final AuthService _authService = AuthService();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  VerificationState _verificationState = VerificationState.inputPhone;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _verificationId;
  int? _resendToken;

  // For OTP resend timer
  int _resendSeconds = 60;
  Timer? _resendTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber.isNotEmpty) {
      phoneController.text = widget.initialPhoneNumber;
      print("Hello");
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    _resendTimer?.cancel();
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

  Future<void> _sendVerificationCode() async {
    if (phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneController.text,
        onCodeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _verificationState = VerificationState.verifyOtp;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          _startResendTimer();
        },
        onError: (String error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final success = await _authService.verifyOtp(
        otpController.text,
        onSuccess: () {
          setState(() {
            _isLoading = false;
            _verificationState = VerificationState.verified;
          });
          CustomToast.show(context,
              message: "Phone number verified successfully", isError: false);
          widget.onVerificationComplete(true);
        },
        onError: (String error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _resendOtp() {
    if (_canResend) {
      otpController.clear();
      _sendVerificationCode();
    }
  }

  void _skip() {
    widget.onVerificationComplete(false);
  }

  Widget _buildInputPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify Your Phone Number",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF303030),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "We'll send a verification code to confirm this is your number",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Enter your phone number",
            labelText: "Phone Number",
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "+92",
                style: TextStyle(fontSize: 16, color: Color(0xFF626262)),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0313B)),
            ),
          ),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Color(0xFFE0313B), fontSize: 12),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendVerificationCode,
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
                : const Text("Send Verification Code"),
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

  Widget _buildVerifyOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Verification Code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF303030),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent a 6-digit code to ${phoneController.text}",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: "Enter 6-digit code",
            labelText: "Verification Code",
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0313B)),
            ),
          ),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Color(0xFFE0313B), fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        Center(
          child: _canResend
              ? TextButton(
                  onPressed: _resendOtp,
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(color: Color(0xFFE0313B)),
                  ),
                )
              : Text(
                  "Resend code in $_resendSeconds seconds",
                  style: const TextStyle(color: Color(0xFF757575)),
                ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _verificationState = VerificationState.inputPhone;
                  _errorMessage = '';
                });
                _resendTimer?.cancel();
              },
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text("Change Number"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF757575),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0313B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  : const Text("Verify"),
            ),
          ],
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
          "Phone Verified Successfully!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF303030),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your number ${phoneController.text} has been verified.",
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
      case VerificationState.inputPhone:
        content = _buildInputPhoneStep();
        break;
      case VerificationState.verifyOtp:
        content = _buildVerifyOtpStep();
        break;
      case VerificationState.verified:
        content = _buildVerifiedStep();
        break;
      case VerificationState.failed:
        content = _buildInputPhoneStep(); // Show input again on failure
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

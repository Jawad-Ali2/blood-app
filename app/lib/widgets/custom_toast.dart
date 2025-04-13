import 'package:flutter/material.dart';

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any existing overlays first
    _dismissCurrentOverlay();

    // Create the overlay entry
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        isError: isError,
        duration: duration,
      ),
    );

    // Show the overlay
    overlay.insert(overlayEntry);

    // Store current overlay for potential dismissal
    _currentOverlay = overlayEntry;

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_currentOverlay == overlayEntry) {
        _dismissCurrentOverlay();
      }
    });
  }

  // Keep track of the current overlay
  static OverlayEntry? _currentOverlay;

  // Method to dismiss current overlay
  static void _dismissCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // Helper function to format error messages
  static String formatErrorMessage(dynamic error) {
    String errorMsg = error.toString();

    // Handle common error types more elegantly
    if (errorMsg.contains('Failed host lookup')) {
      return 'No internet connection. Please check your network.';
    }

    // Remove technical details from DioError
    if (errorMsg.contains('DioError')) {
      // Extract meaningful part - usually between [ and ]
      final RegExp messageRegex = RegExp(r'message: ([^,\]]+)');
      final match = messageRegex.firstMatch(errorMsg);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!.trim();
      }

      // If we can't extract a specific message, provide a general one
      if (errorMsg.contains('400')) {
        return 'Invalid request data. Please check your inputs.';
      } else if (errorMsg.contains('401')) {
        return 'Authentication required. Please log in again.';
      } else if (errorMsg.contains('403')) {
        return 'You don\'t have permission to perform this action.';
      } else if (errorMsg.contains('404')) {
        return 'Resource not found. Please try again later.';
      } else if (errorMsg.contains('500')) {
        return 'Server error. Please try again later.';
      }
    }

    // If it contains "exception" or "error", try to extract just that part
    if (errorMsg.toLowerCase().contains('exception:')) {
      final parts = errorMsg.split('exception:');
      return parts.last.trim();
    }

    return errorMsg;
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final bool isError;
  final Duration duration;

  const _ToastOverlay({
    required this.message,
    required this.isError,
    required this.duration,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();

    // Start exit animation shortly before duration ends
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_animation),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: widget.isError ? Colors.red[700] : Colors.green[700],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    widget.isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      CustomToast._dismissCurrentOverlay();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

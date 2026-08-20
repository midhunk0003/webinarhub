import 'dart:ui';

import 'package:flutter/material.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info,
    Color color = Colors.blue,
    VoidCallback? onClosed, // generic callback
  }) {
    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),

        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.85), color]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    /// 👇 Called when snackbar hides / dismissed / route change
    controller.closed.then((reason) {
      onClosed?.call();
    });
  }

  static void networkError(
    BuildContext context, {
    required VoidCallback onRetry,
    VoidCallback? onClosed, // generic callback
    String message = "Network error. Please check your connection.",
  }) {
    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400.withOpacity(.9),
                    Colors.deepOrange.shade600.withOpacity(.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// 🔴 Icon Container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// 📄 Message
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// 🔁 Retry Button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onRetry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text(
                      "Retry",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    /// 👇 Called when snackbar hides / dismissed / route change
    controller.closed.then((reason) {
      onClosed?.call();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/widgets/diloges/success_and_failure_diloge_widget.dart';

class AppDialogHelper {
  static void showFailureDialog<T extends ChangeNotifier>({
    required BuildContext context,
    required dynamic failure,
    required T provider,
    required VoidCallback onTap,
  }) {
    if (failure == null) return;

    // Skip network failure if needed
    if (failure is NetworkFailure) {
      return;
    }

    if (failure is ClientFailure ||
        failure is ServerFailure ||
        failure is OtherFailureNon200 ||
        failure is AuthFailure ||
        failure is LoginFailure) {
      showDialog(
        context: context,
        builder: (_) {
          return FailureAndSuccessDialogWidget<T>(
            image: "assets/images/failuremsg.png",
            heading: "Failed",
            title: failure.message,
            provider: provider,
            onTap: onTap,
          );
        },
      );
    }
  }

  static void showSuccessDialog<T extends ChangeNotifier>({
    required BuildContext context,
    required String message,
    required T provider,
    required VoidCallback onTap,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return FailureAndSuccessDialogWidget<T>(
          image: "assets/images/successmesg.png",
          heading: "Success",
          title: message,
          provider: provider,
          onTap: onTap,
        );
      },
    );
  }

  static void showPermissionDeniedDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          title: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lms/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';

Future<dynamic> logoutMethodFunction(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,

        insetPadding: const EdgeInsets.symmetric(horizontal: 30),

        child: Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [const Color(0xFF1E1E2C), const Color(0xFF2A2A40)],
            ),

            borderRadius: BorderRadius.circular(28),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              /// ICON
              Container(
                height: 80,
                width: 80,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: Colors.red.withOpacity(0.12),
                ),

                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 42,
                ),
              ),

              const SizedBox(height: 22),

              /// TITLE
              const Text(
                'Confirm Logout',

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 14),

              /// MESSAGE
              Text(
                'Are you sure you want to logout from your account?',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey.shade300,
                ),
              ),

              const SizedBox(height: 30),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL BUTTON
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),

                        side: BorderSide(color: Colors.grey.shade600),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },

                      child: const Text(
                        'Cancel',

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// LOGOUT BUTTON
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,

                            elevation: 0,

                            padding: const EdgeInsets.symmetric(vertical: 14),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          onPressed:
                              authProvider.status == AuthStatus.loading
                                  ? null
                                  : () async {
                                    final isLogoutSuccess =
                                        await authProvider.logoutProvider();

                                    // if (!mounted) return;

                                    debugPrint(
                                      "Logout success: $isLogoutSuccess",
                                    );

                                    if (isLogoutSuccess) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/loginscreen',
                                        (route) => false,
                                      );
                                    }
                                  },

                          child: const Text(
                            'Logout',

                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

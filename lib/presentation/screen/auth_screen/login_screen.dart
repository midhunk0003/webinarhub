import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/auth_provider.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_text_form_widget_field.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:lms/presentation/widgets/social_media_icon.dart';
import 'package:lms/presentation/widgets/diloges/success_and_failure_diloge_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Stack(
          children: [
            Reusablebackground(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool _isTablet = constraints.maxWidth > 600;
                  return (authProvider.failure is NetworkFailure)
                      ? NetWorkRetry(
                        failureMessage:
                            authProvider.failure?.message ??
                            "No internet connection",
                        onRetry: () async {
                          await authProvider.loginProvider(
                            userNameController.text.trim(),
                            passwordController.text.trim(),
                          );
                          // Guard against widget being disposed during async gap
                          if (!mounted) return;

                          /// ✅ SUCCESS
                          if (authProvider.status == AuthStatus.success) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/custombottomnavbarwidget',
                            );
                            AppDialogHelper.showSuccessDialog<AuthProvider>(
                              context: context,
                              message: "Login Successful",
                              provider: authProvider,
                              onTap: () {
                                // authProvider.c();
                                Navigator.pop(context);
                              },
                            );
                          }

                          /// ❌ FAILURE
                          if (authProvider.status == AuthStatus.failure) {
                            AppDialogHelper.showFailureDialog<AuthProvider>(
                              context: context,
                              failure: authProvider.failure,
                              provider: authProvider,
                              onTap: () {
                                authProvider.clearFailure();
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                      )
                      : Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 100),
                              Text(
                                'Glad You\'re Back',
                                style: TextStyle(
                                  color: AppColor.lightgray,
                                  fontSize: _isTablet ? 30 : 24,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Log in to continue your learning journey',
                                style: TextStyle(
                                  color: AppColor.lightgray,
                                  fontSize: _isTablet ? 18 : 14,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: _isTablet ? 43 : 40),
                              CommonTextFormField(
                                isTablet: _isTablet,
                                hintText: "Enter your user name",
                                controller: userNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Enter User Name";
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );

                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return "Enter valid email";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: _isTablet ? 20 : 18),
                              CommonTextFormField(
                                isTablet: _isTablet,
                                hintText: "Enter your password",
                                controller: passwordController,
                                passVisible: true,
                                obscureText: authProvider.isObscureText,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "enter user password";
                                  }
                                  return null;
                                },
                                provider: authProvider,
                              ),
                              SizedBox(height: _isTablet ? 14 : 12),
                              Align(
                                alignment:
                                    Alignment.centerRight, // ✅ RIGHT ALIGN
                                child: InkWell(
                                  onTap: () {
                                    debugPrint('forgot password');
                                  },
                                  child: Text(
                                    'Forget password?',
                                    style: TextStyle(
                                      color: AppColor.lightgray,
                                      fontSize: _isTablet ? 14 : 12,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: _isTablet ? 40 : 36),
                              CommonCustomeButtonWidget(
                                isTablet: _isTablet,
                                text: "Login",
                                onTap:
                                    authProvider.status == AuthStatus.loading
                                        ? null
                                        : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          try {
                                            // Login API
                                            await authProvider.loginProvider(
                                              userNameController.text.trim(),
                                              passwordController.text.trim(),
                                            );

                                            if (!mounted) return;

                                            // Login Failed
                                            if (authProvider.status ==
                                                AuthStatus.failure) {
                                              AppDialogHelper.showFailureDialog<
                                                AuthProvider
                                              >(
                                                context: context,
                                                failure: authProvider.failure,
                                                provider: authProvider,
                                                onTap: () {
                                                  authProvider.clearFailure();
                                                  Navigator.pop(context);
                                                },
                                              );
                                              return;
                                            }

                                            // Login Success
                                            if (authProvider.status ==
                                                AuthStatus.success) {
                                              String? userRole;

                                              try {
                                                userRole =
                                                    await authProvider
                                                        .getUserRole();
                                              } catch (e) {
                                                debugPrint(
                                                  "Error getting user role: $e",
                                                );
                                              }

                                              if (!mounted) return;

                                              if (userRole == null ||
                                                  userRole.isEmpty) {
                                                AppDialogHelper.showFailureDialog<
                                                  AuthProvider
                                                >(
                                                  context: context,
                                                  failure:
                                                      "Unable to retrieve user role.",
                                                  provider: authProvider,
                                                  onTap: () {
                                                    authProvider.clearFailure();
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                return;
                                              }

                                              // Navigate
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/custombottomnavbarwidget',
                                                arguments: {
                                                  'userrole': userRole,
                                                },
                                              );

                                              return;
                                            }

                                            // Unexpected Status
                                            AppDialogHelper.showFailureDialog<
                                              AuthProvider
                                            >(
                                              context: context,
                                              failure:
                                                  "Something went wrong. Please try again.",
                                              provider: authProvider,
                                              onTap: () {
                                                authProvider.clearFailure();
                                                Navigator.pop(context);
                                              },
                                            );
                                          } catch (e, stackTrace) {
                                            debugPrint("Login Exception: $e");
                                            debugPrintStack(
                                              stackTrace: stackTrace,
                                            );

                                            if (!mounted) return;

                                            AppDialogHelper.showFailureDialog<
                                              AuthProvider
                                            >(
                                              context: context,
                                              failure:
                                                  "An unexpected error occurred.",
                                              provider: authProvider,
                                              onTap: () {
                                                authProvider.clearFailure();
                                                Navigator.pop(context);
                                              },
                                            );
                                          }
                                        },
                              ),

                              SizedBox(height: _isTablet ? 40 : 36),
                              Align(
                                alignment: Alignment.center,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: _isTablet ? 14 : 12,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Don\'t have an account? ',
                                        style: TextStyle(
                                          color: AppColor.lightgray,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sign up',
                                        style: TextStyle(color: Colors.blue),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                // 👉 Navigate to Signup Screen
                                                Navigator.pushNamed(
                                                  context,
                                                  '/registerscreen',
                                                );
                                              }, // second color
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: _isTablet ? 48 : 47),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SocialMediaSignupIconWidget(
                                    iconImage: "assets/svg/google.svg",
                                  ),
                                  SizedBox(width: 16),
                                  SocialMediaSignupIconWidget(
                                    iconImage: "assets/svg/facb.svg",
                                  ),
                                  SizedBox(width: 16),
                                  SocialMediaSignupIconWidget(
                                    iconImage: "assets/svg/twitter.svg",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                },
              ),
            ),
            (authProvider.status == AuthStatus.loading)
                ? Container(
                  color: Colors.black45,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.primaryBlueLight,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

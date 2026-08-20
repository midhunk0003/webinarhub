import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_text_form_widget_field.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  const EditProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool _isDialogShowing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialData();
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _initialData() async {
    firstNameController.text = widget.firstName ?? '';
    lastNameController.text = widget.lastName ?? '';
    phoneNumberController.text = widget.phoneNumber ?? '';
  }

  void _handleFailure(ProfileProvider profileProvider) {
    if (_isDialogShowing) return;

    final failures = <Failure>[
      if (profileProvider.failure != null) profileProvider.failure!,
    ];

    if (!mounted || failures.isEmpty) return;

    final failure = failures.first;

    // Ignore network failure
    if (failure is NetworkFailure) {
      return;
    }

    _isDialogShowing = true;

    AppDialogHelper.showFailureDialog(
      context: context,
      failure: failure,
      provider: profileProvider,
      onTap: () {
        profileProvider.clearFailure();
        Navigator.pop(context);
      },
    );

    if (mounted) {
      _isDialogShowing = false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool _isTablet = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: _isTablet ? 80 : 66),
                  CommonCustomAppBarWidget(
                    isTablet: _isTablet,
                    showBackButton: true,
                    title: "Edit Profile",
                    onBackButtonPressed: () {
                      Navigator.pop(context);
                    },
                    onShareButtonPressed: () {
                      print('share');
                    },
                    showShareButton: false,
                  ),
                  SizedBox(height: _isTablet ? 35 : 30),
                  CommonTextFormField(
                    isTablet: _isTablet,
                    hintText: "Enter your first name",
                    controller: firstNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "enter user first name";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: _isTablet ? 22 : 18),
                  CommonTextFormField(
                    isTablet: _isTablet,
                    hintText: "enter user last name",
                    controller: lastNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "enter last name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _isTablet ? 22 : 18),
                  CommonTextFormField(
                    isTablet: _isTablet,
                    hintText: "Mobile Number",
                    controller: phoneNumberController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "enter mobile number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _isTablet ? 28 : 24),
                  Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                      return CommonCustomeButtonWidget(
                        isTablet: _isTablet,
                        text:
                            profileProvider.isLoadingupdate
                                ? "Saving..."
                                : "Save",
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await profileProvider.updateProfileData(
                              firstNameController.text.toString(),
                              lastNameController.text.toString(),
                              phoneNumberController.text.toString(),
                            );
                            if (!mounted) return;
                            if (profileProvider.success != null) {
                              AppDialogHelper.showSuccessDialog(
                                context: context,
                                message: profileProvider.success?.message ?? '',
                                provider: profileProvider,
                                onTap: () {
                                  profileProvider.clearFailure();
                                  profileProvider.clearSuccess();
                                  Navigator.pop(context);
                                },
                              );
                              await profileProvider.getProfilePro();
                            } else if (profileProvider.failure != null) {
                              _handleFailure(profileProvider);
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

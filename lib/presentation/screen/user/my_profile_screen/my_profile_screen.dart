import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/widgets/logout_function_method.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/widgets/myprofile_menu_list_widget.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isDialogShowing = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialData();
    });
  }

  Future<void> _initialData() async {
    if (!mounted) return;
    final profileProvider = context.read<ProfileProvider>();
    await Future.wait([profileProvider.getProfilePro()]);
    if (!mounted) return;
    _handleFailure(profileProvider);
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
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return Reusablebackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool _isTablet = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: _isTablet ? 80 : 66),
                    CommonCustomAppBarWidget(
                      isTablet: _isTablet,
                      showBackButton: false,
                      title: "My Profile",
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {
                        print('share');
                      },
                      showShareButton: false,
                    ),
                    SizedBox(height: _isTablet ? 35 : 30),
                    profileProvider.isLoadingProfile
                        ? _buildShimmerHeader()
                        : HomeHeaderSectionWidget(
                          isTablet: _isTablet,
                          title: profileProvider.profileModel?.data?.fullName,
                          subTitle: profileProvider.profileModel?.data?.email,
                          profileImageUrl:
                              profileProvider
                                  .profileModel
                                  ?.data
                                  ?.profileImageUrl,
                          showNotificationIcon: false,
                          showProfileImage: true,
                          onTapImage: () {
                            print('Profile Image Tapped');
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  child: SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Drag handle
                                        Container(
                                          width: 40,
                                          height: 4,
                                          margin: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),

                                        const Text(
                                          'Change Profile Photo',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ProfileImageOption(
                                                icon: Icons.camera_alt_outlined,
                                                title: 'Camera',
                                                onTap: () {
                                                  Navigator.pop(context);

                                                  // Open camera
                                                  print('Open Camera');
                                                  profileProvider
                                                      .pickProfileImage(
                                                        ImageSource.camera,
                                                      );
                                                },
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            Expanded(
                                              child: _ProfileImageOption(
                                                icon:
                                                    Icons
                                                        .photo_library_outlined,
                                                title: 'Gallery',
                                                onTap: () {
                                                  Navigator.pop(context);

                                                  // Open gallery
                                                  print('Open Gallery');
                                                  profileProvider
                                                      .pickProfileImage(
                                                        ImageSource.gallery,
                                                      );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    const SizedBox(height: 16),
                    // Show only after selecting an image
                    if (profileProvider.selectedProfileImage != null)
                      SizedBox(
                        width: double.infinity,
                        child: CommonCustomeButtonWidget(
                          isTablet: _isTablet,
                          text:
                              profileProvider.isLoadingProfileImage
                                  ? "Uploading..."
                                  : "Upload Profile Image",
                          onTap: () async {
                            await profileProvider.uploadProfileImage();
                            if (!mounted) return;
                            if (profileProvider.success != null) {
                              AppDialogHelper.showSuccessDialog(
                                context: context,
                                message: profileProvider.success?.message ?? '',
                                provider: profileProvider,
                                onTap: () {
                                  profileProvider.clearFailure();
                                  profileProvider.clearSuccess();
                                  profileProvider.clearSelectedFile();
                                  Navigator.pop(context);
                                },
                              );
                              await profileProvider.getProfilePro();
                            } else if (profileProvider.failure != null) {
                              _handleFailure(profileProvider);
                            }
                          },
                        ),
                      ),

                    SizedBox(height: _isTablet ? 45 : 40),
                    Text(
                      'Account',
                      style: TextStyle(
                        color: AppColor.ghostwhite,
                        fontSize: _isTablet ? 15 : 12,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: _isTablet ? 18 : 16),
                    MyProfileMenuListWidget(
                      isTablet: _isTablet,
                      iconPath: 'assets/svg/profileicon.svg',
                      title: 'Edit Profile',
                      trailingIcon: Icons.arrow_forward_ios,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/editprofilescreen',
                          arguments: {
                            'firstname':
                                profileProvider.profileModel?.data?.firstName,
                            'lastname':
                                profileProvider.profileModel?.data?.lastName,
                            'phonenumber':
                                profileProvider.profileModel?.data?.phoneNumber,
                          },
                        );
                      },
                    ),
                    // SizedBox(height: _isTablet ? 18 : 16),
                    // MyProfileMenuListWidget(
                    //   isTablet: _isTablet,
                    //   iconPath: 'assets/svg/carticon.svg',
                    //   title: 'Cart',
                    //   trailingIcon: Icons.arrow_forward_ios,
                    //   onTap: () {
                    //     print('Cart');
                    //     Navigator.pushNamed(context, '/mycartscreen');
                    //   },
                    // ),
                    SizedBox(height: _isTablet ? 45 : 40),
                    Text(
                      'General',
                      style: TextStyle(
                        color: AppColor.ghostwhite,
                        fontSize: _isTablet ? 15 : 12,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // SizedBox(height: _isTablet ? 18 : 16),
                    // MyProfileMenuListWidget(
                    //   isTablet: _isTablet,
                    //   iconPath: 'assets/svg/notificationicon.svg',
                    //   title: 'Notifications',
                    //   trailingIcon: Icons.arrow_forward_ios,
                    //   onTap: () {
                    //     print('Notifications');
                    //   },
                    // ),
                    SizedBox(height: _isTablet ? 18 : 16),
                    MyProfileMenuListWidget(
                      isTablet: _isTablet,
                      iconPath: 'assets/svg/helpcentericon.svg',
                      title: 'Help Center',
                      trailingIcon: Icons.arrow_forward_ios,
                      onTap: () {
                        print('Help Center');
                        Navigator.pushNamed(context, '/helpcenterscreen');
                      },
                    ),
                    SizedBox(height: _isTablet ? 18 : 16),
                    MyProfileMenuListWidget(
                      isTablet: _isTablet,
                      iconPath: 'assets/svg/contactusicon.svg',
                      title: 'Contact Us',
                      trailingIcon: Icons.arrow_forward_ios,
                      onTap: () {
                        print('Contact Us');
                        Navigator.pushNamed(context, '/contactusscreen');
                      },
                    ),

                    SizedBox(height: _isTablet ? 18 : 16),
                    MyProfileMenuListWidget(
                      isTablet: _isTablet,
                      iconPath: 'assets/svg/changepassword.svg',
                      title: 'Change Password',
                      trailingIcon: Icons.arrow_forward_ios,
                      onTap: () {
                        print('Change Password');
                        Navigator.pushNamed(context, '/changepassword');
                      },
                    ),

                    SizedBox(height: _isTablet ? 45 : 40),
                    MyProfileMenuListWidget(
                      isTablet: _isTablet,
                      iconPath: 'assets/svg/logouticon.svg',
                      title: 'Log out',
                      trailingIcon: Icons.arrow_forward_ios,
                      logout: true,
                      onTap: () async {
                        print('Log out');
                        await logoutMethodFunction(context);
                      },
                    ),
                    SizedBox(height: _isTablet ? 110 : 150),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Widget _buildShimmerHeader() {
  return Shimmer.fromColors(
    baseColor: Colors.white.withOpacity(0.08),
    highlightColor: Colors.white.withOpacity(0.20),
    child: Row(
      children: [
        // Profile image dummy
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        // Name + subtitle dummy
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Notification dummy
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

class _ProfileImageOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileImageOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColor.gold),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

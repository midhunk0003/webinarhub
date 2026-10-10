import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/widgets/logout_function_method.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // ============================================================
  // STATE
  // ============================================================

  bool _isDialogShowing = false;
  bool _notificationEnabled = true;

  /// Used to force Image.network() to reload after an upload.
  int _profileImageVersion = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _initialData();
    });
  }

  // ============================================================
  // INITIAL DATA
  // ============================================================

  Future<void> _initialData() async {
    if (!mounted) return;

    final ProfileProvider profileProvider = context.read<ProfileProvider>();

    try {
      await profileProvider.getProfilePro();

      if (!mounted) return;

      _handleFailure(profileProvider);
    } catch (e, stackTrace) {
      debugPrint('Profile initialization error: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // FAILURE HANDLING
  // ============================================================

  void _handleFailure(ProfileProvider profileProvider) {
    if (!mounted) return;

    if (_isDialogShowing) return;

    final Failure? failure = profileProvider.failure;

    if (failure == null) return;

    // Ignore network failure as per existing behavior.
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

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          _isDialogShowing = false;
        }
      },
    );

    // If your dialog helper is non-awaitable, don't leave
    // the flag permanently enabled.
    //
    // The callback above also resets it when the dialog closes.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isDialogShowing) {
        _isDialogShowing = false;
      }
    });
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  void _showProfileImageOptions(ProfileProvider profileProvider) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // DRAG HANDLE
                // ==================================================
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D5D0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // OPTIONS
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: _ProfileImageOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        onTap: () {
                          Navigator.of(sheetContext).pop();

                          if (!mounted) return;

                          profileProvider.pickProfileImage(ImageSource.camera);
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _ProfileImageOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        onTap: () {
                          Navigator.of(sheetContext).pop();

                          if (!mounted) return;

                          profileProvider.pickProfileImage(ImageSource.gallery);
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
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<void> _uploadProfileImage(ProfileProvider profileProvider) async {
    // ------------------------------------------------------------
    // Don't upload if no image selected.
    // ------------------------------------------------------------

    final selectedImage = profileProvider.selectedProfileImage;

    if (selectedImage == null) {
      return;
    }

    // ------------------------------------------------------------
    // Prevent duplicate upload.
    // ------------------------------------------------------------

    if (profileProvider.isLoadingProfileImage) {
      return;
    }

    try {
      // ==========================================================
      // 1. UPLOAD IMAGE
      // ==========================================================

      await profileProvider.uploadProfileImage();

      if (!mounted) return;

      // ==========================================================
      // 2. CHECK FAILURE
      // ==========================================================

      if (profileProvider.failure != null) {
        _handleFailure(profileProvider);
        return;
      }

      // ==========================================================
      // 3. CHECK SUCCESS
      // ==========================================================

      if (profileProvider.success == null) {
        debugPrint('Profile image upload finished without success/failure.');

        return;
      }

      final String successMessage =
          profileProvider.success?.message?.trim().isNotEmpty == true
              ? profileProvider.success!.message!
              : 'Profile image updated successfully.';

      // ==========================================================
      // 4. IMPORTANT
      //
      // Remove local selected image BEFORE refreshing profile.
      //
      // Otherwise this UI:
      //
      // selectedProfileImage != null
      //
      // will continue showing Image.file() instead of
      // Image.network().
      // ==========================================================

      profileProvider.clearSelectedFile();

      // ==========================================================
      // 5. FORCE NETWORK IMAGE RELOAD
      //
      // Useful when backend keeps the same image URL.
      // ==========================================================

      if (mounted) {
        setState(() {
          _profileImageVersion++;
        });
      }

      // ==========================================================
      // 6. REFRESH PROFILE
      // ==========================================================

      await profileProvider.getProfilePro();

      if (!mounted) return;

      // ==========================================================
      // 7. CHECK REFRESH FAILURE
      // ==========================================================

      if (profileProvider.failure != null) {
        _handleFailure(profileProvider);
        return;
      }

      // ==========================================================
      // 8. SHOW SUCCESS
      // ==========================================================

      AppDialogHelper.showSuccessDialog(
        context: context,
        message: successMessage,
        provider: profileProvider,
        onTap: () {
          if (!mounted) return;

          profileProvider.clearFailure();
          profileProvider.clearSuccess();

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Profile image upload error: $e');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showErrorSnackBar('Unable to update profile image.');
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openEditProfile(ProfileProvider profileProvider) {
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      '/editprofilescreen',
      arguments: {
        'firstname': profileProvider.profileModel?.data?.firstName,
        'lastname': profileProvider.profileModel?.data?.lastName,
        'phonenumber': profileProvider.profileModel?.data?.phoneNumber,
      },
    );
  }

  void _openHelpCenter() {
    if (!mounted) return;

    Navigator.pushNamed(context, '/helpcenterscreen');
  }

  void _openContactUs() {
    if (!mounted) return;

    Navigator.pushNamed(context, '/contactusscreen');
  }

  void _openChangePassword() {
    if (!mounted) return;

    Navigator.pushNamed(context, '/changepassword');
  }

  void _openPaymentHistory() {
    if (!mounted) return;

    Navigator.pushNamed(context, '/paymenthistoryscreen');
  }

  void _openTermsPrivacy() {
    if (!mounted) return;

    Navigator.pushNamed(context, '/termsprivacy');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        String? role =
            profileProvider.profileModel?.data?.role?.trim().toLowerCase();
        return DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Figtree'),
          child: Reusablebackground(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth > 600;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // TOP SPACING
                      // ==================================================
                      SizedBox(height: isTablet ? 80 : 66),

                      // ==================================================
                      // APP BAR
                      // ==================================================
                      CommonCustomAppBarWidget(
                        isTablet: isTablet,
                        showBackButton: false,
                        title: 'My Profile',
                        onBackButtonPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        onShareButtonPressed: () {},
                        showShareButton: false,
                      ),

                      SizedBox(height: isTablet ? 35 : 30),

                      // ==================================================
                      // PROFILE HEADER
                      // ==================================================
                      _buildProfileHeader(context, profileProvider, isTablet),

                      SizedBox(height: isTablet ? 28 : 24),

                      // ==================================================
                      // ACCOUNT
                      // ==================================================
                      _SectionTitle(title: 'ACCOUNT', isTablet: isTablet),

                      const SizedBox(height: 16),
                      _MenuCard(
                        children: [
                          _MenuItem(
                            iconPath:
                                'assets/svg/profile_svg/edit_profile_new.svg',
                            fallbackIcon: Icons.person_outline,
                            title: 'Personal Details Edits',
                            onTap: () {
                              _openEditProfile(profileProvider);
                            },
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            iconPath:
                                'assets/svg/profile_svg/change_password_new.svg',
                            fallbackIcon: Icons.lock_outline,
                            title: 'Change password',
                            onTap: _openChangePassword,
                          ),
                        ],
                      ),

                      // ==================================================
                      // BILLING
                      // ==================================================
                      if (role != null && role != 'trainer') ...[
                        const SizedBox(height: 24),

                        _SectionTitle(
                          title: 'BILLING AND TRANSACTION',
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 16),

                        _MenuCard(
                          children: [
                            _MenuItem(
                              iconPath:
                                  'assets/svg/profile_svg/payment_history_new.svg',
                              fallbackIcon:
                                  Icons.account_balance_wallet_outlined,
                              title: 'Payment History',
                              onTap: _openPaymentHistory,
                            ),
                          ],
                        ),
                      ],

                      // ==================================================
                      // PREFERENCE & SUPPORT
                      // ==================================================
                      const SizedBox(height: 24),

                      _SectionTitle(
                        title: 'PREFERENCE & SUPPORT',
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 16),

                      _MenuCard(
                        children: [
                          // Notifications
                          _MenuItem(
                            iconPath: 'assets/svg/profile_svg/notifi_new.svg',
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            showArrow: false,
                            trailing: _SmallSwitch(
                              value: _notificationEnabled,
                              onChanged: (value) {
                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _notificationEnabled = value;
                                });
                              },
                            ),
                          ),
                          const _MenuDivider(),
                          // Help & Support
                          _MenuItem(
                            iconPath:
                                'assets/svg/profile_svg/help_center_new.svg',
                            fallbackIcon: Icons.headset_mic_outlined,
                            title: 'Help & Support',
                            onTap: _openHelpCenter,
                          ),
                          const _MenuDivider(),
                          // Contact Us
                          _MenuItem(
                            iconPath:
                                'assets/svg/profile_svg/contact_us_new.svg',
                            fallbackIcon: Icons.contact_page_outlined,
                            title: 'Contact Us',
                            onTap: _openContactUs,
                          ),
                          const _MenuDivider(),
                          // Terms & Privacy
                          _MenuItem(
                            iconPath:
                                'assets/svg/profile_svg/terms_privacy_new.svg',
                            icon: Icons.description_outlined,
                            title: 'Terms & Privacy',
                            onTap: _openTermsPrivacy,
                          ),
                        ],
                      ),

                      // ==================================================
                      // LOGOUT
                      // ==================================================
                      const SizedBox(height: 24),

                      _LogoutCard(
                        onTap: () async {
                          if (!mounted) return;
                          await logoutMethodFunction(context);
                        },
                      ),

                      SizedBox(height: isTablet ? 40 : 200),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileProvider profileProvider,
    bool isTablet,
  ) {
    // ----------------------------------------------------------
    // PROFILE LOADING
    // ----------------------------------------------------------

    if (profileProvider.isLoadingProfile) {
      return _buildShimmerHeader(isTablet: isTablet);
    }

    // ----------------------------------------------------------
    // SAFE PROFILE DATA
    // ----------------------------------------------------------

    final profileData = profileProvider.profileModel?.data;

    final String fullName = profileData?.fullName?.trim() ?? '';

    final String email = profileData?.email?.trim() ?? '';

    final String? profileImageUrl = profileData?.profileImageUrl?.trim();

    final bool hasNetworkImage =
        profileImageUrl != null && profileImageUrl.isNotEmpty;

    final bool hasLocalImage = profileProvider.selectedProfileImage != null;

    // ----------------------------------------------------------
    // RESPONSIVE SIZE
    // ----------------------------------------------------------

    final double imageSize = isTablet ? 100 : 96;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ========================================================
        // PROFILE IMAGE
        // ========================================================
        SizedBox(
          width: imageSize + 4,
          height: imageSize + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --------------------------------------------------
              // IMAGE
              // --------------------------------------------------
              GestureDetector(
                onTap:
                    profileProvider.isLoadingProfileImage
                        ? null
                        : () {
                          _showProfileImageOptions(profileProvider);
                        },
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: AppColor.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildProfileImage(
                    profileProvider: profileProvider,
                    networkImageUrl: profileImageUrl,
                    hasLocalImage: hasLocalImage,
                    hasNetworkImage: hasNetworkImage,
                    size: imageSize,
                  ),
                ),
              ),

              // --------------------------------------------------
              // EDIT BUTTON
              // --------------------------------------------------
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        profileProvider.isLoadingProfileImage
                            ? null
                            : () {
                              _showProfileImageOptions(profileProvider);
                            },
                    child: Container(
                      width: isTablet ? 34 : 32,
                      height: isTablet ? 34 : 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.gold,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child:
                          profileProvider.isLoadingProfileImage
                              ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // ========================================================
        // NAME + EMAIL + UPLOAD
        // ========================================================
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // NAME
              // --------------------------------------------------
              Text(
                fullName.isNotEmpty ? fullName : 'User',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: isTablet ? 23 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppColor.ghostwhite,
                ),
              ),

              // --------------------------------------------------
              // EMAIL
              // --------------------------------------------------
              if (email.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],

              // --------------------------------------------------
              // UPLOAD BUTTON
              // --------------------------------------------------
              if (hasLocalImage) ...[
                const SizedBox(height: 10),

                _buildUploadButton(profileProvider),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE IMAGE BUILDER
  // ============================================================

  Widget _buildProfileImage({
    required ProfileProvider profileProvider,
    required String? networkImageUrl,
    required bool hasLocalImage,
    required bool hasNetworkImage,
    required double size,
  }) {
    // ==========================================================
    // 1. LOCAL SELECTED IMAGE
    // ==========================================================
    if (hasLocalImage) {
      final file = profileProvider.selectedProfileImage;

      if (file != null) {
        return Image.file(
          file,
          key: ValueKey(file.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Local profile image error: $error');

            return _defaultProfileImage(size: size);
          },
        );
      }
    }

    // ==========================================================
    // 2. NETWORK IMAGE
    // ==========================================================

    if (hasNetworkImage && networkImageUrl != null) {
      // Add cache-busting parameter.
      //
      // This is especially useful when the backend
      // returns the SAME image URL after replacing
      // the actual image.
      final String imageUrl = _addCacheBuster(networkImageUrl);
      print('............................................. : ${imageUrl}');
      return Image.network(
        '${ApiEndPoint.serverUrl}${imageUrl}',
        key: ValueKey(imageUrl),
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,

        // ------------------------------------------------------
        // Loading
        // ------------------------------------------------------
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _profileImageLoading(size: size);
        },

        // ------------------------------------------------------
        // Error
        // ------------------------------------------------------
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Network profile image error: $error');

          debugPrint('Profile image URL: $imageUrl');

          return _defaultProfileImage(size: size);
        },
      );
    }

    // ==========================================================
    // 3. DEFAULT
    // ==========================================================

    return _defaultProfileImage(size: size);
  }

  // ============================================================
  // CACHE BUSTER
  // ============================================================

  String _addCacheBuster(String url) {
    final String separator = url.contains('?') ? '&' : '?';

    return '$url${separator}v=$_profileImageVersion';
  }

  // ============================================================
  // DEFAULT PROFILE IMAGE
  // ============================================================

  Widget _defaultProfileImage({required double size}) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFEDE9E4),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline,
        color: const Color(0xFF777777),
        size: size * 0.42,
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE LOADING
  // ============================================================

  Widget _profileImageLoading({required double size}) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFEDE9E4),
      alignment: Alignment.center,
      child: SizedBox(
        width: size * 0.22,
        height: size * 0.22,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFFF7A00),
        ),
      ),
    );
  }

  // ============================================================
  // UPLOAD BUTTON
  // ============================================================

  Widget _buildUploadButton(ProfileProvider profileProvider) {
    final bool isUploading = profileProvider.isLoadingProfileImage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            isUploading
                ? null
                : () {
                  _uploadProfileImage(profileProvider);
                },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color:
                isUploading ? const Color(0xFF777777) : const Color(0xFF222222),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              isUploading
                  ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                  : const Text(
                    'Upload',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
        ),
      ),
    );
  }

  // ============================================================
  // SHIMMER
  // ============================================================

  Widget _buildShimmerHeader({required bool isTablet}) {
    final double imageSize = isTablet ? 100 : 96;

    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9E5E0),
      highlightColor: const Color(0xFFF8F6F3),
      child: Row(
        children: [
          // Image shimmer
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          const SizedBox(width: 16),

          // Text shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isTablet ? 180 : 130,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  width: isTablet ? 220 : 160,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SECTION TITLE
// ==================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isTablet;

  const _SectionTitle({required this.title, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Figtree',
          color: AppColor.lightgray,
          fontSize: isTablet ? 11 : 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ==================================================================
// MENU CARD
// ==================================================================

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        color: AppColor.secondaryGlassColor,
        child: Column(children: children),
      ),
    );
  }
}

// ==================================================================
// MENU ITEM
// ==================================================================

class _MenuItem extends StatelessWidget {
  final String title;
  final String? iconPath;
  final IconData? icon;
  final IconData? fallbackIcon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showArrow;

  const _MenuItem({
    required this.title,
    this.iconPath,
    this.icon,
    this.fallbackIcon,
    this.onTap,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 47),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Icon
              _buildIcon(),

              const SizedBox(width: 8),

              // Title
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColor.primaryText,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Trailing
              if (trailing != null)
                trailing!
              else if (showArrow)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF777777),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  Widget _buildIcon() {
    if (iconPath != null && iconPath!.trim().isNotEmpty) {
      return SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          iconPath!,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColor.goldSoft,
            BlendMode.srcIn,
          ),
          placeholderBuilder: (context) {
            return Icon(
              fallbackIcon ?? Icons.settings_outlined,
              size: 24,
              color: AppColor.goldSoft,
            );
          },
        ),
      );
    }

    return Icon(
      icon ?? fallbackIcon ?? Icons.settings_outlined,
      size: 24,
      color: AppColor.goldSoft,
    );
  }
}

// ==================================================================
// DIVIDER
// ==================================================================

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: AppColor.goldSoft.withOpacity(0.08),
      ),
    );
  }
}

// ==================================================================
// NOTIFICATION SWITCH
// ==================================================================

class _SmallSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SmallSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.72,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppColor.goldSoft,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFD0CCC7),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ==================================================================
// LOGOUT CARD
// ==================================================================

class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: AppColor.secondaryGlassColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/profile_svg/logout_new.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF6B6B),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) {
                  return const Icon(
                    Icons.logout_outlined,
                    size: 24,
                    color: Color(0xFFFF6B6B),
                  );
                },
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Log out',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right,
                size: 17,
                color: Color(0xFFFFA0A0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// PROFILE IMAGE OPTION
// ==================================================================

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6F4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7E4E0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF333333)),

              const SizedBox(height: 8),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

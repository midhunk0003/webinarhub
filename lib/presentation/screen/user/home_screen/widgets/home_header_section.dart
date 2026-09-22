import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeHeaderSectionWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? profileImageUrl;
  final bool showNotificationIcon;
  final bool showProfileImage;
  final VoidCallback? onTapImage;

  const HomeHeaderSectionWidget({
    super.key,
    required bool isTablet,
    this.title,
    this.subTitle,
    this.profileImageUrl,
    this.showNotificationIcon = false,
    this.showProfileImage = false,
    this.onTapImage,
  }) : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        children: [
          if (showProfileImage)
            InkWell(
              onTap: onTapImage,
              child: Container(
                width: _isTablet ? 70 : 60,
                height: _isTablet ? 70 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.gold, width: 2.0),
                ),
                child: ClipOval(child: _buildProfileImage()),
              ),
            ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title?.isNotEmpty == true ? title! : 'Hello',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 30 : 24,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subTitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: _isTablet ? 18 : 14,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (showNotificationIcon)
            Consumer<TrainerAllWebinarProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildNotificationButton(context, 0, isLoading: true);
                }
                final count = provider.getNotificationCountModel?.data ?? '0';

                return _buildNotificationButton(
                  context,
                  int.tryParse(count) ?? 0,
                  isLoading: false,
                );
              },
            ),
          //  _buildNotificationButton(context, 3),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final selectedImage = provider.selectedProfileImage;

        // 1. Selected local image
        if (selectedImage != null) {
          return Image.file(
            selectedImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: AppColor.gold);
            },
          );
        }

        // 2. Existing network image
        if (profileImageUrl != null && profileImageUrl!.trim().isNotEmpty) {
          return Image.network(
            '${ApiEndPoint.serverUrl}${profileImageUrl!}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: AppColor.gold);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Icon(Icons.person, color: AppColor.gold);
            },
          );
        }

        // 3. No image
        return Icon(Icons.person, color: AppColor.ghostwhite);
      },
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    int notificationCount, {
    bool isLoading = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/trainernotificationscreen');
          },
          child: Container(
            width: _isTablet ? 80 : 54,
            height: _isTablet ? 80 : 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.secondaryGlassColor.withOpacity(0.14),
                  AppColor.primaryGlassColor.withOpacity(0.14),
                ],
              ),
              border: Border.all(
                color: AppColor.gold.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 1,
                  offset: const Offset(0.9, 0),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.06),
                  offset: const Offset(-0.6, 0),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 6,
                  spreadRadius: -2,
                  offset: const Offset(-2, 0),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.10),
                  blurRadius: 6,
                  spreadRadius: -3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Center(
                  child:
                      isLoading
                          ? SizedBox(
                            width: _isTablet ? 24 : 18,
                            height: _isTablet ? 24 : 18,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Lottie.asset(
                            'assets/lottie/Notification.json',
                            width: _isTablet ? 50 : 45,
                            height: _isTablet ? 50 : 46,
                            fit: BoxFit.contain,
                          ),
                  // SvgPicture.asset(
                  //   'assets/svg/notification.svg',
                  //   width: _isTablet ? 32 : 22,
                  //   height: _isTablet ? 32 : 22,
                  //   colorFilter: const ColorFilter.mode(
                  //     Colors.white,
                  //     BlendMode.srcIn,
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
        ),

        // Notification count
        if (notificationCount > 0)
          Positioned(
            top: _isTablet ? 4 : -4,
            right: _isTablet ? 4 : 2,
            child: Container(
              constraints: BoxConstraints(
                minWidth: _isTablet ? 24 : 19,
                minHeight: _isTablet ? 24 : 19,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: _isTablet ? 6 : 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.65),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  notificationCount > 99 ? '99+' : notificationCount.toString(),
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 10 : 9,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildNotificationButton(BuildContext context) {
  //   return Stack(
  //     clipBehavior: Clip.none,
  //     children: [
  //       InkWell(
  //         onTap: () {
  //           Navigator.pushNamed(context, '/trainernotificationscreen');
  //         },
  //         child: Container(
  //           width: _isTablet ? 80 : 54,
  //           height: _isTablet ? 80 : 54,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             gradient: LinearGradient(
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //               colors: [
  //                 AppColor.secondaryGlassColor.withOpacity(0.14),
  //                 AppColor.primaryGlassColor.withOpacity(0.14),
  //               ],
  //             ),
  //             border: Border.all(
  //               color: AppColor.gold.withOpacity(0.1),
  //               width: 1.0,
  //             ),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.35),
  //                 blurRadius: 1,
  //                 offset: const Offset(0.9, 0),
  //               ),
  //               BoxShadow(
  //                 color: Colors.white.withOpacity(0.06),
  //                 offset: const Offset(-0.6, 0),
  //               ),
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.18),
  //                 blurRadius: 6,
  //                 spreadRadius: -2,
  //                 offset: const Offset(-2, 0),
  //               ),
  //               BoxShadow(
  //                 color: Colors.white.withOpacity(0.10),
  //                 blurRadius: 6,
  //                 spreadRadius: -3,
  //                 offset: const Offset(0, -2),
  //               ),
  //             ],
  //           ),
  //           child: ClipOval(
  //             child: BackdropFilter(
  //               filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  //               child: Center(
  //                 child: SvgPicture.asset(
  //                   'assets/svg/notification.svg',
  //                   width: _isTablet ? 32 : 22,
  //                   height: _isTablet ? 32 : 22,
  //                   colorFilter: const ColorFilter.mode(
  //                     Colors.white,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),

  //       Positioned(
  //         top: _isTablet ? 10.0 : 6.0,
  //         right: _isTablet ? 10.0 : 6.0,
  //         child: Container(
  //           width: _isTablet ? 10 : 8,
  //           height: _isTablet ? 10 : 8,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF38BDF8),
  //             shape: BoxShape.circle,
  //             border: Border.all(color: const Color(0xFF0D1117), width: 1.5),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: const Color(0xFF38BDF8).withOpacity(0.65),
  //                 blurRadius: 6,
  //                 spreadRadius: 1,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class HomeHeaderSectionWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? profileImageUrl;
  final bool showNotificationIcon;
  final bool showProfileImage;

  const HomeHeaderSectionWidget({
    super.key,
    required bool isTablet,
    this.title,
    this.subTitle,
    this.profileImageUrl,
    this.showNotificationIcon = false,
    this.showProfileImage = false,
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
            Container(
              width: _isTablet ? 70 : 60,
              height: _isTablet ? 70 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.ghostwhite, width: 2.0),
              ),
              child: ClipOval(child: _buildProfileImage()),
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

          if (showNotificationIcon) _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (profileImageUrl == null || profileImageUrl!.trim().isEmpty) {
      return Icon(Icons.person, color: AppColor.ghostwhite);
    }

    return Image.network(
      profileImageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.person, color: AppColor.ghostwhite);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Icon(Icons.person, color: AppColor.ghostwhite);
      },
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
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
                color: AppColor.gradientEnd.withOpacity(0.1),
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
                  child: SvgPicture.asset(
                    'assets/svg/notification.svg',
                    width: _isTablet ? 32 : 22,
                    height: _isTablet ? 32 : 22,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: _isTablet ? 10.0 : 6.0,
          right: _isTablet ? 10.0 : 6.0,
          child: Container(
            width: _isTablet ? 10 : 8,
            height: _isTablet ? 10 : 8,
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0D1117), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withOpacity(0.65),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

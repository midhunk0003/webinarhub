import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class MyProfileMenuListWidget extends StatelessWidget {
  final String? iconPath;
  final String? title;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final bool logout;
  const MyProfileMenuListWidget({
    super.key,
    required bool isTablet,
    this.iconPath,
    this.title,
    this.trailingIcon,
    this.onTap,
    this.logout = false,
  }) : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: logout ? null : double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: _isTablet ? 24 : 16,
          vertical: _isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.formPrimaryColor.withOpacity(0.24),
              AppColor.formSecondaryColor.withOpacity(0.24),
            ],
          ),
          border: Border.all(color: AppColor.formBorderColor.withOpacity(0.24)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: logout ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Row(
              children: [
                SvgPicture.asset('${iconPath ?? ''}'),
                SizedBox(width: 12),
                Text(
                  '${title ?? ''}',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 18 : 14,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            logout
                ? SizedBox()
                : Icon(
                  trailingIcon ?? Icons.arrow_forward_ios,
                  color: AppColor.ghostwhite,
                  size: _isTablet ? 18 : 14,
                ),
          ],
        ),
      ),
    );
  }
}

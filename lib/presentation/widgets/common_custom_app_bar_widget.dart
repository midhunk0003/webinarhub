import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class CommonCustomAppBarWidget extends StatelessWidget {
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onShareButtonPressed;
  final bool showShareButton;
  const CommonCustomAppBarWidget({
    super.key,
    required bool isTablet,
    this.showBackButton = false,
    this.title,
    this.onBackButtonPressed,
    this.onShareButtonPressed,
    this.showShareButton = false,
  }) : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                showBackButton
                    ? InkWell(
                      onTap: onBackButtonPressed,
                      child: Icon(
                        Icons.arrow_back,
                        size: _isTablet ? 48 : 24,
                        color: AppColor.ghostwhite,
                      ),
                    )
                    : SizedBox(),
                SizedBox(width: showBackButton ? 12 : 0),
                Expanded(
                  child: Text(
                    '${title ?? ''}',
                    style: TextStyle(
                      color: AppColor.ghostwhite,
                      fontSize: _isTablet ? 28 : 24,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          showShareButton
              ? InkWell(
                onTap: onShareButtonPressed,
                child: Container(
                  width: _isTablet ? 40 : 30,
                  height: _isTablet ? 40 : 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.formPrimaryColor.withOpacity(0.24),
                        AppColor.formSecondaryColor.withOpacity(0.24),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_isTablet ? 8 : 6),
                    border: Border.all(
                      color: AppColor.formBorderColor.withOpacity(0.24),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/shareicon.svg',
                      width: _isTablet ? 20 : 16,
                      height: _isTablet ? 20 : 16,
                    ),
                  ),
                ),
              )
              : SizedBox(),
        ],
      ),
    );
  }
}

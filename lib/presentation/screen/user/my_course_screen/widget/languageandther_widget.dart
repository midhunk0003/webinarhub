import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class LanguageAndOtherWIdget extends StatelessWidget {
  final String? svgIcon;
  final String? title;
  final String? subTitle;
  const LanguageAndOtherWIdget({
    super.key,
    required bool isTablet,
    required this.svgIcon,
    required this.title,
    required this.subTitle,
  }) : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.24),
            AppColor.formSecondaryColor.withOpacity(0.24),
          ],
        ),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.24)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.formPrimaryColor.withOpacity(0.24),
                    AppColor.formSecondaryColor.withOpacity(0.24),
                  ],
                ),
                border: Border.all(
                  color: AppColor.formBorderColor.withOpacity(0.24),
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  width: 18,
                  height: 18,
                  '${svgIcon ?? ''}',
                ),
              ),
            ),
            SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${title ?? ''}',
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: _isTablet ? 14 : 10,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${subTitle ?? ''}',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 16 : 14,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

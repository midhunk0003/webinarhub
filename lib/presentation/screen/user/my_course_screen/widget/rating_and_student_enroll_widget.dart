import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/core/colors.dart';

class RatingAndStudentEnrollWidget extends StatelessWidget {
  final String maxParticipants;
  final bool isTablet;
  final VoidCallback? onTap;

  const RatingAndStudentEnrollWidget({
    required this.isTablet,
    required this.maxParticipants,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: AppColor.cardBackground.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.gold.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isTablet ? 42 : 36,
                height: isTablet ? 42 : 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/svg/enrollstudent.svg',
                  width: isTablet ? 21 : 18,
                  height: isTablet ? 21 : 18,
                  colorFilter: ColorFilter.mode(AppColor.gold, BlendMode.srcIn),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$maxParticipants Students',
                    style: TextStyle(
                      color: AppColor.ghostwhite,
                      fontSize: isTablet ? 16 : 14,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Maximum capacity',
                    style: TextStyle(
                      color: AppColor.lightgray,
                      fontSize: isTablet ? 13 : 12,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColor.ghostwhite.withOpacity(0.7),
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

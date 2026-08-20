import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class RatingAndStudentEnrollWidget extends StatelessWidget {
  final String? stundEnrolled;
  final bool isTablet;
  final VoidCallback? onTap;

  const RatingAndStudentEnrollWidget({
    required this.stundEnrolled,
    required this.isTablet,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: isTablet ? 20 : 12,
      runSpacing: 8,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/enrollstudent.svg',
                  width: isTablet ? 20 : 16,
                ),

                const SizedBox(width: 4),

                Text(
                  stundEnrolled ?? '',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: isTablet ? 16 : 14,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(width: 4),

                Text(
                  '(Students Enrolled)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: isTablet ? 16 : 14,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 14,
                  color: AppColor.ghostwhite,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

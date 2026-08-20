import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class SocialMediaSignupIconWidget extends StatelessWidget {
  final String? iconImage;
  const SocialMediaSignupIconWidget({super.key, required this.iconImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.24),
            AppColor.formSecondaryColor.withOpacity(0.24),
          ],
        ),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(child: SvgPicture.asset('${iconImage}' ?? '')),
    );
  }
}

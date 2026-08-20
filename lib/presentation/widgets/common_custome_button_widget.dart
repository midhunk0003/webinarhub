import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';

class CommonCustomeButtonWidget extends StatelessWidget {
  const CommonCustomeButtonWidget({
    super.key,
    required this.isTablet,
    this.onTap,
    this.text,
  });

  final bool isTablet;
  final VoidCallback? onTap;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive values
    final double height = width < 600 ? 50 : 60;
    final double fontSize = width < 600 ? 16 : 18;
    final double radius = width < 600 ? 30 : 40;
    final double horizontalPadding = width * 0.00;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: AppColor.primaryBlueGradient,
            ),
          ),
          child: Center(
            child: FittedBox(
              child: Text(
                text ?? '',
                style: TextStyle(
                  color: AppColor.ghostwhite,
                  fontSize: fontSize,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

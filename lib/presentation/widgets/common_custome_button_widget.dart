// import 'package:flutter/material.dart';
// import 'package:lms/core/colors.dart';

// class CommonCustomeButtonWidget extends StatelessWidget {
//   const CommonCustomeButtonWidget({
//     super.key,
//     required this.isTablet,
//     this.onTap,
//     this.text,
//     this.icon,
//   });

//   final bool isTablet;
//   final VoidCallback? onTap;
//   final String? text;
//   final IconData? icon;
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;

//     // Responsive values
//     final double height = width < 600 ? 50 : 60;
//     final double fontSize = width < 600 ? 16 : 18;
//     final double radius = width < 600 ? 30 : 40;
//     final double horizontalPadding = width * 0.00;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(radius),
//         child: Container(
//           height: height,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(radius),
//             gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: AppColor.goldGradient,
//             ),
//           ),
//           child: Center(
//             child: FittedBox(
//               child: Row(
//                 children: [
//                   if (icon != null) ...[
//                     Icon(
//                       icon,
//                       color: AppColor.buttonText,
//                       size: width < 600 ? 20 : 22,
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                   Text(
//                     text ?? '',
//                     style: TextStyle(
//                       color: AppColor.buttonText,
//                       fontSize: fontSize,
//                       fontFamily: 'Urbanist',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms/core/colors.dart';
import 'package:lottie/lottie.dart';

class CommonCustomeButtonWidget extends StatefulWidget {
  const CommonCustomeButtonWidget({
    super.key,
    required this.isTablet,
    this.onTap,
    this.text,
    this.icon,
    this.lotty = false,
  });

  final bool isTablet;
  final VoidCallback? onTap;
  final String? text;
  final IconData? icon;
  final bool lotty;

  @override
  State<CommonCustomeButtonWidget> createState() =>
      _CommonCustomeButtonWidgetState();
}

class _CommonCustomeButtonWidgetState extends State<CommonCustomeButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Continuous color sliding animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // 📳 Vibrate
    await HapticFeedback.mediumImpact();

    // Original action
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final double height = width < 600 ? 50 : 60;
    final double fontSize = width < 600 ? 16 : 18;
    final double radius = width < 600 ? 30 : 40;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;

        return Padding(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),

                // ✨ Continuous sliding color
                gradient: LinearGradient(
                  begin: Alignment(-1.5 + (value * 3), 0),
                  end: Alignment(0.5 + (value * 3), 0),
                  colors: AppColor.goldGradient,
                ),
              ),
              child: Center(
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: AppColor.buttonText,
                          size: width < 600 ? 20 : 22,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text ?? '',
                        style: TextStyle(
                          color: AppColor.buttonText,
                          fontSize: fontSize,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.lotty) ...[
                        Lottie.asset(
                          'assets/lottie/animation_arrow.json',
                          width: 45,
                          height: 46,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

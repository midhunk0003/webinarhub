import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';

class Reusablebackground extends StatelessWidget {
  final Widget? child;
  const Reusablebackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool _isTablet = constraints.maxWidth > 600;
          return Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: AppColor.darkGradient,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: _isTablet ? 0 : 0,
                horizontal: _isTablet ? 48 : 24,
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

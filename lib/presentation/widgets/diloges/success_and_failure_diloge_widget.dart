import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';

class FailureAndSuccessDialogWidget<T extends ChangeNotifier>
    extends StatefulWidget {
  final String image;
  final String? heading;
  final String? title;
  final T provider;
  final VoidCallback onTap;

  const FailureAndSuccessDialogWidget({
    Key? key,
    required this.image,
    this.heading,
    this.title,
    required this.provider,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FailureAndSuccessDialogWidget<T>> createState() =>
      _FailureAndSuccessDialogWidgetState<T>();
}

class _FailureAndSuccessDialogWidgetState<T extends ChangeNotifier>
    extends State<FailureAndSuccessDialogWidget<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 80 : 40,
        vertical: 24,
      ),

      child: ScaleTransition(
        scale: _scaleAnimation,

        child: Container(
          padding: EdgeInsets.all(isTablet ? 28 : 20),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B1220), Color(0xFF111827)],
            ),

            borderRadius: BorderRadius.circular(25),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.9),

                offset: const Offset(0, 2),

                blurRadius: 2,
                spreadRadius: -2,
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Image.asset(
                widget.image,
                width: isTablet ? 64 : 48,
                height: isTablet ? 64 : 48,
              ),

              const SizedBox(height: 20),

              Text(
                widget.heading ?? '',

                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,

                  fontWeight: FontWeight.bold,

                  color: AppColor.ghostwhite,

                  shadows: const [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black26,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.title ?? '',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,

                  color: AppColor.lightgray,
                ),
              ),

              const SizedBox(height: 25),

              CommonCustomeButtonWidget(
                isTablet: isTablet,

                text: "Ok",

                onTap: widget.onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

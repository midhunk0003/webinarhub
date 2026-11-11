import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_empty_state_home.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';

class UpcomingWebinarCard extends StatefulWidget {
  final TrainerDashboardProvider trainerDashProvider;
  final bool isTablet;

  const UpcomingWebinarCard({
    super.key,
    required this.trainerDashProvider,
    required this.isTablet,
  });

  @override
  State<UpcomingWebinarCard> createState() => _UpcomingWebinarCardState();
}

class _UpcomingWebinarCardState extends State<UpcomingWebinarCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webinar =
        widget
            .trainerDashProvider
            .trainerUpcommingAndAssignedModel
            ?.data
            ?.upcomingWebinar;

    if (webinar == null) {
      return WebinarEmptyState(
        title: "No Upcoming Webinars",
        subTitle: 'Your scheduled webinars will appear here',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallMobile = constraints.maxWidth < 380;
        final radius = widget.isTablet ? 20.0 : 18.0;

        final imageWidth =
            widget.isTablet
                ? 220.0
                : isSmallMobile
                ? 105.0
                : 120.0;

        final imageHeight =
            widget.isTablet
                ? 220.0
                : isSmallMobile
                ? 165.0
                : 185.0;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final value = _animationController.value;
            final breathe = (math.sin(value * math.pi * 2) + 1) / 2;
            final pulse = (math.sin(value * math.pi * 4) + 1) / 2;

            return Transform.translate(
              offset: Offset(0, -0.7 * breathe),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.goldGradient.first.withOpacity(
                        0.08 + breathe * 0.12,
                      ),
                      blurRadius: 12 + breathe * 12,
                      spreadRadius: 1 + breathe * 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Stack(
                    children: [
                      // Main card.
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF191919),
                              const Color(0xFF111111),
                              AppColor.formSecondaryColor.withOpacity(0.35),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(
                            color: AppColor.gold.withOpacity(0.24),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _TrainerGoldenParticlesPainter(
                                    animationValue: value,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Webinar thumbnail.
                                SizedBox(
                                  width: imageWidth,
                                  height: imageHeight,
                                  child: _buildThumbnail(
                                    imageUrl: webinar.thumbnailUrl,
                                    radius: widget.isTablet ? 16 : 14,
                                    breathe: breathe,
                                  ),
                                ),

                                SizedBox(width: widget.isTablet ? 20 : 12),

                                // Webinar details.
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Upcoming label.
                                      Row(
                                        children: [
                                          Container(
                                            width: 8 + pulse * 2,
                                            height: 8 + pulse * 2,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  AppColor.goldGradient.first,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColor.gold
                                                      .withOpacity(
                                                        0.4 + pulse * 0.4,
                                                      ),
                                                  blurRadius: 4 + pulse * 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          const Flexible(
                                            child: Text(
                                              'UPCOMING WEBINAR',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      // Webinar title.
                                      Text(
                                        webinar.title ?? 'Untitled Webinar',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize:
                                              widget.isTablet
                                                  ? 21
                                                  : isSmallMobile
                                                  ? 15
                                                  : 18,
                                          height: 1.15,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Date and time.
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.calendar_month_rounded,
                                            size: 15,
                                            color: AppColor.goldGradient.last,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              formatWebinarDate(
                                                webinar.startDateTime,
                                                webinar.endDateTime,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize:
                                                    isSmallMobile ? 10 : 11,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Student count.
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.gold.withOpacity(
                                            0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          border: Border.all(
                                            color: AppColor.gold.withOpacity(
                                              0.20,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.people_alt_outlined,
                                              color: AppColor.goldLight,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                '${webinar.enrolledCount ?? 0} Students',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Join / details button.
                                      SizedBox(
                                        width: double.infinity,
                                        height: widget.isTablet ? 44 : 40,
                                        child: CommonCustomeButtonWidget(
                                          isTablet: widget.isTablet,
                                          text: 'View Webinar',
                                          icon: null,
                                          lotty: true,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/trainerwebinardetailpage',
                                              arguments: {
                                                'courseId': webinar.id,
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Animated gold border.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _TrainerBorderShinePainter(
                              animationValue: value,
                              radius: radius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThumbnail({
    required String? imageUrl,
    required double radius,
    required double breathe,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.formPrimaryColor,
              AppColor.formSecondaryColor,
              const Color(0xFF0B0B0B),
            ],
          ),
          border: Border.all(color: AppColor.gold.withOpacity(0.35)),
        ),
        child:
            hasImage
                ? Image.network(
                  '${ApiEndPoint.serverUrl}$imageUrl',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _thumbnailFallback(breathe);
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _thumbnailFallback(breathe);
                  },
                )
                : _thumbnailFallback(breathe),
      ),
    );
  }

  Widget _thumbnailFallback(double breathe) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -25,
          right: -25,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.gold.withOpacity(0.12)),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 54 + breathe * 4,
            height: 54 + breathe * 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.gold.withOpacity(0.08),
              border: Border.all(color: AppColor.gold.withOpacity(0.28)),
            ),
            child: Icon(
              Icons.video_camera_back_outlined,
              color: AppColor.goldLight,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

// Moving gold border.
class _TrainerBorderShinePainter extends CustomPainter {
  final double animationValue;
  final double radius;

  _TrainerBorderShinePainter({
    required this.animationValue,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
      Radius.circular(radius),
    );

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..shader = LinearGradient(
            begin: Alignment(-1 + animationValue * 2, -1),
            end: Alignment(1 + animationValue * 2, 1),
            colors: [
              Colors.transparent,
              AppColor.gold.withOpacity(0.08),
              AppColor.gold.withOpacity(0.65),
              AppColor.goldLight.withOpacity(0.85),
              Colors.transparent,
            ],
            stops: const [0, 0.35, 0.48, 0.55, 1],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _TrainerBorderShinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.radius != radius;
  }
}

// Gold particle animation.
class _TrainerGoldenParticlesPainter extends CustomPainter {
  final double animationValue;

  _TrainerGoldenParticlesPainter({required this.animationValue});

  static const List<List<double>> _particles = [
    [0.06, 0.16, 3, 0],
    [0.20, 0.08, 2, 0.35],
    [0.42, 0.14, 2.5, 0.70],
    [0.73, 0.07, 2, 0.20],
    [0.91, 0.20, 3, 0.55],
    [0.84, 0.82, 2.5, 0.40],
    [0.62, 0.92, 2, 0.15],
    [0.32, 0.88, 3, 0.65],
    [0.08, 0.74, 2, 0.30],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      final progress = (animationValue + particle[3]) % 1.0;
      final blink = (math.sin(progress * math.pi * 2) + 1) / 2;

      final center = Offset(
        size.width * particle[0],
        size.height * particle[1],
      );

      final paint =
          Paint()
            ..color = AppColor.goldGradient.first.withOpacity(
              0.10 + blink * 0.55,
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + blink * 2);

      canvas.drawCircle(center, particle[2] * (0.65 + blink * 0.45), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrainerGoldenParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

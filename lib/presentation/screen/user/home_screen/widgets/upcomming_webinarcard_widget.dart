import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lms/core/api_end_point.dart';

import 'package:lms/core/colors.dart';
import 'package:lms/data/model/user_dashboard_upcomming_and_recent_model/user_dashboard_upcomming_and_recent_model.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_empty_state_home.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';
import 'package:lottie/lottie.dart';

class UpcomingWebinarCard extends StatefulWidget {
  final UserDashboardProvider userDashboardProvider;
  final bool isTablet;

  /// Webinar thumbnail URL.
  ///
  /// Example:
  /// imageUrl: upcomingWebinar.thumbnailUrl
  final String? imageUrl;

  const UpcomingWebinarCard({
    super.key,
    required this.userDashboardProvider,
    required this.isTablet,
    this.imageUrl,
  });

  @override
  State<UpcomingWebinarCard> createState() => _UpcomingWebinarCardState();
}

class _UpcomingWebinarCardState extends State<UpcomingWebinarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

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
    final upcomingWebinar =
        widget
            .userDashboardProvider
            .userDashboardUpcommingAndRecentModel
            ?.data
            ?.upcomingWebinar;

    if (upcomingWebinar == null) {
      return const WebinarEmptyState(
        title: 'No Upcoming Webinars',
        subTitle: 'New webinars will appear here when available.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isSmallMobile = width < 380;

        final double cardRadius = widget.isTablet ? 20 : 18;

        // ---------------------------------------------------------------
        // IMAGE SIZE
        // ---------------------------------------------------------------
        final double imageWidth =
            widget.isTablet
                ? 245
                : isSmallMobile
                ? 112
                : 130;

        final double imageHeight =
            widget.isTablet
                ? 205
                : isSmallMobile
                ? 160
                : 180;

        return InkWell(
          borderRadius: BorderRadius.circular(cardRadius),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/userwebinarcoursedetailpage',
              arguments: {'courseId': upcomingWebinar.webinarId},
            );
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final value = _animationController.value;

              // Smooth breathing animation.
              final breathe = (math.sin(value * math.pi * 2) + 1) / 2;

              // Faster pulse.
              final pulse = (math.sin(value * math.pi * 4) + 1) / 2;

              return Transform.translate(
                offset: Offset(0, -0.7 * breathe),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.goldGradient.first.withOpacity(
                          0.08 + (breathe * 0.12),
                        ),
                        blurRadius: 12 + (breathe * 12),
                        spreadRadius: 1 + (breathe * 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(cardRadius),
                    child: Stack(
                      children: [
                        // =====================================================
                        // MAIN CARD
                        // =====================================================
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.formPrimaryColor.withOpacity(0.25),
                                AppColor.formSecondaryColor.withOpacity(0.25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(cardRadius),
                            border: Border.all(
                              color: AppColor.formBorderColor.withOpacity(0.24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.40),
                                offset: const Offset(0, 3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // ===============================================
                              // GOLDEN PARTICLES
                              // ===============================================
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _GoldenParticlesPainter(
                                      animationValue: value,
                                    ),
                                  ),
                                ),
                              ),

                              // ===============================================
                              // IMAGE + CONTENT
                              // ===============================================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // =========================================
                                  // LEFT IMAGE
                                  // =========================================
                                  SizedBox(
                                    width: imageWidth,
                                    height: imageHeight,
                                    child: _buildWebinarImage(
                                      imageUrl: upcomingWebinar.thumbnailUrl,
                                      radius: widget.isTablet ? 16 : 14,
                                      pulse: pulse,
                                      breathe: breathe,
                                    ),
                                  ),

                                  SizedBox(width: widget.isTablet ? 20 : 14),

                                  // =========================================
                                  // RIGHT CONTENT
                                  // =========================================
                                  Expanded(
                                    child: _buildContent(
                                      context: context,
                                      upcomingWebinar: upcomingWebinar,
                                      pulse: pulse,
                                      breathe: breathe,
                                      isSmallMobile: isSmallMobile,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // =====================================================
                        // ANIMATED GOLD BORDER
                        // =====================================================
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _BorderShinePainter(
                                animationValue: value,
                                radius: cardRadius,
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
          ),
        );
      },
    );
  }

  // ===========================================================================
  // IMAGE
  // ===========================================================================

  Widget _buildWebinarImage({
    required String? imageUrl,
    required double radius,
    required double pulse,
    required double breathe,
  }) {
    final bool hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColor.goldGradient.first.withOpacity(0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.goldGradient.first.withOpacity(
                0.08 + (pulse * 0.08),
              ),
              blurRadius: 14,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child:
            hasImage
                ? Image.network(
                  "${ApiEndPoint.serverUrl}${imageUrl}",
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,

                  // ---------------------------------------------------------
                  // IMAGE LOADING
                  // ---------------------------------------------------------
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return _buildImageFallback(breathe: breathe, loading: true);
                  },

                  // ---------------------------------------------------------
                  // IMAGE ERROR
                  // ---------------------------------------------------------
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageFallback(
                      breathe: breathe,
                      loading: false,
                    );
                  },
                )
                : _buildImageFallback(breathe: breathe, loading: false),
      ),
    );
  }

  // ===========================================================================
  // IMAGE FALLBACK
  // ===========================================================================

  Widget _buildImageFallback({required double breathe, required bool loading}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor,
            AppColor.formSecondaryColor,
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle.
          Positioned(
            top: -40,
            right: -35,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.goldGradient.first.withOpacity(0.08),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -45,
            left: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.goldGradient.last.withOpacity(0.06),
                ),
              ),
            ),
          ),

          // Center icon.
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 54 + (breathe * 4),
              height: 54 + (breathe * 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.goldGradient.first.withOpacity(0.08),
                border: Border.all(
                  color: AppColor.goldGradient.first.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.goldGradient.first.withOpacity(0.12),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Icon(
                loading
                    ? Icons.image_outlined
                    : Icons.video_camera_back_outlined,
                color: AppColor.goldGradient.last,
                size: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RIGHT CONTENT
  // ===========================================================================

  Widget _buildContent({
    required BuildContext context,
    required UserUpcomingWebinar upcomingWebinar,
    required double pulse,
    required double breathe,
    required bool isSmallMobile,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================================================
        // UPCOMING LABEL
        // ===============================================================
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10 + (pulse * 3),
              height: 10 + (pulse * 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.goldGradient.first.withOpacity(
                  0.08 + (pulse * 0.10),
                ),
              ),
              child: Center(
                child: Container(
                  width: 5 + (pulse * 1.5),
                  height: 5 + (pulse * 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.goldGradient.first,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.goldGradient.first.withOpacity(
                          0.5 + (pulse * 0.5),
                        ),
                        blurRadius: 4 + (pulse * 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Opacity(
                opacity: 0.65 + (pulse * 0.35),
                child: const Text(
                  'Upcoming Webinar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ===============================================================
        // TITLE
        // ===============================================================
        Transform.scale(
          scale: 1.0 + (breathe * 0.008),
          alignment: Alignment.centerLeft,
          child: Text(
            upcomingWebinar.title ?? 'N/A',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize:
                  widget.isTablet
                      ? 21
                      : isSmallMobile
                      ? 16
                      : 18,
              height: 1.12,
              fontFamily: 'Urbanist',
              shadows: [
                Shadow(
                  color: AppColor.goldGradient.first.withOpacity(
                    0.08 + (breathe * 0.18),
                  ),
                  blurRadius: 3 + (breathe * 5),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 9),

        // ===============================================================
        // DATE
        // ===============================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  upcomingWebinar.startDate,
                  upcomingWebinar.endDate,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallMobile ? 10 : 11,
                  height: 1.3,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ===============================================================
        // PRICE TAG
        // ===============================================================
        _buildPriceTag(
          upcomingWebinar: upcomingWebinar,
          pulse: pulse,
          isSmallMobile: isSmallMobile,
        ),

        const SizedBox(height: 11),

        // ===============================================================
        // JOIN BUTTON
        // ===============================================================
        SizedBox(
          width: double.infinity,
          height:
              widget.isTablet
                  ? 44
                  : isSmallMobile
                  ? 38
                  : 42,
          child: CommonCustomeButtonWidget(
            isTablet: widget.isTablet,
            text: 'Join',
            icon: null,
            lotty: true,
            onTap: () async {
              Navigator.pushNamed(
                context,
                '/userwebinarcoursedetailpage',
                arguments: {'courseId': upcomingWebinar.webinarId},
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PRICE / FREE TAG
  // ===========================================================================

  Widget _buildPriceTag({
    required UserUpcomingWebinar upcomingWebinar,
    required double pulse,
    required bool isSmallMobile,
  }) {
    final bool isPaid = upcomingWebinar.isPaid == 'true';

    final dynamic price = upcomingWebinar.price;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 9 : 11,
        vertical: isSmallMobile ? 7 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors:
              isPaid
                  ? [
                    AppColor.goldGradient.first.withOpacity(
                      0.20 + (pulse * 0.04),
                    ),
                    AppColor.goldGradient.last.withOpacity(0.07),
                  ]
                  : [
                    Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.025),
                  ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isPaid
                  ? AppColor.goldGradient.first.withOpacity(
                    0.45 + (pulse * 0.15),
                  )
                  : Colors.white.withOpacity(0.16),
          width: 1,
        ),
        boxShadow: [
          if (isPaid)
            BoxShadow(
              color: AppColor.goldGradient.first.withOpacity(
                0.08 + (pulse * 0.08),
              ),
              blurRadius: 10 + (pulse * 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // ===============================================================
          // PRICE ICON
          // ===============================================================
          Container(
            width: isSmallMobile ? 27 : 30,
            height: isSmallMobile ? 27 : 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  isPaid
                      ? LinearGradient(
                        colors: [
                          AppColor.goldGradient.first,
                          AppColor.goldGradient.last,
                        ],
                      )
                      : null,
              color: isPaid ? null : Colors.white.withOpacity(0.10),
              border:
                  isPaid
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.18)),
              boxShadow:
                  isPaid
                      ? [
                        BoxShadow(
                          color: AppColor.goldGradient.first.withOpacity(0.30),
                          blurRadius: 8,
                        ),
                      ]
                      : null,
            ),
            child: Icon(
              isPaid
                  ? Icons.workspace_premium_rounded
                  : Icons.card_giftcard_rounded,
              color: isPaid ? Colors.black : Colors.white70,
              size: isSmallMobile ? 14 : 16,
            ),
          ),

          const SizedBox(width: 8),

          // ===============================================================
          // PRICE TEXT
          // ===============================================================
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaid ? 'WEBINAR FEE' : 'ACCESS',
                  style: TextStyle(
                    color: isPaid ? AppColor.goldGradient.last : Colors.white54,
                    fontFamily: 'Urbanist',
                    fontSize: isSmallMobile ? 7 : 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaid ? _formatPrice(price) : 'FREE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPaid ? Colors.white : Colors.white70,
                    fontFamily: 'Urbanist',
                    fontSize: isSmallMobile ? 15 : 17,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          // ===============================================================
          // RIGHT LABEL
          // ===============================================================
          if (isPaid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.goldGradient.first.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PAID',
                style: TextStyle(
                  color: AppColor.goldGradient.last,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Urbanist',
                  letterSpacing: 0.5,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'FREE',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Urbanist',
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FORMAT PRICE
  // ===========================================================================

  String _formatPrice(dynamic price) {
    if (price == null) {
      return '₹0';
    }

    if (price is num) {
      if (price % 1 == 0) {
        return '₹${price.toInt()}';
      }

      return '₹${price.toStringAsFixed(2)}';
    }

    final parsed = double.tryParse(price.toString());

    if (parsed != null) {
      if (parsed % 1 == 0) {
        return '₹${parsed.toInt()}';
      }

      return '₹${parsed.toStringAsFixed(2)}';
    }

    return '₹$price';
  }
}

// ============================================================================
// GOLDEN PARTICLES
// ============================================================================

class _GoldenParticlesPainter extends CustomPainter {
  final double animationValue;

  _GoldenParticlesPainter({required this.animationValue});

  static const List<_Particle> particles = [
    _Particle(0.06, 0.16, 3.0, 0.00),
    _Particle(0.20, 0.08, 2.0, 0.35),
    _Particle(0.42, 0.14, 2.5, 0.70),
    _Particle(0.73, 0.07, 2.0, 0.20),
    _Particle(0.91, 0.20, 3.0, 0.55),
    _Particle(0.96, 0.52, 2.0, 0.85),
    _Particle(0.84, 0.82, 2.5, 0.40),
    _Particle(0.62, 0.92, 2.0, 0.15),
    _Particle(0.32, 0.88, 3.0, 0.65),
    _Particle(0.08, 0.74, 2.0, 0.30),
    _Particle(0.03, 0.42, 2.5, 0.90),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final progress = (animationValue + particle.delay) % 1.0;

      final blink = (math.sin(progress * math.pi * 2) + 1) / 2;

      final x = size.width * particle.x;

      final y = size.height * particle.y;

      final radius = particle.size * (0.65 + blink * 0.45);

      final opacity = 0.10 + (blink * 0.70);

      final paint =
          Paint()
            ..color = AppColor.goldGradient.first.withOpacity(opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + (blink * 3));

      canvas.drawCircle(Offset(x, y), radius, paint);

      if (blink > 0.55) {
        final centerPaint =
            Paint()
              ..color = AppColor.goldGradient.last.withOpacity(blink * 0.65);

        canvas.drawCircle(Offset(x, y), radius * 0.35, centerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GoldenParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// ============================================================================
// PARTICLE MODEL
// ============================================================================

class _Particle {
  final double x;
  final double y;
  final double size;
  final double delay;

  const _Particle(this.x, this.y, this.size, this.delay);
}

// ============================================================================
// MOVING GOLDEN BORDER
// ============================================================================

class _BorderShinePainter extends CustomPainter {
  final double animationValue;
  final double radius;

  _BorderShinePainter({required this.animationValue, required this.radius});

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
            begin: Alignment(-1.0 + (animationValue * 2), -1.0),
            end: Alignment(1.0 + (animationValue * 2), 1.0),
            colors: [
              Colors.transparent,
              AppColor.goldGradient.first.withOpacity(0.05),
              AppColor.goldGradient.first.withOpacity(0.65),
              AppColor.goldGradient.last.withOpacity(0.85),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.48, 0.55, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(rect, paint);

    final shinePosition = animationValue * (size.width + size.height) * 2;

    final perimeter = _getPerimeterPoint(size, shinePosition);

    final glowPaint =
        Paint()
          ..color = AppColor.goldGradient.last.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(perimeter, 2.0, glowPaint);
  }

  Offset _getPerimeterPoint(Size size, double position) {
    final width = size.width;
    final height = size.height;

    final perimeter = (width + height) * 2;

    final p = position % perimeter;

    if (p < width) {
      return Offset(p, 0);
    }

    if (p < width + height) {
      return Offset(width, p - width);
    }

    if (p < (width * 2) + height) {
      return Offset(width - (p - width - height), height);
    }

    return Offset(0, height - (p - (width * 2) - height));
  }

  @override
  bool shouldRepaint(covariant _BorderShinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.radius != radius;
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

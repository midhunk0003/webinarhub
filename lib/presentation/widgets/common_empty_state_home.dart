// ============================================================================
// WEBINAR EMPTY STATE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lottie/lottie.dart';

class WebinarEmptyState extends StatelessWidget {
  final String title;
  final String subTitle;

  /// Optional call-to-action, e.g. "Notify me" or "Browse recordings".
  final String? actionLabel;
  final VoidCallback? onAction;

  const WebinarEmptyState({
    super.key,
    required this.title,
    required this.subTitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final gold = AppColor.gold;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder:
          (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - t)),
              child: child,
            ),
          ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gold.withOpacity(0.10),
              Colors.white.withOpacity(0.03),
              Colors.white.withOpacity(0.02),
            ],
          ),
          border: Border.all(color: gold.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: gold.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft gold glow behind the animation
            Container(
              width: 140,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [gold.withOpacity(0.20), gold.withOpacity(0.0)],
                ),
              ),
              child: Lottie.asset(
                'assets/lottie/videocam_live.json',
                width: 112,
                height: 112,
                repeat: true,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) =>
                        Icon(Icons.videocam_outlined, size: 48, color: gold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: BorderSide(color: gold.withOpacity(0.7)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Usage:
// const WebinarEmptyState(
//   title: 'No live webinars right now',
//   subTitle: 'When a trainer goes live, it will show up here.',
// )
//
// With a button:
// WebinarEmptyState(
//   title: 'No live webinars right now',
//   subTitle: 'When a trainer goes live, it will show up here.',
//   actionLabel: 'Notify me',
//   onAction: () {},
// )

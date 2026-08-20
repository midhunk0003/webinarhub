import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CourseDetailShimmer extends StatelessWidget {
  final bool isTablet;

  const CourseDetailShimmer({super.key, required this.isTablet});

  Color get baseColor => const Color(0xFF252525);
  Color get highlightColor => const Color(0xFF3A3A3A);

  Widget _shimmerBox({double? width, double? height, double radius = 8}) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _textShimmer({
    required double width,
    double height = 16,
    double radius = 5,
  }) {
    return _shimmerBox(width: width, height: height, radius: radius);
  }

  Widget _appBarShimmer() {
    return Row(
      children: [
        _shimmerBox(
          width: isTablet ? 44 : 40,
          height: isTablet ? 44 : 40,
          radius: 12,
        ),

        const Spacer(),

        _shimmerBox(
          width: isTablet ? 44 : 40,
          height: isTablet ? 44 : 40,
          radius: 12,
        ),
      ],
    );
  }

  Widget _ratingShimmer() {
    return Row(
      children: [
        _shimmerBox(
          width: isTablet ? 120 : 100,
          height: isTablet ? 30 : 26,
          radius: 8,
        ),

        const SizedBox(width: 12),

        _textShimmer(width: isTablet ? 130 : 100, height: 16),
      ],
    );
  }

  Widget _languageCard() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 18 : 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _shimmerBox(
              width: isTablet ? 42 : 36,
              height: isTablet ? 42 : 36,
              radius: 10,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textShimmer(width: isTablet ? 70 : 60, height: 13),

                  const SizedBox(height: 7),

                  _textShimmer(width: isTablet ? 90 : 75, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webinarInfoCard({bool fullWidth = false}) {
    final card = Container(
      padding: EdgeInsets.all(isTablet ? 18 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _shimmerBox(
            width: isTablet ? 46 : 40,
            height: isTablet ? 46 : 40,
            radius: 10,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textShimmer(width: isTablet ? 70 : 55, height: 13),

                const SizedBox(height: 7),

                _textShimmer(width: isTablet ? 120 : 100, height: 17),
              ],
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return card;
    }

    return Expanded(child: card);
  }

  Widget _uploadCard() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(
              width: isTablet ? 48 : 42,
              height: isTablet ? 48 : 42,
              radius: 12,
            ),

            SizedBox(height: isTablet ? 16 : 12),

            _textShimmer(
              width: isTablet ? 120 : 100,
              height: isTablet ? 17 : 15,
            ),

            const SizedBox(height: 8),

            _textShimmer(width: isTablet ? 150 : 125, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _resourceCard() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _shimmerBox(
            width: isTablet ? 48 : 42,
            height: isTablet ? 48 : 42,
            radius: 10,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textShimmer(width: isTablet ? 190 : 160, height: 16),

                const SizedBox(height: 8),

                _textShimmer(width: isTablet ? 110 : 90, height: 13),
              ],
            ),
          ),

          _shimmerBox(
            width: isTablet ? 36 : 32,
            height: isTablet ? 36 : 32,
            radius: 8,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({double width = 150}) {
    return _textShimmer(
      width: isTablet ? width + 20 : width,
      height: isTablet ? 24 : 21,
      radius: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 30 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isTablet ? 80 : 66),

            // ================= APP BAR =================
            _appBarShimmer(),

            SizedBox(height: isTablet ? 35 : 30),

            // ================= COURSE TITLE =================
            _textShimmer(
              width: isTablet ? 320 : 260,
              height: isTablet ? 30 : 26,
              radius: 6,
            ),

            const SizedBox(height: 16),

            // ================= COURSE IMAGE =================
            _shimmerBox(
              width: double.infinity,
              height: isTablet ? 280 : 220,
              radius: 12,
            ),

            const SizedBox(height: 24),

            // ================= OVERVIEW =================
            _sectionTitle(width: 170),

            const SizedBox(height: 14),

            _textShimmer(width: double.infinity, height: 14),

            const SizedBox(height: 8),

            _textShimmer(width: double.infinity, height: 14),

            const SizedBox(height: 8),

            _textShimmer(width: isTablet ? 650 : 280, height: 14),

            const SizedBox(height: 8),

            _textShimmer(width: isTablet ? 580 : 250, height: 14),

            const SizedBox(height: 20),

            // ================= RATING =================
            _ratingShimmer(),

            const SizedBox(height: 24),

            // ================= LANGUAGE / TYPE =================
            Row(
              children: [
                _languageCard(),

                const SizedBox(width: 14),

                _languageCard(),
              ],
            ),

            const SizedBox(height: 24),

            // ================= WEBINAR SCHEDULE =================
            _sectionTitle(width: 190),

            const SizedBox(height: 14),

            Row(
              children: [
                _webinarInfoCard(),

                const SizedBox(width: 12),

                _webinarInfoCard(),
              ],
            ),

            const SizedBox(height: 12),

            _webinarInfoCard(fullWidth: true),

            // ================= COURSE CONTENT =================
            const SizedBox(height: 30),

            _sectionTitle(width: 160),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _uploadCard(),

                const SizedBox(width: 14),

                _uploadCard(),
              ],
            ),

            // ================= RESOURCES =================
            const SizedBox(height: 30),

            _sectionTitle(width: 120),

            const SizedBox(height: 14),

            _resourceCard(),

            const SizedBox(height: 10),

            _resourceCard(),

            const SizedBox(height: 10),

            _resourceCard(),

            const SizedBox(height: 36),

            // ================= JOIN BUTTON =================
            _shimmerBox(
              width: double.infinity,
              height: isTablet ? 58 : 52,
              radius: 12,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/upcomming_webinarcard_widget.dart';
import 'package:lms/presentation/widgets/common_empty_state_home.dart';

class WebinarList extends StatelessWidget {
  final UserDashboardProvider userDashboardProvider;

  const WebinarList({required this.userDashboardProvider, super.key});

  @override
  Widget build(BuildContext context) {
    final webinars =
        userDashboardProvider
            .userDashboardUpcommingAndRecentModel
            ?.data
            ?.assignedWebinars ??
        [];

    if (webinars.isEmpty) {
      return WebinarEmptyState(
        title: 'No Recent Webinars',
        subTitle: 'New webinars will appear here when available.',
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        physics: const BouncingScrollPhysics(),
        itemCount: webinars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final webinar = webinars[index];

          return WebinarTile(
            title: webinar.title ?? '',
            status: webinar.status ?? '',
            students: '0',
            startDateTime: webinar.startDate ?? '',
            recentWebinarId: webinar.webinarId?.toString() ?? '',
            isPaid: webinar.isPaid,
            price: webinar.price,
            paymentStatus: webinar.paymentStatus,
            thumbnailUrl: webinar.thumbnailUrl,
          );
        },
      ),
    );
  }
}

// ============================================================================
// WEBINAR TILE
// ============================================================================

class WebinarTile extends StatelessWidget {
  final String title;
  final String status;
  final String students;
  final String startDateTime;
  final String? recentWebinarId;

  final String? isPaid;
  final String? price;
  final String? paymentStatus;
  final String? thumbnailUrl;

  const WebinarTile({
    super.key,
    required this.title,
    required this.status,
    required this.students,
    required this.startDateTime,
    required this.recentWebinarId,
    required this.isPaid,
    required this.price,
    required this.paymentStatus,
    this.thumbnailUrl,
  });

  // ==========================================================================
  // PREMIUM
  // ==========================================================================

  bool get _isPremium {
    return isPaid?.trim().toLowerCase() == 'true';
  }

  // ==========================================================================
  // PAYMENT STATUS
  // ==========================================================================

  bool get _isPaymentPaid {
    return paymentStatus?.trim().toLowerCase() == 'paid';
  }

  // ==========================================================================
  // DATE TIME
  // ==========================================================================

  DateTime? get _dateTime {
    if (startDateTime.trim().isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(startDateTime).toLocal();
    } catch (_) {
      return null;
    }
  }

  String get _formattedDate {
    final date = _dateTime;

    if (date == null) {
      return '--';
    }

    return DateFormat('MMM d, yyyy').format(date);
  }

  String get _formattedTime {
    final date = _dateTime;

    if (date == null) {
      return '--';
    }

    return DateFormat('hh:mm a').format(date);
  }

  // ==========================================================================
  // PRICE
  // ==========================================================================

  String get _displayPrice {
    if (!_isPremium) {
      return 'Free';
    }

    final value = price?.trim();

    if (value == null || value.isEmpty) {
      return '₹0';
    }

    return value.startsWith('₹') ? value : '₹$value';
  }

  // ==========================================================================
  // PAID TAG
  // ==========================================================================

  Widget _buildPaidTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF16804A).withOpacity(.15)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16804A)),
          SizedBox(width: 4),
          Text(
            'Paid',
            style: TextStyle(
              color: Color(0xFF16804A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      splashColor: AppColor.gold.withOpacity(.08),
      highlightColor: AppColor.gold.withOpacity(.04),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/userwebinarcoursedetailpage',
          arguments: {'courseId': recentWebinarId},
        );
      },
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.borderGlassColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadow.withOpacity(.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================================
              // IMAGE
              // ===============================================================
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColor.borderGlassColor,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // -------------------------------------------------------
                      // THUMBNAIL
                      // -------------------------------------------------------
                      if (thumbnailUrl != null &&
                          thumbnailUrl!.trim().isNotEmpty)
                        Image.network(
                          ApiEndPoint.serverUrl + thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackImage();
                          },
                        )
                      else
                        _buildFallbackImage(),

                      // -------------------------------------------------------
                      // DARK OVERLAY
                      // -------------------------------------------------------
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(.05),
                              Colors.black.withOpacity(.30),
                            ],
                          ),
                        ),
                      ),

                      // -------------------------------------------------------
                      // PREMIUM / FREE
                      // -------------------------------------------------------
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isPremium
                                    ? const Color(0xffff8500)
                                    : const Color(0xff22a06b),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.12),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPremium
                                    ? Icons.workspace_premium_rounded
                                    : Icons.lock_open_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isPremium ? 'Premium' : 'Free',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // -------------------------------------------------------
                      // PAID TAG
                      // Only visible when paymentStatus == Paid
                      // -------------------------------------------------------
                      if (_isPremium && _isPaymentPaid)
                        Positioned(top: 8, right: 8, child: _buildPaidTag()),
                    ],
                  ),
                ),
              ),

              // ===============================================================
              // CONTENT
              // ===============================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------------
                      // TITLE
                      // -------------------------------------------------------
                      Text(
                        title.trim().isEmpty ? 'Untitled Webinar' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColor.ghostwhite,
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // -------------------------------------------------------
                      // DATE + TIME
                      // -------------------------------------------------------
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColor.primaryText,
                            size: 16,
                          ),
                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              _formattedDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColor.secondaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColor.primaryText,
                            size: 16,
                          ),
                          const SizedBox(width: 4),

                          Text(
                            _formattedTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColor.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // -------------------------------------------------------
                      // DIVIDER
                      // -------------------------------------------------------
                      const _DottedDivider(),

                      const SizedBox(height: 12),

                      // -------------------------------------------------------
                      // PRICE + ARROW
                      // -------------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // PRICE
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Price',
                                      style: TextStyle(
                                        color: Color(0xff858585),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _displayPrice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColor.ghostwhite,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ARROW
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColor.gold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FALLBACK IMAGE
  // ==========================================================================

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gold.withOpacity(.25),
            AppColor.gold.withOpacity(.08),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_collection_outlined,
          color: AppColor.gold,
          size: 42,
        ),
      ),
    );
  }
}

// ============================================================================
// DOTTED DIVIDER
// ============================================================================

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(45, (index) {
        return Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: const Color(0xffDDDDDD),
          ),
        );
      }),
    );
  }
}

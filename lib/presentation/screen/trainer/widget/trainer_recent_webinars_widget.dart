import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/screen/trainer/widget/trainer_upcomming_webinar.dart';
import 'package:lms/presentation/widgets/common_empty_state_home.dart';

// ============================================================================
// TRAINER WEBINAR LIST
// ============================================================================

class TrainerRecentWebinarsWidget extends StatelessWidget {
  final TrainerDashboardProvider trainerDashboardProvider;

  const TrainerRecentWebinarsWidget({
    required this.trainerDashboardProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final webinars =
        trainerDashboardProvider
            .trainerUpcommingAndAssignedModel
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
            status: _getStatusText(webinar.status),
            students: (webinar.enrolledCount ?? 0).toString(),
            startDateTime: webinar.startDateTime ?? '',
            recentWebinarId: webinar.id?.toString() ?? '',
            thumbnailUrl: webinar.thumbnailUrl,
          );
        },
      ),
    );
  }

  // Update these mappings if your backend uses different status IDs.
  String _getStatusText(dynamic status) {
    switch (status?.toString()) {
      case '1':
        return 'Scheduled';
      case '2':
        return 'Scheduled';
      case '3':
        return 'Live';
      case '4':
        return 'Completed';
      case '5':
        return 'Cancelled';
      default:
        return 'Scheduled';
    }
  }
}

// ============================================================================
// TRAINER WEBINAR TILE — SAME BLACK/GOLD USER DESIGN
// ============================================================================

class WebinarTile extends StatelessWidget {
  final String title;
  final String status;
  final String students;
  final String startDateTime;
  final String? recentWebinarId;
  final String? thumbnailUrl;

  const WebinarTile({
    super.key,
    required this.title,
    required this.status,
    required this.students,
    required this.startDateTime,
    required this.recentWebinarId,
    this.thumbnailUrl,
  });

  // ==========================================================================
  // DATE TIME
  // ==========================================================================

  DateTime? get _dateTime {
    if (startDateTime.trim().isEmpty) return null;

    try {
      return DateTime.parse(startDateTime).toLocal();
    } catch (_) {
      return null;
    }
  }

  String get _formattedDate {
    final date = _dateTime;
    if (date == null) return '--';

    return DateFormat('MMM d, yyyy').format(date);
  }

  String get _formattedTime {
    final date = _dateTime;
    if (date == null) return '--';

    return DateFormat('hh:mm a').format(date);
  }

  // ==========================================================================
  // STATUS COLOR
  // ==========================================================================

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.redAccent;
      case 'scheduled':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
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
        if (recentWebinarId == null || recentWebinarId!.isEmpty) return;

        Navigator.pushNamed(
          context,
          '/trainerwebinardetailpage',
          arguments: {
            // Pass the ID in the format expected by your trainer detail page.
            'courseId': recentWebinarId,
          },
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
              // ==============================================================
              // THUMBNAIL
              // ==============================================================
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
                      if (thumbnailUrl != null &&
                          thumbnailUrl!.trim().isNotEmpty)
                        Image.network(
                          _thumbnailImageUrl(thumbnailUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackImage(),
                        )
                      else
                        _buildFallbackImage(),

                      // Dark overlay
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

                      // Status badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor().withOpacity(.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==============================================================
              // CONTENT
              // ==============================================================
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
                      // Title
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

                      // Date and time
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
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColor.primaryText,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formattedTime,
                            style: const TextStyle(
                              color: AppColor.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const _DottedDivider(),

                      const SizedBox(height: 12),

                      // Student count and arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enrolled Students',
                                  style: TextStyle(
                                    color: Color(0xff858585),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline,
                                      color: AppColor.gold,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        students,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColor.ghostwhite,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
  // THUMBNAIL URL
  // ==========================================================================

  String _thumbnailImageUrl(String path) {
    final value = path.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final baseUrl = ApiEndPoint.serverUrl;

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
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

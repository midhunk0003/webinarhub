import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/animation/animation.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/services/generateZoomJwt.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/screen/trainer/widget/monthly_chart.dart';
import 'package:lms/presentation/screen/trainer/widget/trainer_recent_webinars_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'widget/trainer_upcomming_webinar.dart';

class TrainerHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;
  const TrainerHomeScreen({this.onViewAll, super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  bool _isDialogShowing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initialData();
    });
  }

  Future<void> _initialData() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userid');

    print('User ID: $userId');
    final dashprovider = context.read<TrainerDashboardProvider>();
    final webinarProvider = context.read<TrainerAllWebinarProvider>();
    await Future.wait([
      dashprovider.getDashUpcommingAndAssignPro(),
      dashprovider.getDashOverViewPro(),
      dashprovider.getProfilePro(),
      webinarProvider.getNotificationCountPro(),
    ]);
    if (!mounted) return;
    _handleFailure(dashprovider, webinarProvider);
  }

  void _handleFailure(
    TrainerDashboardProvider dashProvider,
    TrainerAllWebinarProvider webinarProvider,
  ) {
    if (!mounted || _isDialogShowing) return;

    final failures = <Failure>[
      if (dashProvider.failure != null &&
          dashProvider.failure is! NetworkFailure)
        dashProvider.failure!,

      if (webinarProvider.failure != null &&
          webinarProvider.failure is! NetworkFailure)
        webinarProvider.failure!,
    ];

    // No non-network failures
    if (failures.isEmpty) {
      return;
    }

    _isDialogShowing = true;

    AppDialogHelper.showFailureDialog(
      context: context,
      failure: failures.first,
      provider: dashProvider,
      onTap: () {
        dashProvider.clearFailure();
        webinarProvider.clearFailure();
        Navigator.pop(context);
      },
    );

    if (mounted) {
      _isDialogShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 700;
          return Consumer<TrainerDashboardProvider>(
            builder: (context, trainerDashProvider, _) {
              final failure =
                  trainerDashProvider.failure ?? trainerDashProvider.failure;
              if (failure is NetworkFailure) {
                return NetWorkRetry(
                  failureMessage: failure?.message ?? "No internet connection",
                  onRetry: () async {
                    await _initialData();
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await _initialData();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 66),
                      trainerDashProvider.isLoadingProfile
                          ? _buildShimmerHeader()
                          : HomeHeaderSectionWidget(
                            isTablet: isTablet,
                            title:
                                trainerDashProvider
                                    .profileModel
                                    ?.data
                                    ?.fullName,
                            subTitle:
                                trainerDashProvider.profileModel?.data?.email,
                            profileImageUrl:
                                trainerDashProvider
                                    .profileModel
                                    ?.data
                                    ?.profileImageUrl,
                            showNotificationIcon: true,
                            showProfileImage: true,
                          ),
                      const SizedBox(height: 25),
                      trainerDashProvider.isLoading
                          ? UpcomingWebinarCardShimmer()
                          : WebinarSectionEntrance(
                            delay: const Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                DashboardTitle(
                                  "Upcomming Webinars",
                                  true,
                                  widget.onViewAll,
                                ),
                                const SizedBox(height: 25),
                                UpcomingWebinarCard(
                                  trainerDashProvider: trainerDashProvider,
                                  isTablet: isTablet,
                                ),
                              ],
                            ),
                          ),
                      const SizedBox(height: 25),
                      trainerDashProvider.isLoading
                          ? WebinarShimmerList()
                          : WebinarSectionEntrance(
                            delay: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                DashboardTitle(
                                  "Recent Webinars",
                                  true,
                                  widget.onViewAll,
                                ),

                                const SizedBox(height: 15),
                                TrainerRecentWebinarsWidget(
                                  trainerDashboardProvider: trainerDashProvider,
                                ),
                              ],
                            ),
                          ),
                      const SizedBox(height: 25),
                      DashboardTitle("Overview", false, widget.onViewAll),
                      const SizedBox(height: 15),
                      trainerDashProvider.isLoadingOverView
                          ? _buildShimmerGrid()
                          : StatsGrid(
                            isTablet: isTablet,
                            trainerDashProvider: trainerDashProvider,
                          ),
                      const SizedBox(height: 25),
                      // DashboardchartTitleWidget(),
                      // const MonthlyBarChart(),
                      SizedBox(height: kBottomNavigationBarHeight + 100),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// class DashboardchartTitleWidget extends StatelessWidget {
//   const DashboardchartTitleWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Analytics",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               "Classes Overview",
//               style: TextStyle(color: Colors.white54, fontSize: 13),
//             ),
//           ],
//         ),
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white10,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.bar_chart_rounded, color: Colors.white),
//         ),
//       ],
//     );
//   }
// }

class DashboardTitle extends StatelessWidget {
  final String title;
  final bool viewall;
  final VoidCallback? onViewAll;
  const DashboardTitle(this.title, this.viewall, this.onViewAll, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
        viewall
            ? InkWell(
              onTap: () {
                onViewAll?.call(); // ✅ CALL the callback
              },
              child: Text(
                "View All",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
            : SizedBox.shrink(),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final TrainerDashboardProvider trainerDashProvider;
  final bool isTablet;

  const StatsGrid({
    super.key,
    required this.isTablet,
    required this.trainerDashProvider,
  });

  @override
  Widget build(BuildContext context) {
    final overview = trainerDashProvider.trainerOverViewModel;

    final items = [
      DashboardItem(
        overview?.data?.totalWebinars?.toString() ?? '0',
        'Total Webinars',
        Icons.video_collection_outlined,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.draftWebinars?.toString() ?? '0',
        'Draft Webinars',
        Icons.edit_outlined,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.publishedWebinars?.toString() ?? '0',
        'Published Webinars',
        Icons.check_circle_outline_rounded,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.upcomingWebinars?.toString() ?? '0',
        'Upcoming Webinars',
        Icons.schedule_rounded,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.completedWebinars?.toString() ?? '0',
        'Completed Webinars',
        Icons.task_alt_rounded,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.cancelledWebinars?.toString() ?? '0',
        'Cancelled Webinars',
        Icons.cancel_outlined,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.totalParticipants?.toString() ?? '0',
        'Total Participants',
        Icons.people_outline_rounded,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.materialsUploaded?.toString() ?? '0',
        'Materials Uploaded',
        Icons.folder_copy_outlined,
        AppColor.gold,
      ),
      DashboardItem(
        overview?.data?.notificationsSent?.toString() ?? '0',
        'Notifications Sent',
        Icons.notifications_active_outlined,
        AppColor.gold,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: isTablet ? 150 : 142,
      ),
      itemBuilder: (context, index) {
        return DashboardTile(item: items[index], animationIndex: index);
      },
    );
  }
}

class DashboardItem {
  final String value;
  final String title;
  final IconData icon;
  final Color color;

  const DashboardItem(this.value, this.title, this.icon, this.color);
}

class DashboardTile extends StatefulWidget {
  final DashboardItem item;
  final int animationIndex;

  const DashboardTile({
    super.key,
    required this.item,
    required this.animationIndex,
  });

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: 100 + (widget.animationIndex * 100)),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: _buildCard()),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF191919), Color(0xFF111111), Color(0xFF0B0B0B)],
        ),
        border: Border.all(color: AppColor.gold.withOpacity(0.20), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Top gold accent line.
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColor.gold.withOpacity(0.25),
                      AppColor.goldLight.withOpacity(0.60),
                      AppColor.gold.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gold accent line.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColor.gold.withOpacity(0.20),
                      AppColor.goldLight.withOpacity(0.35),
                      AppColor.gold.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon.
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B2418), Color(0xFF17130D)],
                      ),
                      border: Border.all(
                        color: AppColor.gold.withOpacity(0.28),
                      ),
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: AppColor.goldLight,
                      size: 22,
                    ),
                  ),

                  const Spacer(),

                  // Title.
                  Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Value with gold gradient.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                AppColor.goldLight,
                                AppColor.gold,
                                AppColor.goldDark,
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            widget.item.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: -0.7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: AppColor.gold.withOpacity(0.60),
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingWebinarCardShimmer extends StatelessWidget {
  const UpcomingWebinarCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 140, height: 16),

            const SizedBox(height: 12),

            _box(width: double.infinity, height: 26),

            const SizedBox(height: 8),

            _box(width: 180, height: 16),

            const SizedBox(height: 20),

            Row(
              children: [
                _box(width: 110, height: 42, radius: 8),

                const Spacer(),

                const CircleAvatar(radius: 12, backgroundColor: Colors.white),

                const SizedBox(width: 8),

                _box(width: 90, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width == double.infinity ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class WebinarShimmerList extends StatelessWidget {
  const WebinarShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const WebinarShimmerTile();
      },
    );
  }
}

class WebinarShimmerTile extends StatelessWidget {
  const WebinarShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              height: 18,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(height: 12),

            // Status
            Container(
              height: 14,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // Students
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                const Spacer(),

                // Date
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildShimmerGrid() {
  return GridView.builder(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 9,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
    ),
    itemBuilder: (_, index) {
      return _shimmerTile();
    },
  );
}

Widget _shimmerTile() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Spacer(),

          // Number placeholder
          Container(
            width: 65,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(height: 8),

          // Label placeholder
          Container(
            width: 90,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildShimmerHeader() {
  return Shimmer.fromColors(
    baseColor: Colors.white.withOpacity(0.08),
    highlightColor: Colors.white.withOpacity(0.20),
    child: Row(
      children: [
        // Profile image dummy
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        // Name + subtitle dummy
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Notification dummy
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

String _getStatusText(dynamic status) {
  if (status == null) {
    return 'Unknown';
  }

  final String value = status.toString();

  switch (value) {
    case '2':
      return 'Scheduled';

    case '3':
      return 'Live';

    case '4':
      return 'Completed';

    case '5':
      return 'Cancelled';

    default:
      return value.isEmpty ? 'Unknown' : value;
  }
}
// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final String text = status.trim().isEmpty ? 'Unknown' : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

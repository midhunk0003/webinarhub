import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/screen/trainer/widget/monthly_chart.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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
    await Future.wait([
      dashprovider.getDashUpcommingAndAssignPro(),
      dashprovider.getDashOverViewPro(),
    ]);
    if (!mounted) return;
    _handleFailure(dashprovider);
  }

  void _handleFailure(TrainerDashboardProvider dashProvider) {
    if (!mounted) return;

    final failure = dashProvider.failure;

    // Ignore network failure
    if (failure == null || failure is NetworkFailure) {
      return;
    }

    // Prevent multiple dialogs
    if (_isDialogShowing) {
      return;
    }

    _isDialogShowing = true;

    AppDialogHelper.showFailureDialog(
      context: context,
      failure: failure,
      provider: dashProvider,
      onTap: () {
        dashProvider.clearFailure();
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
              final failure = trainerDashProvider.failure;
              if (failure is NetworkFailure) {
                return NetWorkRetry(
                  failureMessage:
                      trainerDashProvider.failure?.message ??
                      "No internet connection",
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
                      HomeHeaderSectionWidget(
                        isTablet: isTablet,
                        title: "Hello Trainer 👋",
                        subTitle: "Manage your webinars easily",
                        showNotificationIcon: true,
                        showProfileImage: false,
                      ),
                      const SizedBox(height: 25),
                      DashboardTitle(
                        "Upcomming Webinars",
                        true,
                        widget.onViewAll,
                      ),
                      const SizedBox(height: 25),
                      trainerDashProvider.isLoading
                          ? UpcomingWebinarCardShimmer()
                          : UpcomingWebinarCard(
                            trainerDashProvider: trainerDashProvider,
                          ),
                      const SizedBox(height: 25),
                      DashboardTitle("Recent Webinars", true, widget.onViewAll),
                      const SizedBox(height: 15),
                      trainerDashProvider.isLoading
                          ? WebinarShimmerList()
                          : WebinarList(
                            trainerDashboardProvider: trainerDashProvider,
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

class UpcomingWebinarCard extends StatelessWidget {
  final TrainerDashboardProvider trainerDashProvider;
  const UpcomingWebinarCard({super.key, required this.trainerDashProvider});

  @override
  Widget build(BuildContext context) {
    final upcommingWebinars =
        trainerDashProvider
            .trainerUpcommingAndAssignedModel
            ?.data
            ?.upcomingWebinar;

    if (upcommingWebinars == null) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/trainerwebinardetailpage',
          arguments: {'courseId': upcommingWebinars.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.formPrimaryColor.withOpacity(0.24),
              AppColor.formSecondaryColor.withOpacity(0.24),
            ],
          ),
          border: Border.all(color: AppColor.formBorderColor.withOpacity(0.24)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Webinar",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 10),

            Text(
              "${trainerDashProvider.trainerUpcommingAndAssignedModel?.data?.upcomingWebinar?.title ?? 'N/A'}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              formatWebinarDate(
                trainerDashProvider
                    .trainerUpcommingAndAssignedModel
                    ?.data
                    ?.upcomingWebinar
                    ?.startDateTime,
                trainerDashProvider
                    .trainerUpcommingAndAssignedModel
                    ?.data
                    ?.upcomingWebinar
                    ?.endDateTime,
              ),
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await trainerDashProvider.launchZoomMeeting(
                      trainerDashProvider
                              .trainerUpcommingAndAssignedModel
                              ?.data
                              ?.upcomingWebinar!
                              .meetingUrl ??
                          '',
                    );
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text("Join"),
                ),

                const Spacer(),

                const Icon(Icons.people, color: Colors.white),

                const SizedBox(width: 8),

                InkWell(
                  onTap: () {
                    // Navigator.pushNamed(
                    //   context,
                    //   '/viewallparticipents',
                    //   arguments: {
                    //     'courseId':
                    //         trainerDashProvider
                    //             .trainerUpcommingAndAssignedModel
                    //             ?.data
                    //             ?.upcomingWebinar!
                    //             .id,
                    //   },
                    // );
                  },
                  child: Text(
                    "${trainerDashProvider.trainerUpcommingAndAssignedModel?.data?.upcomingWebinar?.enrolledCount} Students",
                    style: TextStyle(color: Colors.white),
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
        Colors.blue,
      ),
      DashboardItem(
        overview?.data?.draftWebinars?.toString() ?? '0',
        'Draft',
        Icons.edit_outlined,
        Colors.orange,
      ),
      DashboardItem(
        overview?.data?.publishedWebinars?.toString() ?? '0',
        'Published',
        Icons.check_circle_outline,
        Colors.green,
      ),
      DashboardItem(
        overview?.data?.upcomingWebinars?.toString() ?? '0',
        'Upcoming',
        Icons.schedule_outlined,
        Colors.purple,
      ),
      DashboardItem(
        overview?.data?.completedWebinars?.toString() ?? '0',
        'Completed',
        Icons.task_alt_outlined,
        Colors.teal,
      ),
      DashboardItem(
        overview?.data?.cancelledWebinars?.toString() ?? '0',
        'Cancelled',
        Icons.cancel_outlined,
        Colors.red,
      ),
      DashboardItem(
        overview?.data?.totalParticipants?.toString() ?? '0',
        'Students',
        Icons.people_outline,
        Colors.indigo,
      ),
      DashboardItem(
        overview?.data?.materialsUploaded?.toString() ?? '0',
        'Materials',
        Icons.folder_outlined,
        Colors.amber,
      ),
      DashboardItem(
        overview?.data?.notificationsSent?.toString() ?? '0',
        'Notifications',
        Icons.notifications_none,
        Colors.cyan,
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
        mainAxisExtent: isTablet ? 145 : 135,
      ),
      itemBuilder: (context, index) {
        return DashboardTile(item: items[index]);
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

class DashboardTile extends StatelessWidget {
  final DashboardItem item;

  const DashboardTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.22),
            AppColor.formSecondaryColor.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),

          const Spacer(),

          /// Value
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),

          const SizedBox(height: 7),

          /// Title
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class WebinarList extends StatelessWidget {
  final TrainerDashboardProvider trainerDashboardProvider;
  const WebinarList({required this.trainerDashboardProvider, super.key});
  @override
  Widget build(BuildContext context) {
    final webinars =
        trainerDashboardProvider
            .trainerUpcommingAndAssignedModel
            ?.data
            ?.assignedWebinars ??
        [];

    if (webinars.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: webinars.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return WebinarTile(
          title: webinars[index].title ?? '',
          status: webinars[index].status == '1' ? 'Published' : 'Draft',
          students: webinars[index].enrolledCount ?? '0',
          startDateTime: webinars[index].startDateTime ?? '',
          recentWebinarId: webinars[index].id.toString() ?? '',
        );
      },
    );
  }
}

class WebinarTile extends StatelessWidget {
  final String title;
  final String status;
  final String students;
  final String startDateTime;
  final String? recentWebinarId;

  const WebinarTile({
    super.key,
    required this.title,
    required this.status,
    required this.students,
    required this.startDateTime,
    required this.recentWebinarId,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(startDateTime).toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/trainerwebinardetailpage',
          arguments: {'courseId': recentWebinarId},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Row(
          children: [
            // Webinar icon
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.video_collection_outlined,
                color: Colors.blue,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  // Date and time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white54,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Icon(
                        Icons.access_time,
                        color: Colors.white54,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Students
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: Colors.white54,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$students Students',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
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

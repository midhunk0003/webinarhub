import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/screen/trainer/widget/monthly_chart.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/webinar_price_label.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class UserHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;
  const UserHomeScreen({this.onViewAll, super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ScrollController _privacyScrollController = ScrollController();
  bool _isPrivacyPolicyCompleted = false;
  bool _isPrivacyPolicyChecked = false;

  bool _isDialogShowing = false;
  @override
  void initState() {
    _privacyScrollController.addListener(_onScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initialData();
    });
  }

  void _onScroll() {
    if (_privacyScrollController.position.pixels >=
        _privacyScrollController.position.maxScrollExtent - 20) {
      if (!_isPrivacyPolicyCompleted) {
        setState(() {
          _isPrivacyPolicyCompleted = true;
        });
      }
    }
  }

  Future<void> _initialData() async {
    if (!mounted) return;
    final dashprovider = context.read<UserDashboardProvider>();

    final webinarProvider = context.read<TrainerAllWebinarProvider>();

    // Load privacy policy status first
    await dashprovider.loadPolicyAcceptanceStatus();

    if (!mounted) return;

    await Future.wait([
      dashprovider.getUserDashUpcommingAndAssignPro(),
      dashprovider.getUserDashOverViewPro(),
      dashprovider.getProfilePro(),
      dashprovider.getUserPolicyAndAgreePro(), // ✅ ADD THIS
      webinarProvider.getNotificationCountPro(),
    ]);
    if (!mounted) return;
    _handleFailure(dashprovider, webinarProvider);
  }

  void _handleFailure(
    UserDashboardProvider dashProvider,
    TrainerAllWebinarProvider webinarProvider,
  ) {
    if (!mounted) return;

    final failures = <Failure>[
      if (dashProvider.failure != null) dashProvider.failure!,
      if (webinarProvider.failure != null) webinarProvider.failure!,
    ];
    // IMPORTANT:
    // If there are no failures, do nothing.
    // This prevents:
    // Bad state: No element
    // caused by failures.first
    if (failures.isEmpty) {
      return;
    }
    // Ignore network failure
    if (failures == null || failures is NetworkFailure) {
      return;
    }

    // Prevent multiple dialogs
    if (_isDialogShowing) {
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
  void dispose() {
    _privacyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 700;
          return Consumer2<UserDashboardProvider, TrainerAllWebinarProvider>(
            builder: (context, userDashboardProvider, webinarProvider, _) {
              final failure =
                  userDashboardProvider.failure ?? webinarProvider.failure;
              if (failure is NetworkFailure) {
                return NetWorkRetry(
                  failureMessage: failure.message ?? "No internet connection",
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
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 66),
                          userDashboardProvider.isLoadingProfile
                              ? _buildShimmerHeader()
                              : HomeHeaderSectionWidget(
                                isTablet: isTablet,
                                title:
                                    userDashboardProvider
                                        .profileModel
                                        ?.data
                                        ?.fullName,
                                subTitle:
                                    userDashboardProvider
                                        .profileModel
                                        ?.data
                                        ?.email,
                                profileImageUrl:
                                    userDashboardProvider
                                        .profileModel
                                        ?.data
                                        ?.profileImageUrl,
                                showNotificationIcon: true,
                                showProfileImage: true,
                              ),
                          const SizedBox(height: 25),
                          DashboardTitle(
                            "Upcomming Webinars",
                            true,
                            widget.onViewAll,
                          ),
                          const SizedBox(height: 25),
                          userDashboardProvider.isLoading
                              ? UpcomingWebinarCardShimmer()
                              : UpcomingWebinarCard(
                                userDashboardProvider: userDashboardProvider,
                                isTablet: isTablet,
                              ),
                          const SizedBox(height: 25),
                          DashboardTitle(
                            "Recent Webinars",
                            true,
                            widget.onViewAll,
                          ),
                          const SizedBox(height: 15),
                          userDashboardProvider.isLoading
                              ? WebinarShimmerList()
                              : WebinarList(
                                userDashboardProvider: userDashboardProvider,
                              ),
                          const SizedBox(height: 25),
                          DashboardTitle("Overview", false, widget.onViewAll),
                          const SizedBox(height: 15),
                          userDashboardProvider.isLoadingOverView
                              ? _buildShimmerGrid()
                              : StatsGrid(
                                isTablet: isTablet,
                                userDashboardProvider: userDashboardProvider,
                              ),
                          const SizedBox(height: 25),
                          // DashboardchartTitleWidget(),
                          // const MonthlyBarChart(),
                          SizedBox(height: kBottomNavigationBarHeight + 100),
                        ],
                      ),

                      if (userDashboardProvider.requiresPolicyAcceptance)
                        Positioned(
                          top: 150,
                          left: 0,
                          right: 0,
                          child: _buildPrivacyPolicy(
                            isTablet,
                            userDashboardProvider,
                          ),
                        ),
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
  // Add these variables inside your State class

  Widget _buildPrivacyPolicy(bool isTablet, UserDashboardProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final policyModel = provider.userPolicyAndAgreeModel;
    final policies = policyModel?.data ?? [];

    return Center(
      child: Container(
        width: screenWidth > 700 ? 600 : screenWidth * 0.92,
        height: screenHeight > 700 ? 600 : screenHeight * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            const Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Please read the privacy policy carefully.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 15),

            // ============================================================
            // POLICY LIST
            // ============================================================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child:
                    policies.isEmpty
                        ? const Center(
                          child: Text(
                            "Privacy policy content is not available.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        )
                        : Scrollbar(
                          controller: _privacyScrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _privacyScrollController,
                            padding: const EdgeInsets.only(
                              right: 12,
                              bottom: 20,
                            ),
                            itemCount: policies.length,
                            itemBuilder: (context, index) {
                              final policy = policies[index];

                              final title = (policy.title ?? '').trim();

                              final content = (policy.content ?? '').trim();

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < policies.length - 1 ? 20 : 0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ==================================================
                                    // TITLE
                                    // ==================================================
                                    if (title.isNotEmpty)
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),

                                    if (title.isNotEmpty && content.isNotEmpty)
                                      const SizedBox(height: 10),

                                    // ==================================================
                                    // CONTENT
                                    // ==================================================
                                    if (content.isNotEmpty)
                                      Text(
                                        content,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.6,
                                          color: Colors.black87,
                                        ),
                                      ),

                                    // ==================================================
                                    // DIVIDER
                                    // ==================================================
                                    if (index < policies.length - 1)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Divider(
                                          color: Colors.grey.shade300,
                                          height: 1,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 12),

            // ============================================================
            // SCROLL MESSAGE
            // ============================================================
            if (!_isPrivacyPolicyCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Please scroll to the bottom to continue.",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ============================================================
            // CHECKBOX
            // ============================================================
            if (_isPrivacyPolicyCompleted)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _isPrivacyPolicyChecked,
                onChanged: (value) {
                  setState(() {
                    _isPrivacyPolicyChecked = value ?? false;
                  });
                },
                title: const Text(
                  "I have read and agree to the Privacy Policy",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

            // ============================================================
            // AGREE BUTTON
            // ============================================================
            if (_isPrivacyPolicyChecked)
              CommonCustomeButtonWidget(
                isTablet: isTablet,
                text: provider.isLoadingAccept ? "loading...." : "Agree",
                onTap: () async {
                  final policyIds =
                      policies
                          .map((policy) => int.tryParse(policy.id.toString()))
                          .whereType<int>()
                          .toList();
                  debugPrint('Policy IDs....: $policyIds');
                  try {
                    await provider.acceptPrivacyPolicyPro(policyIds);

                    if (!mounted) return;
                    if (provider.failure != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.failure?.message ??
                                'Unable to accept privacy policy.',
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _isPrivacyPolicyCompleted = false;
                      _isPrivacyPolicyChecked = false;
                    });
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to save your preference. Please try again.',
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
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
              child: Row(
                children: [
                  Text(
                    "View All",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            )
            : SizedBox.shrink(),
      ],
    );
  }
}

class UpcomingWebinarCard extends StatefulWidget {
  final UserDashboardProvider userDashboardProvider;
  final bool isTablet;

  const UpcomingWebinarCard({
    super.key,
    required this.userDashboardProvider,
    required this.isTablet,
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

    // One continuous controller for all card animations.
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
    final upcommingWebinars =
        widget
            .userDashboardProvider
            .userDashboardUpcommingAndRecentModel
            ?.data
            ?.upcomingWebinar;

    if (upcommingWebinars == null) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/userwebinarcoursedetailpage',
          arguments: {'courseId': upcommingWebinars.webinarId},
        );
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final value = _animationController.value;

          // Smooth sine wave for breathing animations.
          final breathe = (math.sin(value * math.pi * 2) + 1) / 2;

          // Faster pulse.
          final pulse = (math.sin(value * math.pi * 4) + 1) / 2;

          return Transform.translate(
            offset: Offset(0, -0.7 * breathe),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ============================================================
                // 1. SOFT OUTER GLOW
                // ============================================================
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
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
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        // ====================================================
                        // MAIN CARD
                        // ====================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.formPrimaryColor.withOpacity(0.24),
                                AppColor.formSecondaryColor.withOpacity(0.24),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColor.formBorderColor.withOpacity(0.24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // ==============================================
                              // 2. GOLDEN PARTICLES
                              // ==============================================
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _GoldenParticlesPainter(
                                      animationValue: value,
                                    ),
                                  ),
                                ),
                              ),

                              // ==============================================
                              // CONTENT
                              // ==============================================
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ==========================================
                                  // 3. UPCOMING WEBINAR INDICATOR
                                  // ==========================================
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Outer pulsing ring
                                      Container(
                                        width: 14 + (pulse * 4),
                                        height: 14 + (pulse * 4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColor.goldGradient.first
                                              .withOpacity(
                                                0.08 + (pulse * 0.10),
                                              ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 6 + (pulse * 2),
                                            height: 6 + (pulse * 2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  AppColor.goldGradient.first,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColor
                                                      .goldGradient
                                                      .first
                                                      .withOpacity(
                                                        0.5 + (pulse * 0.5),
                                                      ),
                                                  blurRadius: 4 + (pulse * 5),
                                                  spreadRadius: pulse * 1.5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Animated heading
                                      Transform.translate(
                                        offset: Offset(0, -1.2 * pulse),
                                        child: Opacity(
                                          opacity: 0.65 + (pulse * 0.35),
                                          child: const Text(
                                            "Upcoming Webinar",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Urbanist',
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 7),

                                      // Small blinking dot
                                      Opacity(
                                        opacity: 0.2 + ((1 - pulse) * 0.8),
                                        child: Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.goldGradient.last,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // ==========================================
                                  // 4. WEBINAR TITLE
                                  // ==========================================
                                  Transform.scale(
                                    scale: 1.0 + (breathe * 0.008),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      upcommingWebinars.title ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        fontFamily: 'Urbanist',
                                        shadows: [
                                          Shadow(
                                            color: AppColor.goldGradient.first
                                                .withOpacity(
                                                  0.05 + (breathe * 0.20),
                                                ),
                                            blurRadius: 3 + (breathe * 5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // ==========================================
                                  // DATE
                                  // ==========================================
                                  Text(
                                    formatWebinarDate(
                                      upcommingWebinars.startDate,
                                      upcommingWebinars.endDate,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ==========================================
                                  // JOIN + PRICE
                                  // ==========================================
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CommonCustomeButtonWidget(
                                          isTablet: widget.isTablet,
                                          text: "Join",
                                          icon: null,
                                          lotty: true,
                                          onTap: () async {
                                            Navigator.pushNamed(
                                              context,
                                              '/userwebinarcoursedetailpage',
                                              arguments: {
                                                'courseId':
                                                    upcommingWebinars.webinarId,
                                              },
                                            );
                                            // try {
                                            //   await widget.userDashboardProvider
                                            //       .userJoinDataPro(
                                            //         upcommingWebinars.webinarId,
                                            //         '2',
                                            //       );

                                            //   if (widget
                                            //           .userDashboardProvider
                                            //           .userJoinWebinarModel !=
                                            //       null) {
                                            //     final meetingUrl =
                                            //         upcommingWebinars
                                            //             .meetingUrl ??
                                            //         '';

                                            //     if (meetingUrl.isEmpty) {
                                            //       if (!context.mounted) {
                                            //         return;
                                            //       }

                                            //       ScaffoldMessenger.of(
                                            //         context,
                                            //       ).showSnackBar(
                                            //         const SnackBar(
                                            //           content: Text(
                                            //             'Unable to open the webinar. Meeting link not found.',
                                            //           ),
                                            //         ),
                                            //       );

                                            //       return;
                                            //     }

                                            //     await widget
                                            //         .userDashboardProvider
                                            //         .launchZoomMeeting(
                                            //           meetingUrl,
                                            //         );
                                            //   } else if (widget
                                            //           .userDashboardProvider
                                            //           .failure !=
                                            //       null) {
                                            //     if (!context.mounted) {
                                            //       return;
                                            //     }

                                            //     AppDialogHelper.showFailureDialog(
                                            //       context: context,
                                            //       failure:
                                            //           widget
                                            //               .userDashboardProvider
                                            //               .failure,
                                            //       provider:
                                            //           widget
                                            //               .userDashboardProvider,
                                            //       onTap: () {
                                            //         widget.userDashboardProvider
                                            //             .clearFailure();

                                            //         Navigator.pop(context);
                                            //       },
                                            //     );
                                            //   } else {
                                            //     if (!context.mounted) {
                                            //       return;
                                            //     }

                                            //     ScaffoldMessenger.of(
                                            //       context,
                                            //     ).showSnackBar(
                                            //       const SnackBar(
                                            //         content: Text(
                                            //           'Something went wrong. Please try again.',
                                            //         ),
                                            //       ),
                                            //     );
                                            //   }
                                            // } catch (e) {
                                            //   if (!context.mounted) {
                                            //     return;
                                            //   }

                                            //   ScaffoldMessenger.of(
                                            //     context,
                                            //   ).showSnackBar(
                                            //     const SnackBar(
                                            //       content: Text(
                                            //         'Unable to join the webinar. Please try again.',
                                            //       ),
                                            //     ),
                                            //   );

                                            //   debugPrint(
                                            //     'Join webinar error: $e',
                                            //   );
                                            // }
                                          },
                                        ),
                                      ),

                                      const Spacer(),

                                      // ======================================
                                      // 5. ANIMATED PRICE
                                      // ======================================
                                      Transform.scale(
                                        scale: 1.0 + (pulse * 0.035),
                                        child: Opacity(
                                          opacity: 0.82 + (pulse * 0.18),
                                          child: webinarPriceLabel(
                                            isPaid: upcommingWebinars.isPaid,
                                            price: upcommingWebinars.price,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ====================================================
                        // 6. MOVING GOLDEN BORDER SHINE
                        // ====================================================
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _BorderShinePainter(
                                animationValue: value,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// GOLDEN PARTICLES
// ============================================================================

class _GoldenParticlesPainter extends CustomPainter {
  final double animationValue;

  _GoldenParticlesPainter({required this.animationValue});

  final List<_Particle> particles = const [
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
      // Different particles blink at different times.
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

      // Small bright center
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

class _Particle {
  final double x;
  final double y;
  final double size;
  final double delay;

  const _Particle(this.x, this.y, this.size, this.delay);
}

// ============================================================================
// MOVING GOLDEN BORDER SHINE
// ============================================================================

class _BorderShinePainter extends CustomPainter {
  final double animationValue;

  _BorderShinePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
      const Radius.circular(14),
    );

    // Animated position around the perimeter.
    final shinePosition = animationValue * (size.width + size.height) * 2;

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

    // Very subtle moving point of light.
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
      // Top
      return Offset(p, 0);
    }

    if (p < width + height) {
      // Right
      return Offset(width, p - width);
    }

    if (p < (width * 2) + height) {
      // Bottom
      return Offset(width - (p - width - height), height);
    }

    // Left
    return Offset(0, height - (p - (width * 2) - height));
  }

  @override
  bool shouldRepaint(covariant _BorderShinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// old normal card
// class UpcomingWebinarCard extends StatelessWidget {
//   final UserDashboardProvider userDashboardProvider;
//   final bool isTablet;
//   const UpcomingWebinarCard({
//     super.key,
//     required this.userDashboardProvider,
//     required this.isTablet,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final upcommingWebinars =
//         userDashboardProvider
//             .userDashboardUpcommingAndRecentModel
//             ?.data
//             ?.upcomingWebinar;

//     if (upcommingWebinars == null) {
//       return const SizedBox.shrink();
//     }
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           '/userwebinarcoursedetailpage',
//           arguments: {'courseId': upcommingWebinars.webinarId},
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AppColor.formPrimaryColor.withOpacity(0.24),
//               AppColor.formSecondaryColor.withOpacity(0.24),
//             ],
//           ),
//           border: Border.all(color: AppColor.formBorderColor.withOpacity(0.24)),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               offset: const Offset(0, 2),
//               blurRadius: 4,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Upcoming Webinar",
//               style: TextStyle(color: Colors.white70),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               "${userDashboardProvider.userDashboardUpcommingAndRecentModel?.data?.upcomingWebinar?.title ?? 'N/A'}",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 22,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               formatWebinarDate(
//                 userDashboardProvider
//                     .userDashboardUpcommingAndRecentModel
//                     ?.data
//                     ?.upcomingWebinar
//                     ?.startDate,
//                 userDashboardProvider
//                     .userDashboardUpcommingAndRecentModel
//                     ?.data
//                     ?.upcomingWebinar
//                     ?.endDate,
//               ),
//               style: const TextStyle(color: Colors.white70),
//             ),

//             const SizedBox(height: 20),

//             Row(
//               children: [
//                 // ElevatedButton.icon(
//                 //   onPressed: () async {
//                 //     // await userDashboardProvider.launchZoomMeeting(
//                 //     //   userDashboardProvider
//                 //     //           .userDashboardUpcommingAndRecentModel
//                 //     //           ?.data
//                 //     //           ?.upcomingWebinar!
//                 //     //           .meetingUrl ??
//                 //     //       '',
//                 //     // );

//                 //     // try {
//                 //     //   await userDashboardProvider.userJoinDataPro(
//                 //     //     userDashboardProvider
//                 //     //         .userDashboardUpcommingAndRecentModel
//                 //     //         ?.data
//                 //     //         ?.upcomingWebinar
//                 //     //         ?.webinarId,
//                 //     //   );

//                 //     //   if (userDashboardProvider.userJoinWebinarModel != null) {
//                 //     //     final meetingUrl =
//                 //     //         userDashboardProvider
//                 //     //             .userDashboardUpcommingAndRecentModel
//                 //     //             ?.data
//                 //     //             ?.upcomingWebinar
//                 //     //             ?.meetingUrl ??
//                 //     //         '';
//                 //     //     if (meetingUrl.isEmpty) {
//                 //     //       ScaffoldMessenger.of(context).showSnackBar(
//                 //     //         const SnackBar(
//                 //     //           content: Text(
//                 //     //             'Unable to open the webinar. Meeting link not found.',
//                 //     //           ),
//                 //     //         ),
//                 //     //       );
//                 //     //       return;
//                 //     //     }

//                 //     //     await userDashboardProvider.launchZoomMeeting(
//                 //     //       meetingUrl,
//                 //     //     );
//                 //     //   } else if (userDashboardProvider.failure != null) {
//                 //     //     AppDialogHelper.showFailureDialog(
//                 //     //       context: context,
//                 //     //       failure: userDashboardProvider.failure,
//                 //     //       provider: userDashboardProvider,
//                 //     //       onTap: () {
//                 //     //         userDashboardProvider.clearFailure();
//                 //     //         Navigator.pop(context);
//                 //     //       },
//                 //     //     );
//                 //     //   } else {
//                 //     //     ScaffoldMessenger.of(context).showSnackBar(
//                 //     //       const SnackBar(
//                 //     //         content: Text(
//                 //     //           'Something went wrong. Please try again..............',
//                 //     //         ),
//                 //     //       ),
//                 //     //     );
//                 //     //   }
//                 //     // } catch (e) {
//                 //     //   ScaffoldMessenger.of(context).showSnackBar(
//                 //     //     const SnackBar(
//                 //     //       content: Text(
//                 //     //         'Unable to join the webinar. Please try again.',
//                 //     //       ),
//                 //     //     ),
//                 //     //   );

//                 //     //   debugPrint('Join webinar error: $e');
//                 //     // }
//                 //   },
//                 //   icon: const Icon(Icons.video_call),
//                 //   label: const Text("Join"),
//                 // ),
//                 Expanded(
//                   child: CommonCustomeButtonWidget(
//                     isTablet: isTablet,
//                     text: "Join",
//                     icon: Icons.video_call,
//                     onTap: () async {
//                       try {
//                         await userDashboardProvider.userJoinDataPro(
//                           userDashboardProvider
//                               .userDashboardUpcommingAndRecentModel
//                               ?.data
//                               ?.upcomingWebinar
//                               ?.webinarId,
//                         );

//                         if (userDashboardProvider.userJoinWebinarModel !=
//                             null) {
//                           final meetingUrl =
//                               userDashboardProvider
//                                   .userDashboardUpcommingAndRecentModel
//                                   ?.data
//                                   ?.upcomingWebinar
//                                   ?.meetingUrl ??
//                               '';
//                           if (meetingUrl.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Unable to open the webinar. Meeting link not found.',
//                                 ),
//                               ),
//                             );
//                             return;
//                           }

//                           await userDashboardProvider.launchZoomMeeting(
//                             meetingUrl,
//                           );
//                         } else if (userDashboardProvider.failure != null) {
//                           AppDialogHelper.showFailureDialog(
//                             context: context,
//                             failure: userDashboardProvider.failure,
//                             provider: userDashboardProvider,
//                             onTap: () {
//                               userDashboardProvider.clearFailure();
//                               Navigator.pop(context);
//                             },
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                 'Something went wrong. Please try again..............',
//                               ),
//                             ),
//                           );
//                         }
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Unable to join the webinar. Please try again.',
//                             ),
//                           ),
//                         );

//                         debugPrint('Join webinar error: $e');
//                       }
//                     },
//                   ),
//                 ),

//                 const Spacer(),

//                 // const Icon(Icons.price_change, color: Colors.white),

//                 // const SizedBox(width: 8),
//                 webinarPriceLabel(
//                   isPaid: upcommingWebinars.isPaid,
//                   price: upcommingWebinars.price,
//                 ),
//                 // InkWell(
//                 //   onTap: () {
//                 //     // Navigator.pushNamed(
//                 //     //   context,
//                 //     //   '/viewallparticipents',
//                 //     //   arguments: {
//                 //     //     'courseId':
//                 //     //         userDashboardProvider
//                 //     //             .trainerUpcommingAndAssignedModel
//                 //     //             ?.data
//                 //     //             ?.upcomingWebinar!
//                 //     //             .id,
//                 //     //   },
//                 //     // );
//                 //   },
//                 //   child: Text(
//                 //     "${userDashboardProvider.userDashboardUpcommingAndRecentModel?.data?.upcomingWebinar?.price}",
//                 //     style: TextStyle(color: Colors.white),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class StatsGrid extends StatelessWidget {
  final UserDashboardProvider userDashboardProvider;
  final bool isTablet;

  const StatsGrid({
    super.key,
    required this.isTablet,
    required this.userDashboardProvider,
  });

  @override
  Widget build(BuildContext context) {
    final overview = userDashboardProvider.userOverViewModel;

    final items = [
      DashboardItem(
        overview?.data?.upcomingWebinarsCount?.toString() ?? '0',
        'Upcoming Webinars',
        Icons.video_camera_front_rounded,
        AppColor.gold,
      ),

      DashboardItem(
        overview?.data?.pastWebinarsCount?.toString() ?? '0',
        'Past Webinars',
        Icons.history_rounded,
        AppColor.gold,
      ),

      DashboardItem(
        overview?.data?.totalMaterialsAvailable?.toString() ?? '0',
        'Materials Available',
        Icons.folder_copy_rounded,
        AppColor.gold,
      ),

      DashboardItem(
        overview?.data?.unreadNotificationsCount?.toString() ?? '0',
        'Unread Notifications',
        Icons.notifications_active_rounded,
        AppColor.gold,
      ),

      DashboardItem(
        overview?.data?.totalSuccessfulPayments?.toString() ?? '0',
        'Successful Payments',
        Icons.account_balance_wallet_rounded,
        AppColor.gold,
      ),

      DashboardItem(
        '₹${overview?.data?.totalAmountSpent?.toString() ?? '0'}',
        'Total Amount Spent',
        Icons.currency_rupee_rounded,
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

class DashboardTile extends StatefulWidget {
  final DashboardItem item;

  const DashboardTile({super.key, required this.item});

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool get isUpcomingWebinar => widget.item.title == 'Upcoming Webinars';

  @override
  void initState() {
    super.initState();

    // Only animate Upcoming Webinars
    if (isUpcomingWebinar) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);

      _glowAnimation = Tween<double>(
        begin: 0.10,
        end: 0.35,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _scaleAnimation = Tween<double>(
        begin: 0.96,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _opacityAnimation = Tween<double>(
        begin: 0.35,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    if (isUpcomingWebinar) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isUpcomingWebinar) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _buildCard(
            glow: _glowAnimation.value,
            scale: _scaleAnimation.value,
            pulse: _opacityAnimation.value,
          );
        },
      );
    }

    // Other cards are completely static
    return _buildCard(glow: 0.0, scale: 1.0, pulse: 1.0);
  }

  Widget _buildCard({
    required double glow,
    required double scale,
    required double pulse,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        // ============================================================
        // PREMIUM BLACK BACKGROUND
        // ============================================================
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF191919), Color(0xFF111111), Color(0xFF0B0B0B)],
        ),

        // ============================================================
        // GOLD BORDER
        // ============================================================
        border: Border.all(
          color: AppColor.gold.withOpacity(
            isUpcomingWebinar ? 0.20 + (glow * 0.35) : 0.20,
          ),
          width: 1,
        ),

        // ============================================================
        // SHADOW
        // ============================================================
        boxShadow: [
          if (isUpcomingWebinar)
            BoxShadow(
              color: AppColor.gold.withOpacity(glow * 0.18),
              blurRadius: 24,
              spreadRadius: 1,
            ),

          const BoxShadow(
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
            // ==========================================================
            // ANIMATED GOLD GLOW
            // ONLY UPCOMING WEBINAR
            // ==========================================================
            if (isUpcomingWebinar)
              Positioned(
                right: -35,
                top: -35,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColor.gold.withOpacity(glow * 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ==========================================================
            // TOP GOLD LINE
            // ==========================================================
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

            // ==========================================================
            // BOTTOM GOLD LINE
            // ==========================================================
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
                      AppColor.goldLight.withOpacity(
                        isUpcomingWebinar ? 0.35 + (glow * 0.35) : 0.35,
                      ),
                      AppColor.gold.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================================
            // CONTENT
            // ==========================================================
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // TOP ROW
                  // ======================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------------------------------------------------
                      // ICON
                      // --------------------------------------------------
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

                          boxShadow: [
                            if (isUpcomingWebinar)
                              BoxShadow(
                                color: AppColor.gold.withOpacity(glow * 0.18),
                                blurRadius: 12,
                              ),
                          ],
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: AppColor.goldLight,
                          size: 22,
                        ),
                      ),

                      const Spacer(),

                      // ==================================================
                      // LIVE BADGE
                      // ONLY UPCOMING WEBINAR
                      // ==================================================
                      if (isUpcomingWebinar)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: pulse,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.gold.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColor.gold.withOpacity(0.20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColor.goldLight,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.gold.withOpacity(
                                          pulse * 0.8,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 5),

                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: AppColor.goldLight,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  // ======================================================
                  // TITLE
                  // ======================================================
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

                  const SizedBox(height: 5),

                  // ======================================================
                  // VALUE
                  // ======================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
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
          status: _getStatusText(webinars[index].status),
          students: '0',
          startDateTime: webinars[index].startDate ?? '',
          recentWebinarId: webinars[index].webinarId.toString() ?? '',
          isPaid: webinars[index].isPaid,
          price: webinars[index].price,
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
  final String? isPaid;
  final String? price;

  const WebinarTile({
    super.key,
    required this.title,
    required this.status,
    required this.students,
    required this.startDateTime,
    required this.recentWebinarId,
    required this.isPaid,
    required this.price,
  });
  // ============================================================
  // STATUS COLOR
  // ============================================================

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

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(startDateTime).toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/userwebinarcoursedetailpage',
          arguments: {'courseId': recentWebinarId},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.gold.withOpacity(.14)),
        ),
        child: Row(
          children: [
            // Webinar icon
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColor.gold.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.video_collection_outlined,
                color: AppColor.gold,
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

                      _StatusBadge(status: status, color: _statusColor()),
                      // Status
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.green.withOpacity(.12),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Text(
                      //     status,
                      //     style: const TextStyle(
                      //       color: Colors.greenAccent,
                      //       fontSize: 11,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
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

                  // price
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: Colors.white54,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      webinarPriceLabel(isPaid: isPaid, price: price),
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

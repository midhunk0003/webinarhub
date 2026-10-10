import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:lms/animation/animation.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/recent_webinars_widget.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/upcomming_webinarcard_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:provider/provider.dart';
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
                color: AppColor.gold,
                backgroundColor: AppColor.background,
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
                          userDashboardProvider.isLoading
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
                                      userDashboardProvider:
                                          userDashboardProvider,
                                      isTablet: isTablet,
                                    ),
                                  ],
                                ),
                              ),

                          const SizedBox(height: 25),
                          userDashboardProvider.isLoading
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
                                    WebinarList(
                                      userDashboardProvider:
                                          userDashboardProvider,
                                    ),
                                  ],
                                ),
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
                                      HtmlWidget(
                                        content,
                                        textStyle: const TextStyle(
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

  bool get isUpcomingWebinar => widget.item.title == 'Upcoming Webinars';

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

    // Stagger the cards.
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
            // Top gold line
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

            // Bottom gold line
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      if (isUpcomingWebinar)
                        Container(
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
                    ],
                  ),

                  const SizedBox(height: 11),

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

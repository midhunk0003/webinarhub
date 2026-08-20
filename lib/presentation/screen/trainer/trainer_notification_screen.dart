import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/notification_model/notification_model.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class TrainerNotificationScreen extends StatefulWidget {
  const TrainerNotificationScreen({super.key});

  @override
  State<TrainerNotificationScreen> createState() =>
      _TrainerNotificationScreenState();
}

class _TrainerNotificationScreenState extends State<TrainerNotificationScreen> {
  int _selectedTab = 0;

  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    final provider = context.read<TrainerAllWebinarProvider>();

    String? isRead;

    switch (_selectedTab) {
      case 0:
        // All
        isRead = null;
        break;

      case 1:
        // Unread
        isRead = 'false';
        break;

      case 2:
        // Read
        isRead = 'true';
        break;
    }

    await provider.getAllNotification(isRead);

    if (!mounted) return;

    if (provider.failure != null && provider.failure is! NetworkFailure) {
      await _handleFailure(provider);
    }
  }

  // ============================================================
  // FAILURE DIALOG
  // ============================================================

  Future<void> _handleFailure(TrainerAllWebinarProvider provider) async {
    if (!mounted) return;

    final failure = provider.failure;

    if (failure == null || failure is NetworkFailure) {
      return;
    }

    if (_isDialogShowing) {
      return;
    }

    _isDialogShowing = true;

    try {
      AppDialogHelper.showFailureDialog(
        context: context,
        failure: failure,
        provider: provider,
        onTap: () {
          provider.clearFailure();

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _onTabChanged(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
    });

    _loadNotifications();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadNotifications();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 600;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColor.formPrimaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isTablet ? 80 : 66),

                    // ==================================================
                    // APP BAR
                    // ==================================================
                    CommonCustomAppBarWidget(
                      isTablet: isTablet,
                      showBackButton: true,
                      title: 'Notifications',
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {},
                      showShareButton: false,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // NOTIFICATION HEADER
                    // ==================================================
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 0,
                      ),
                      child: _NotificationHeader(isTablet: isTablet),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // FILTER TABS
                    // ==================================================
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 0,
                      ),
                      child: _NotificationTabs(
                        selectedIndex: _selectedTab,
                        onChanged: _onTabChanged,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // NOTIFICATIONS
                    // ==================================================
                    Consumer<TrainerAllWebinarProvider>(
                      builder: (context, provider, child) {
                        final failure = provider.failure;

                        // ------------------------------------------
                        // NETWORK ERROR
                        // ------------------------------------------

                        if (failure is NetworkFailure) {
                          return NetWorkRetry(
                            failureMessage:
                                provider.failure?.message ??
                                'No internet connection',
                            onRetry: () async {
                              await _loadNotifications();
                            },
                          );
                        }

                        // ------------------------------------------
                        // LOADING
                        // ------------------------------------------

                        if (provider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 70),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        // ------------------------------------------
                        // DATA
                        // ------------------------------------------

                        final List<NotificationItem> notifications =
                            provider.notificationModel?.data?.items ?? [];

                        // ------------------------------------------
                        // EMPTY
                        // ------------------------------------------

                        if (notifications.isEmpty) {
                          return _EmptyNotifications(selectedTab: _selectedTab);
                        }

                        // ------------------------------------------
                        // LIST
                        // ------------------------------------------

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 0,
                          ),
                          child: Column(
                            children: List.generate(notifications.length, (
                              index,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCard(
                                  notification: notifications[index],
                                  isTablet: isTablet,
                                  onTap: () async {
                                    if (notifications[index].isRead == 'true') {
                                      print('is read');
                                      return;
                                    }
                                    await provider.markAsReadNotification(
                                      notifications[index].id.toString(),
                                    );

                                    if (!mounted) return;
                                  },
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION HEADER
// ============================================================================

class _NotificationHeader extends StatelessWidget {
  final bool isTablet;

  const _NotificationHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 22 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.18),
            AppColor.formSecondaryColor.withOpacity(0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.formPrimaryColor.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColor.formPrimaryColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: isTablet ? 54 : 48,
            height: isTablet ? 54 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.formPrimaryColor.withOpacity(0.18),
                  AppColor.formSecondaryColor.withOpacity(0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: AppColor.formPrimaryColor,
              size: isTablet ? 28 : 25,
            ),
          ),

          const SizedBox(width: 14),

          // TITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay updated with your latest activities',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.ghostwhite.withOpacity(0.65),
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION TABS
// ============================================================================

class _NotificationTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _NotificationTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          _TabItem(
            title: 'All',
            icon: Icons.notifications_none_rounded,
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            title: 'Unread',
            icon: Icons.mark_email_unread_outlined,
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          _TabItem(
            title: 'Read',
            icon: Icons.mark_email_read_outlined,
            isSelected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB ITEM
// ============================================================================

class _TabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        AppColor.formPrimaryColor.withOpacity(0.85),
                        AppColor.formSecondaryColor.withOpacity(0.85),
                      ],
                    )
                    : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION CARD
// ============================================================================

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final bool isTablet;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notification,
    required this.isTablet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = _isNotificationRead(notification.isRead);

    final String title =
        notification.title?.trim().isNotEmpty == true
            ? notification.title!.trim()
            : 'Notification';

    final String message =
        notification.message?.trim().isNotEmpty == true
            ? notification.message!.trim()
            : 'No message available';

    final String event =
        notification.event?.trim().isNotEmpty == true
            ? notification.event!.trim()
            : 'Notification';

    final String createdAt = _formatDate(notification.createdAt);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isRead
                    ? [
                      AppColor.formPrimaryColor.withOpacity(0.10),
                      AppColor.formSecondaryColor.withOpacity(0.10),
                    ]
                    : [
                      AppColor.formPrimaryColor.withOpacity(0.24),
                      AppColor.formSecondaryColor.withOpacity(0.24),
                    ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isRead
                    ? Colors.white.withOpacity(0.08)
                    : AppColor.formPrimaryColor.withOpacity(0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.formPrimaryColor.withOpacity(
                isRead ? 0.03 : 0.07,
              ),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // NOTIFICATION ICON
            // ==========================================================
            Container(
              width: isTablet ? 54 : 48,
              height: isTablet ? 54 : 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.formPrimaryColor.withOpacity(isRead ? 0.10 : 0.20),
                    AppColor.formSecondaryColor.withOpacity(
                      isRead ? 0.10 : 0.20,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getEventIcon(event),
                color: AppColor.formPrimaryColor,
                size: isTablet ? 27 : 24,
              ),
            ),

            const SizedBox(width: 13),

            // ==========================================================
            // CONTENT
            // ==========================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + UNREAD DOT
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.ghostwhite,
                            fontSize: isTablet ? 17 : 15,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                      ),

                      if (!isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: AppColor.formPrimaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.formPrimaryColor.withOpacity(
                                  0.4,
                                ),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 7),

                  // MESSAGE
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.ghostwhite.withOpacity(
                        isRead ? 0.60 : 0.75,
                      ),
                      fontSize: isTablet ? 14 : 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTTOM INFORMATION
                  Row(
                    children: [
                      // EVENT
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.formPrimaryColor.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.label_outline_rounded,
                                size: 13,
                                color: AppColor.formPrimaryColor,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  event,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColor.formPrimaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // DATE
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColor.ghostwhite.withOpacity(0.45),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                createdAt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColor.ghostwhite.withOpacity(0.50),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHECK READ STATUS
  // ============================================================

  bool _isNotificationRead(String? value) {
    if (value == null) return false;

    final String status = value.trim().toLowerCase();

    return status == 'true' || status == '1' || status == 'read';
  }

  // ============================================================
  // EVENT ICON
  // ============================================================

  IconData _getEventIcon(String event) {
    final String value = event.toLowerCase();

    if (value.contains('webinar')) {
      return Icons.video_camera_front_rounded;
    }

    if (value.contains('course')) {
      return Icons.school_rounded;
    }

    if (value.contains('assignment')) {
      return Icons.assignment_rounded;
    }

    if (value.contains('message')) {
      return Icons.message_rounded;
    }

    if (value.contains('payment')) {
      return Icons.payments_rounded;
    }

    if (value.contains('live')) {
      return Icons.live_tv_rounded;
    }

    return Icons.notifications_rounded;
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date unavailable';
    }

    try {
      final DateTime date = DateTime.parse(value).toLocal();

      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return value;
    }
  }
}

// ============================================================================
// EMPTY NOTIFICATIONS
// ============================================================================

class _EmptyNotifications extends StatelessWidget {
  final int selectedTab;

  const _EmptyNotifications({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    IconData icon;

    switch (selectedTab) {
      case 1:
        title = 'No Unread Notifications';
        message = 'You are all caught up!';
        icon = Icons.mark_email_read_rounded;
        break;

      case 2:
        title = 'No Read Notifications';
        message = 'You have no read notifications yet.';
        icon = Icons.notifications_none_rounded;
        break;

      default:
        title = 'No Notifications';
        message = 'You don\'t have any notifications yet.';
        icon = Icons.notifications_none_rounded;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 55),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.10),
            AppColor.formSecondaryColor.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.formPrimaryColor.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.formPrimaryColor.withOpacity(0.14),
                  AppColor.formSecondaryColor.withOpacity(0.14),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColor.formPrimaryColor),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

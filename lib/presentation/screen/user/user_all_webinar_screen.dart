import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/animation/animation.dart';
import 'package:lms/animation/webinar_stager_animation.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/user_full_list_webinar_model/user_full_list_webinar_model.dart';
import 'package:lms/presentation/provider/user_provider/user_all_wbinar_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/webinar_price_label.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

enum PaymentStatus {
  notRequired(1, 'Not Required'),
  pending(2, 'Pending'),
  processing(3, 'Processing'),
  paid(4, 'Paid'),
  failed(5, 'Failed'),
  cancelled(6, 'Cancelled'),
  expired(7, 'Expired'),
  refunded(8, 'Refunded');

  final int value;
  final String label;

  const PaymentStatus(this.value, this.label);
}

class UserAllWebinarScreen extends StatefulWidget {
  const UserAllWebinarScreen({super.key});

  @override
  State<UserAllWebinarScreen> createState() => _UserAllWebinarScreenState();
}

class _UserAllWebinarScreenState extends State<UserAllWebinarScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;
  String _selectedFilter = 'Upcoming';
  PaymentStatus? _selectedPaymentStatus;
  bool _isDialogShowing = false;
  final List<String> _filters = const [
    'All',
    'Upcoming',
    'Past',
    'Live',
    'Not Required',
    'Pending',
    'Processing',
    'Paid',
    'Failed',
    'Cancelled',
    'Expired',
    'Refunded',
  ];

  PaymentStatus? _getPaymentStatus(String filter) {
    switch (filter) {
      case 'Not Required':
        return PaymentStatus.notRequired;

      case 'Pending':
        return PaymentStatus.pending;

      case 'Processing':
        return PaymentStatus.processing;

      case 'Paid':
        return PaymentStatus.paid;

      case 'Failed':
        return PaymentStatus.failed;

      case 'Cancelled':
        return PaymentStatus.cancelled;

      case 'Expired':
        return PaymentStatus.expired;

      case 'Refunded':
        return PaymentStatus.refunded;

      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialData();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Load more when 300 pixels remain
    if (_scrollController.position.extentAfter < 300) {
      final provider = context.read<UserAllWbinarProvider>();

      if (!provider.isLoading && !provider.isLoadingMore && provider.hasMore) {
        final bool isPaymentFilter = _selectedPaymentStatus != null;

        provider.getAllWebinarPro(
          isPaymentFilter ? null : _getStatus(_selectedFilter),
          _searchController.text.trim(),
          paymentStatus: _selectedPaymentStatus?.value,
          loadMore: true,
        );
      }
    }
  }
  // ============================================================
  // LOAD WEBINARS
  // ============================================================

  Future<void> _initialData({String? status}) async {
    print('Initial Data Load: Status = ${_selectedFilter}');
    if (!mounted) return;

    final provider = context.read<UserAllWbinarProvider>();
    final selectedStatus = status ?? _getStatus(_selectedFilter);
    // await provider.getAllWebinarPro(selectedStatus, '');
    final bool isPaymentFilter = _selectedPaymentStatus != null;
    provider.getAllWebinarPro(
      isPaymentFilter ? null : _getStatus(_selectedFilter),
      _searchController.text.trim(),
      paymentStatus: _selectedPaymentStatus?.value,
    );

    if (!mounted) return;
  }

  // ============================================================
  // STATUS MAPPING
  // ============================================================

  String? _getStatus(String filter) {
    switch (filter) {
      case 'All':
        return '1';

      case 'Upcoming':
        return '2';

      case 'Past':
        return '3';

      case 'Live':
        return '4';

      default:
        return '1';
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  Future<void> _onFilterSelected(String filter) async {
    print('Selected Filter: $filter');

    if (_selectedFilter == filter) {
      return;
    }

    final previousFilter = _selectedFilter;
    final previousPaymentStatus = _selectedPaymentStatus;

    final paymentStatus = _getPaymentStatus(filter);

    setState(() {
      _selectedFilter = filter;
      _selectedPaymentStatus = paymentStatus;
    });
    print(
      'Updated Filter: $_selectedFilter | Payment Status: $_selectedPaymentStatus',
    );
    print('');
    final provider = context.read<UserAllWbinarProvider>();

    // ------------------------------------------------------------
    // TIME FILTER
    // ------------------------------------------------------------

    String? timeFilter;

    if (paymentStatus == null) {
      // Selected All / Upcoming / Past / Live
      timeFilter = _getStatus(filter);
    } else {
      // Selected Payment Status
      // Do not send TimeFilter
      timeFilter = null;
    }

    // ------------------------------------------------------------
    // API
    // ------------------------------------------------------------

    await provider.getAllWebinarPro(
      timeFilter,
      _searchController.text.trim(),
      paymentStatus: paymentStatus?.value,
    );

    if (!mounted) return;

    if (provider.failure != null) {
      setState(() {
        _selectedFilter = previousFilter;
        _selectedPaymentStatus = previousPaymentStatus;
      });

      handleFailure(provider);
      provider.clearFailure();
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  Future<void> handleFailure(UserAllWbinarProvider webinarProvider) async {
    if (!mounted) return;

    final failure = webinarProvider.failure;

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
        provider: webinarProvider,
        onTap: () {
          webinarProvider.clearFailure();
          Navigator.pop(context);
        },
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      final provider = context.read<UserAllWbinarProvider>();

      final bool isPaymentFilter = _selectedPaymentStatus != null;

      final String? timeFilter =
          isPaymentFilter ? null : _getStatus(_selectedFilter);

      await provider.getAllWebinarPro(
        timeFilter,
        value.trim(),
        paymentStatus: _selectedPaymentStatus?.value,
      );
    });
  }
  // ============================================================
  // BUILD
  // ============================================================

  @override
  void dispose() {
    // TODO: implement dispose

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 600;
          return RefreshIndicator(
            onRefresh: _initialData,
            color: AppColor.gold,
            backgroundColor: AppColor.background,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isTablet ? 80 : 66),
                  // App Bar
                  // ==================================================
                  // HEADER
                  // ==================================================
                  HomeHeaderSectionWidget(
                    isTablet: isTablet,
                    title: 'Manage Webinars',
                    subTitle: 'All your classes in one place',
                    showNotificationIcon: true,
                    showProfileImage: false,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SEARCH BAR
                  // ==================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 0),
                    child: _WebinarSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // FILTER
                  // ==================================================
                  _WebinarFilterBar(
                    filters: _filters,
                    selected: _selectedFilter,
                    onSelected: _onFilterSelected,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // CONTENT
                  // ==================================================
                  Consumer<UserAllWbinarProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const _WebinarLoadingState();
                      }
                      final failure = provider.failure;
                      if (failure is NetworkFailure) {
                        return NetWorkRetry(
                          failureMessage:
                              provider.failure?.message ??
                              "No internet connection",
                          onRetry: () async {
                            await _initialData();
                          },
                        );
                      }
                      return Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          child: WebinarList(
                            userAllWbinarProvider: provider,
                            onRetry: _initialData,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// FILTER BAR
// ============================================================================

class _WebinarFilterBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const _WebinarFilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(colors: AppColor.goldGradient)
                        : null,
                color: isSelected ? null : AppColor.background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color:
                      isSelected
                          ? Colors.transparent
                          : AppColor.formBorderColor.withOpacity(0.24),
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColor.gold.withOpacity(0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  // Selected text = dark
                  // Unselected text = light
                  color:
                      isSelected ? AppColor.buttonText : AppColor.primaryText,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
// WEBINAR LIST
// ============================================================================

class WebinarList extends StatelessWidget {
  final UserAllWbinarProvider userAllWbinarProvider;
  final VoidCallback onRetry;

  const WebinarList({
    super.key,
    required this.userAllWbinarProvider,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // final AllWebinarData? data =
    //     userAllWbinarProvider.fullListWebinarModel?.data;

    // final items = data?.items ?? [];
    final items = userAllWbinarProvider.webinarItems;

    // ------------------------------------------------------------
    // EMPTY STATE
    // ------------------------------------------------------------

    if (items.isEmpty) {
      return const _WebinarEmptyState();
    }

    // ------------------------------------------------------------
    // LIST
    // ------------------------------------------------------------

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length + (userAllWbinarProvider.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        // Bottom loading indicator
        if (index >= items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColor.gold),
            ),
          );
        }
        final webinar = items[index];

        return WebinarStaggerAnimation(
          key: ValueKey(webinar.id),
          index: index,
          child: Column(
            children: [
              WebinarTile(
                key: ValueKey(webinar.id),
                title: _safeString(webinar.title),
                status: _getStatusText(webinar.status),
                students: '0',
                startDateTime: _safeString(webinar.startDateTime),
                recentWebinarId: webinar.id?.toString() ?? '',
                isPaid: webinar.isPaid,
                price: webinar.price,
                imageUrl: webinar.thumbnailUrl ?? '',
              ),
            ],
          ),
        );
      },
    );
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
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
        return 'Past';

      case '5':
        return 'Cancelled';

      default:
        return value.isEmpty ? 'Unknown' : value;
    }
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
  final String recentWebinarId;
  final String? isPaid;
  final String? price;
  final String? imageUrl;

  const WebinarTile({
    super.key,
    required this.title,
    required this.status,
    required this.students,
    required this.startDateTime,
    required this.recentWebinarId,
    required this.isPaid,
    required this.price,
    required this.imageUrl,
  });

  // ============================================================
  // SAFE DATE PARSER
  // ============================================================

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.redAccent;

      case 'scheduled':
        return Colors.orangeAccent;

      case 'past':
        return Colors.greenAccent;

      case 'cancelled':
        return Colors.redAccent;

      default:
        return Colors.white70;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final dateTime = _parseDate(startDateTime);

    final formattedDate =
        dateTime != null
            ? DateFormat('dd MMM yyyy').format(dateTime)
            : 'Date unavailable';

    final formattedTime =
        dateTime != null
            ? DateFormat('hh:mm a').format(dateTime)
            : 'Time unavailable';

    final bool hasId = recentWebinarId.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap:
            !hasId
                ? null
                : () {
                  Navigator.pushNamed(
                    context,
                    '/userwebinarcoursedetailpage',
                    arguments: {'courseId': recentWebinarId},
                  );
                },
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColor.borderGlassColor),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // ICON or image
                // ==================================================
                // IMAGE
                SizedBox(
                  width: 122,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.gold.withOpacity(0.20),
                            AppColor.goldDark.withOpacity(0.20),
                          ],
                        ),
                      ),
                      child:
                          (imageUrl == null || imageUrl!.isEmpty)
                              ? Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: Colors.grey.shade500,
                              )
                              : Image.network(
                                '${ApiEndPoint.serverUrl}${imageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: Colors.grey.shade500,
                                  );
                                },
                              ),
                    ),
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ------------------------------------------
                          // TITLE + STATUS
                          // ------------------------------------------
                          Text(
                            '${isPaid == 'true' ? 'PREMIUM' : 'FREE'}'
                                .toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isPaid == 'true'
                                      ? AppColor.gold
                                      : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              letterSpacing: 1.44, // 12% of 12px
                            ),
                          ),
                          const SizedBox(height: 4),
                          // ------------------------------------------
                          // TITLE + STATUS
                          // ------------------------------------------
                          Text(
                            title.isEmpty ? 'Untitled Webinar' : title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ------------------------------------------
                          // DATE + TIME
                          // ------------------------------------------
                          Wrap(
                            spacing: 14,
                            runSpacing: 7,
                            children: [
                              _InfoItem(
                                icon: Icons.calendar_today_outlined,
                                text: formattedDate,
                              ),
                              _InfoItem(
                                icon: Icons.access_time_outlined,
                                text: formattedTime,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------------
                          // price
                          // ------------------------------------------
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                color: Colors.white54,
                                size: 22,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                price ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '/ per slot',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

// ============================================================================
// INFO ITEM
// ============================================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColor.lightgray, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: AppColor.lightgray, fontSize: 12),
        ),
      ],
    );
  }
}

// ============================================================================
// LOADING STATE
// ============================================================================

class _WebinarLoadingState extends StatelessWidget {
  const _WebinarLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _WebinarShimmerTile(),
        ),
      ),
    );
  }
}

class _WebinarShimmerTile extends StatelessWidget {
  const _WebinarShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 10,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
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
// EMPTY STATE
// ============================================================================

class _WebinarEmptyState extends StatelessWidget {
  const _WebinarEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.video_camera_front_outlined,
            size: 52,
            color: Colors.white30,
          ),
          SizedBox(height: 16),
          Text(
            'No webinars found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'There are no webinars available for this filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _WebinarErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _WebinarErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorText =
        message?.trim().isNotEmpty == true
            ? message!
            : 'Unable to load webinars.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            errorText,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.formPrimaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebinarSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _WebinarSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColor.cardBackground.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.10)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: AppColor.gold,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search webinars...',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColor.gold,
            size: 22,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

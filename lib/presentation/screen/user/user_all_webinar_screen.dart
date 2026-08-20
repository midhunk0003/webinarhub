import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';
import 'package:lms/data/model/user_full_list_webinar_model/user_full_list_webinar_model.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_all_wbinar_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/webinar_price_label.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class UserAllWebinarScreen extends StatefulWidget {
  const UserAllWebinarScreen({super.key});

  @override
  State<UserAllWebinarScreen> createState() => _UserAllWebinarScreenState();
}

class _UserAllWebinarScreenState extends State<UserAllWebinarScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedFilter = 'All';
  bool _isDialogShowing = false;
  final List<String> _filters = const ['All', 'Upcoming', 'Past', 'Live'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialData();
    });
  }

  // ============================================================
  // LOAD WEBINARS
  // ============================================================

  Future<void> _initialData({String? status}) async {
    if (!mounted) return;

    final provider = context.read<UserAllWbinarProvider>();

    await provider.getAllWebinarPro(status, '');

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
    if (_selectedFilter == filter) return;

    final previousFilter = _selectedFilter;

    setState(() {
      _selectedFilter = filter;
    });

    final provider = context.read<UserAllWbinarProvider>();

    final status = _getStatus(filter);

    await provider.getAllWebinarPro(status, '');

    if (!mounted) return;

    if (provider.failure != null) {
      // Restore previous filter if API fails.
      setState(() {
        _selectedFilter = previousFilter;
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

      final status = _getStatus(_selectedFilter);

      await provider.getAllWebinarPro(status, value.trim());
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  void dispose() {
    // TODO: implement dispose
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 0,
                      ),
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
                        return WebinarList(
                          userAllWbinarProvider: provider,
                          onRetry: _initialData,
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
                        ? LinearGradient(
                          colors: [
                            AppColor.formPrimaryColor,
                            AppColor.formSecondaryColor,
                          ],
                        )
                        : null,
                color: isSelected ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color:
                      isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.10),
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColor.formPrimaryColor.withOpacity(0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
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
    final AllWebinarData? data =
        userAllWbinarProvider.fullListWebinarModel?.data;

    final items = data?.items ?? [];

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
      itemCount: items.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final webinar = items[index];

        return WebinarTile(
          key: ValueKey(webinar.id),
          title: _safeString(webinar.title),
          status: _getStatusText(webinar.status),
          students: '0',
          startDateTime: _safeString(webinar.startDateTime),
          recentWebinarId: webinar.id?.toString() ?? '',
          isPaid: webinar.isPaid,
          price: webinar.price,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.09)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // ICON
              // ==================================================
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.formPrimaryColor.withOpacity(0.20),
                      AppColor.formSecondaryColor.withOpacity(0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.video_collection_outlined,
                  color: AppColor.formPrimaryColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------
                    // TITLE + STATUS
                    // ------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title.isEmpty ? 'Untitled Webinar' : title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        _StatusBadge(status: status, color: _statusColor()),
                      ],
                    ),

                    const SizedBox(height: 11),

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

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // price
                    // ------------------------------------------
                    Row(
                      children: [
                        const Icon(
                          Icons.currency_rupee,
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

              const SizedBox(width: 8),

              // ==================================================
              // ARROW
              // ==================================================
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: hasId ? Colors.white38 : Colors.white12,
                  size: 15,
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
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: AppColor.formPrimaryColor,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search webinars...',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColor.formPrimaryColor,
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

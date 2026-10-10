import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class TrainerWebinarScreen extends StatefulWidget {
  const TrainerWebinarScreen({super.key});

  @override
  State<TrainerWebinarScreen> createState() => _TrainerWebinarScreenState();
}

class _TrainerWebinarScreenState extends State<TrainerWebinarScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedFilter = 'All';
  bool _isDialogShowing = false;
  final List<String> _filters = const [
    'All',
    'Scheduled',
    'Live',
    'Completed',
    'Cancelled',
  ];

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

    final provider = context.read<TrainerAllWebinarProvider>();

    await provider.getAllWebinarPro(status, '');

    if (!mounted) return;
  }

  // ============================================================
  // STATUS MAPPING
  // ============================================================

  String? _getStatus(String filter) {
    switch (filter) {
      case 'Scheduled':
        return '2';

      case 'Live':
        return '3';

      case 'Completed':
        return '4';

      case 'Cancelled':
        return '5';

      case 'All':
      default:
        return null;
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

    final provider = context.read<TrainerAllWebinarProvider>();

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

  Future<void> handleFailure(TrainerAllWebinarProvider webinarProvider) async {
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

      final provider = context.read<TrainerAllWebinarProvider>();

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
            color: AppColor.gold,
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
                    Consumer<TrainerAllWebinarProvider>(
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
                          trainerAllWebinarProvider: provider,
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
  final TrainerAllWebinarProvider trainerAllWebinarProvider;
  final VoidCallback onRetry;

  const WebinarList({
    super.key,
    required this.trainerAllWebinarProvider,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final data = trainerAllWebinarProvider.trainerFullListWebinarModel?.data;

    final items = data?.items ?? [];

    if (items.isEmpty) {
      return const _WebinarEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final webinar = items[index];

        return WebinarTile(
          key: ValueKey(webinar.id),
          title: _safeString(webinar.title),
          status:
              _safeString(webinar.statusName).isNotEmpty
                  ? _safeString(webinar.statusName)
                  : _getStatusText(webinar.status),
          students: _safeString(webinar.enrolledParticipantCount),
          startDateTime: _safeString(webinar.startDateTime),
          recentWebinarId: _safeString(webinar.id),
          isPaid: _safeString(webinar.isPaid),
          price: _formatPrice(webinar.price, _safeString(null), webinar.isPaid),
          imageUrl: _safeString(webinar.thumbnailUrl),
        );
      },
    );
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _getStatusText(dynamic status) {
    switch (status?.toString()) {
      case '2':
        return 'Scheduled';
      case '3':
        return 'Live';
      case '4':
        return 'Completed';
      case '5':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _formatPrice(dynamic price, String currency, dynamic isPaid) {
    final paid =
        isPaid == true || isPaid?.toString().trim().toLowerCase() == 'true';

    if (!paid) return 'Free';

    if (price == null || price.toString().trim().isEmpty) {
      return 'Price unavailable';
    }

    final amount = double.tryParse(price.toString());

    final formattedAmount =
        amount == null
            ? price.toString()
            : amount == amount.truncateToDouble()
            ? amount.toInt().toString()
            : amount.toStringAsFixed(2);

    final currencyCode = currency.isEmpty ? 'INR' : currency.toUpperCase();

    if (currencyCode == 'INR') {
      return '$formattedAmount';
    }

    return '$currencyCode $formattedAmount';
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

  // ==========================================================================
  // PREMIUM / FREE
  // ==========================================================================

  bool get _isPremium {
    return isPaid?.trim().toLowerCase() == 'true';
  }

  // ==========================================================================
  // SAFE DATE PARSER
  // ==========================================================================

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) return null;

    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  // ==========================================================================
  // STATUS COLOR
  // ==========================================================================

  Color _statusColor() {
    switch (status.trim().toLowerCase()) {
      case 'live':
        return Colors.redAccent;
      case 'scheduled':
        return Colors.orangeAccent;
      case 'completed':
      case 'past':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  // ==========================================================================
  // THUMBNAIL URL
  // ==========================================================================

  String _thumbnailImageUrl(String path) {
    final value = path.trim();

    if (value.startsWith('https://') || value.startsWith('http://')) {
      return value;
    }

    final baseUrl = ApiEndPoint.serverUrl;

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

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

    final hasId = recentWebinarId.trim().isNotEmpty;

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
                    '/trainerwebinardetailpage',
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
                // ==========================================================
                // THUMBNAIL
                // ==========================================================
                SizedBox(
                  width: 122,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.gold.withOpacity(.20),
                            AppColor.goldDark.withOpacity(.20),
                          ],
                        ),
                      ),
                      child:
                          imageUrl != null && imageUrl!.trim().isNotEmpty
                              ? Image.network(
                                _thumbnailImageUrl(imageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _buildFallbackImage(),
                              )
                              : _buildFallbackImage(),
                    ),
                  ),
                ),

                // ==========================================================
                // CONTENT
                // ==========================================================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium / Free
                        Text(
                          _isPremium ? 'PREMIUM' : 'FREE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _isPremium ? AppColor.gold : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            letterSpacing: 1.44,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Title
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

                        // Status
                        _StatusBadge(status: status, color: _statusColor()),

                        const SizedBox(height: 8),

                        // Date and time
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

                        const SizedBox(height: 12),

                        // Enrolled students
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              color: Colors.white54,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '$students Students',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Divider
                        const _DottedDivider(),

                        const SizedBox(height: 12),

                        // Price
                        CommonCustomeButtonWidget(
                          isTablet: false,
                          text: 'Join',
                          onTap: () {
                            if (!hasId) return;

                            Navigator.pushNamed(
                              context,
                              '/trainerwebinardetailpage',
                              arguments: {'courseId': recentWebinarId},
                            );
                          },
                          lotty: true,
                        ),
                      ],
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

  // ==========================================================================
  // FALLBACK IMAGE
  // ==========================================================================

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gold.withOpacity(.20),
            AppColor.goldDark.withOpacity(.20),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_collection_outlined,
          size: 42,
          color: AppColor.gold,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
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
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ],
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
      children: List.generate(35, (index) {
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

// ============================================================================
// EMPTY STATE
// ============================================================================

class _WebinarEmptyState extends StatelessWidget {
  const _WebinarEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.borderGlassColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_collection_outlined,
            size: 42,
            color: AppColor.gold.withOpacity(.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'No webinars found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your webinars will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
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
        color: AppColor.background.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gold.withOpacity(0.20)),
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

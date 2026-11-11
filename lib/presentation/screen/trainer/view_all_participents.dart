import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_all_webinar_participents_model/trainer_all_webinar_participents_model.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class ViewAllParticipents extends StatefulWidget {
  final String? courseId;

  const ViewAllParticipents({required this.courseId, super.key});

  @override
  State<ViewAllParticipents> createState() => _ViewAllParticipentsState();
}

class _ViewAllParticipentsState extends State<ViewAllParticipents> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialData();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD PARTICIPANTS
  // ============================================================

  Future<void> _initialData() async {
    if (!mounted) return;

    final provider = context.read<TrainerCourseProvider>();

    await provider.getParticipantsListPro(
      widget.courseId,
      _searchController.text.trim(),
    );

    if (!mounted) return;

    if (provider.failure != null && provider.failure is! NetworkFailure) {
      await handleFailure(provider);
    }
  }

  // ============================================================
  // FAILURE DIALOG
  // ============================================================

  Future<void> handleFailure(TrainerCourseProvider provider) async {
    if (!mounted || _isDialogShowing) return;

    final failure = provider.failure;

    if (failure == null || failure is NetworkFailure) {
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

          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      final provider = context.read<TrainerCourseProvider>();

      await provider.getParticipantsListPro(widget.courseId, value.trim());

      if (!mounted) return;

      if (provider.failure != null && provider.failure is! NetworkFailure) {
        await handleFailure(provider);
      }
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _onSearchChanged('');
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
            onRefresh: _initialData,
            color: AppColor.gold,
            backgroundColor: AppColor.cardBackground,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isTablet ? 65 : 50),

                    CommonCustomAppBarWidget(
                      isTablet: isTablet,
                      showBackButton: true,
                      title: '',
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {},
                      showShareButton: false,
                    ),

                    const SizedBox(height: 24),

                    // PAGE TITLE
                    _PageHeading(isTablet: isTablet),

                    const SizedBox(height: 24),

                    // SEARCH
                    _WebinarSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                    ),

                    const SizedBox(height: 22),

                    // PARTICIPANT CONTENT
                    Consumer<TrainerCourseProvider>(
                      builder: (context, provider, child) {
                        final failure = provider.failure;

                        if (failure is NetworkFailure) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: NetWorkRetry(
                              failureMessage:
                                  failure.message ?? 'No internet connection',
                              onRetry: _initialData,
                            ),
                          );
                        }

                        if (provider.isLoadingListOfParticipents) {
                          return const _LoadingParticipants();
                        }

                        final List<ParticipantItem> participants =
                            provider
                                .trainerAllWebinarParticipentsModel
                                ?.data
                                ?.items ??
                            [];

                        if (participants.isEmpty) {
                          return _EmptyParticipants(
                            hasSearch: _searchController.text.trim().isNotEmpty,
                          );
                        }

                        return _Participants(
                          participants: participants,
                          isTablet: isTablet,
                        );
                      },
                    ),

                    const SizedBox(height: 24),
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

// ================================================================
// PAGE HEADING
// ================================================================

class _PageHeading extends StatelessWidget {
  final bool isTablet;

  const _PageHeading({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: isTablet ? 35 : 31,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColor.goldLight, AppColor.goldDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'All Participants',
                style: TextStyle(
                  fontSize: isTablet ? 29 : 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppColor.primaryText,
                ),
              ),
            ),
            const Icon(Icons.groups_rounded, size: 28, color: AppColor.gold),
          ],
        ),
        const SizedBox(height: 9),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Manage and view your webinar participants',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12.5,
              color: AppColor.secondaryText.withOpacity(0.75),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// PARTICIPANTS
// ================================================================

class _Participants extends StatelessWidget {
  final List<ParticipantItem> participants;
  final bool isTablet;

  const _Participants({required this.participants, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SUMMARY CARD
        _ParticipantSummaryCard(count: participants.length, isTablet: isTablet),
        // const SizedBox(height: 24),
        // // SECTION HEADER
        // Row(
        //   children: [
        //     const Expanded(
        //       child: Text(
        //         'Participant List',
        //         style: TextStyle(
        //           color: AppColor.primaryText,
        //           fontSize: 17,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //     ),
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        //       decoration: BoxDecoration(
        //         color: AppColor.gold.withOpacity(0.09),
        //         borderRadius: BorderRadius.circular(20),
        //         border: Border.all(color: AppColor.gold.withOpacity(0.24)),
        //       ),
        //       child: Text(
        //         '${participants.length} ${participants.length == 1 ? 'person' : 'people'}',
        //         style: const TextStyle(
        //           color: AppColor.goldLight,
        //           fontSize: 11,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 14),

        // CARDS
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: participants.length,
          separatorBuilder: (context, index) => const SizedBox(height: 13),
          itemBuilder: (context, index) {
            return _ParticipantCard(
              participant: participants[index],
              index: index,
              isTablet: isTablet,
            );
          },
        ),
      ],
    );
  }
}

// ================================================================
// SUMMARY CARD
// ================================================================

class _ParticipantSummaryCard extends StatelessWidget {
  final int count;
  final bool isTablet;

  const _ParticipantSummaryCard({required this.count, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF292318), Color(0xFF171510), Color(0xFF101010)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColor.gold.withOpacity(0.38)),
        boxShadow: [
          BoxShadow(
            color: AppColor.goldDark.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: isTablet ? 62 : 56,
            height: isTablet ? 62 : 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColor.goldLight, AppColor.gold, AppColor.goldDark],
              ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: AppColor.gold.withOpacity(0.18),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColor.buttonText,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          // COUNT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PARTICIPANTS',
                  style: TextStyle(
                    color: AppColor.goldLight.withOpacity(0.85),
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$count',
                  style: TextStyle(
                    color: AppColor.primaryText,
                    fontSize: isTablet ? 33 : 29,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  count == 1
                      ? 'Registered participant'
                      : 'Registered participants',
                  style: TextStyle(
                    color: AppColor.secondaryText.withOpacity(0.72),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF183326),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.17)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF7BD9A2),
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  'Loaded',
                  style: TextStyle(
                    color: Color(0xFF7BD9A2),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

// ================================================================
// PARTICIPANT CARD
// ================================================================

class _ParticipantCard extends StatelessWidget {
  final ParticipantItem participant;
  final int index;
  final bool isTablet;

  const _ParticipantCard({
    required this.participant,
    required this.index,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final String name = _safeText(
      participant.userFullName,
      'Unknown Participant',
    );

    final String email = _safeText(participant.userEmail, 'No email available');

    final String enrollmentStatus = _safeText(
      participant.enrollmentStatusName,
      'Unknown',
    );

    final String enrollmentSource = _safeText(
      participant.enrollmentSourceName,
      'Unknown source',
    );

    final String enrollmentDate = _formatDate(participant.enrollmentDate);

    final bool isEnrolled =
        participant.enrollmentStatus == 2 ||
        enrollmentStatus.toLowerCase() == 'enrolled';

    final Color statusColor =
        isEnrolled ? const Color(0xFF7BD9A2) : AppColor.goldLight;

    return Container(
      padding: EdgeInsets.all(isTablet ? 21 : 16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.gold.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadow.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ParticipantAvatar(name: name, size: isTablet ? 58 : 52),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.primaryText,
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),

                    // EMAIL
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppColor.gold,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            email,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.secondaryText.withOpacity(0.85),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _StatusChip(text: enrollmentStatus, color: statusColor),
            ],
          ),

          const SizedBox(height: 18),

          // GOLD DIVIDER
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.gold.withOpacity(0.0),
                  AppColor.gold.withOpacity(0.30),
                  AppColor.gold.withOpacity(0.0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ENROLLMENT DETAILS
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _InfoChip(
                icon: Icons.calendar_month_rounded,
                label: 'Enrolled',
                text: enrollmentDate,
              ),
              _InfoChip(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Source',
                text: enrollmentSource,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _safeText(String? value, String fallback) {
    final text = value?.trim();
    return text != null && text.isNotEmpty ? text : fallback;
  }

  static String _formatDate(dynamic value) {
    if (value == null) return 'Date unavailable';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return value.toString();
    }
  }
}

// ================================================================
// PARTICIPANT AVATAR
// ================================================================

class _ParticipantAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _ParticipantAvatar({required this.name, required this.size});

  String _getInitials() {
    final parts =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A3020), Color(0xFF1C1913)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.gold.withOpacity(0.65), width: 1.3),
        boxShadow: [
          BoxShadow(color: AppColor.gold.withOpacity(0.07), blurRadius: 12),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: AppColor.goldLight,
            fontSize: size * 0.31,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STATUS CHIP
// ================================================================

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 105),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Flexible(
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
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// INFO CHIP
// ================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColor.secondaryGlassColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColor.gold.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColor.gold),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: AppColor.secondaryText.withOpacity(0.58),
                    fontSize: 8,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.goldLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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

// ================================================================
// SEARCH BAR
// ================================================================

class _WebinarSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _WebinarSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.secondaryGlassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gold.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadow.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColor.primaryText, fontSize: 14),
        cursorColor: AppColor.gold,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: TextStyle(
            color: AppColor.secondaryText.withOpacity(0.55),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColor.gold,
            size: 23,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColor.goldLight.withOpacity(0.85),
                  size: 20,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LOADING
// ================================================================

class _LoadingParticipants extends StatelessWidget {
  const _LoadingParticipants();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 75),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.gold),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Loading participants...',
              style: TextStyle(
                color: AppColor.secondaryText.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY PARTICIPANTS
// ================================================================

class _EmptyParticipants extends StatelessWidget {
  final bool hasSearch;

  const _EmptyParticipants({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColor.gold.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF332A1C), Color(0xFF171510)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.gold.withOpacity(0.30)),
            ),
            child: Icon(
              hasSearch ? Icons.search_off_rounded : Icons.groups_outlined,
              size: 35,
              color: AppColor.gold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            hasSearch ? 'No Results Found' : 'No Participants Yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColor.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            hasSearch
                ? 'Try a different name or email address.'
                : 'Participants will appear here when their enrollment data is available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.secondaryText.withOpacity(0.75),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

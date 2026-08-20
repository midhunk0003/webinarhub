import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_all_webinar_participents_model/trainer_all_webinar_participents_model.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
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
      _initialData();
    });
  }

  // ============================================================
  // LOAD PARTICIPANTS
  // ============================================================

  Future<void> _initialData() async {
    if (!mounted) return;

    final provider = context.read<TrainerCourseProvider>();

    await provider.getParticipantsListPro(widget.courseId, '');

    if (!mounted) return;

    if (provider.failure != null && provider.failure is! NetworkFailure) {
      await handleFailure(provider);
    }
  }

  // ============================================================
  // FAILURE DIALOG
  // ============================================================

  Future<void> handleFailure(TrainerCourseProvider provider) async {
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

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      final provider = context.read<TrainerCourseProvider>();

      await provider.getParticipantsListPro(widget.courseId, value.trim());
    });
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
                    // HEADER
                    // ==================================================
                    // App Bar
                    CommonCustomAppBarWidget(
                      isTablet: isTablet,
                      showBackButton: true,
                      title: "",
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {
                        print('share');
                      },
                      showShareButton: false,
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
                    // PARTICIPANTS
                    // ==================================================
                    Consumer<TrainerCourseProvider>(
                      builder: (context, provider, child) {
                        final failure = provider.failure;

                        // --------------------------------------------
                        // NETWORK ERROR
                        // --------------------------------------------

                        if (failure is NetworkFailure) {
                          return NetWorkRetry(
                            failureMessage:
                                provider.failure?.message ??
                                'No internet connection',
                            onRetry: () async {
                              await _initialData();
                            },
                          );
                        }

                        // --------------------------------------------
                        // PARTICIPANT LIST
                        // --------------------------------------------

                        return _Participants(trainerCourseProvider: provider);
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
// PARTICIPANTS
// ============================================================================

class _Participants extends StatelessWidget {
  final TrainerCourseProvider trainerCourseProvider;

  const _Participants({required this.trainerCourseProvider, super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // LOADING
    // ============================================================

    if (trainerCourseProvider.isLoadingListOfParticipents) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ============================================================
    // GET PARTICIPANTS
    // ============================================================

    final List<ParticipantItem> participants =
        trainerCourseProvider.trainerAllWebinarParticipentsModel?.data?.items ??
        [];

    // ============================================================
    // EMPTY
    // ============================================================

    if (participants.isEmpty) {
      return const _EmptyParticipants();
    }

    // ============================================================
    // RESPONSIVE
    // ============================================================

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // PARTICIPANT COUNT HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.formPrimaryColor.withOpacity(0.14),
                    AppColor.formSecondaryColor.withOpacity(0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColor.formPrimaryColor.withOpacity(0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.formPrimaryColor.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ICON
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.formPrimaryColor.withOpacity(0.16),
                          AppColor.formSecondaryColor.withOpacity(0.16),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: AppColor.formPrimaryColor,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // COUNT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Participants',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColor.ghostwhite.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${participants.length}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ghostwhite,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ENROLLED
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Enrolled',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // PARTICIPANT LIST
            // ==================================================
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final participant = participants[index];

                return _ParticipantCard(
                  participant: participant,
                  index: index,
                  isTablet: isTablet,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// PARTICIPANT CARD
// ============================================================================

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
    final String name =
        participant.userFullName?.trim().isNotEmpty == true
            ? participant.userFullName!.trim()
            : 'Unknown Participant';

    final String email =
        participant.userEmail?.trim().isNotEmpty == true
            ? participant.userEmail!.trim()
            : 'No email available';

    final String initials = _getInitials(name);

    final String enrollmentStatus =
        participant.enrollmentStatusName ?? 'Unknown';

    final String enrollmentSource =
        participant.enrollmentSourceName ?? 'Unknown';

    final String enrollmentDate = _formatDate(participant.enrollmentDate);

    final bool isEnrolled =
        participant.enrollmentStatus == 2 ||
        enrollmentStatus.toLowerCase() == 'enrolled';

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        // ==========================================================
        // MAIN CARD GRADIENT
        // ==========================================================
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.24),
            AppColor.formSecondaryColor.withOpacity(0.24),
          ],
        ),

        borderRadius: BorderRadius.circular(18),

        // ==========================================================
        // THEME BORDER
        // ==========================================================
        border: Border.all(color: AppColor.formPrimaryColor.withOpacity(0.15)),

        // ==========================================================
        // SOFT SHADOW
        // ==========================================================
        boxShadow: [
          BoxShadow(
            color: AppColor.formPrimaryColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // AVATAR
          // ======================================================
          Container(
            width: isTablet ? 58 : 52,
            height: isTablet ? 58 : 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.formPrimaryColor.withOpacity(0.16),
                  AppColor.formSecondaryColor.withOpacity(0.16),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.formPrimaryColor.withOpacity(0.15),
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColor.formPrimaryColor,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ======================================================
          // DETAILS
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // NAME + STATUS
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 17 : 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ghostwhite,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    _StatusChip(text: enrollmentStatus, isActive: isEnrolled),
                  ],
                ),

                const SizedBox(height: 7),

                // ==================================================
                // EMAIL
                // ==================================================
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: AppColor.ghostwhite.withOpacity(0.70),
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          color: AppColor.primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // BOTTOM DETAILS
                // ==================================================
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      text: enrollmentDate,
                    ),
                    _InfoChip(
                      icon: Icons.person_add_alt_1_outlined,
                      text: enrollmentSource,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GET INITIALS
  // ============================================================

  String _getInitials(String name) {
    final parts =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((element) => element.isNotEmpty)
            .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Date unavailable';
    }

    try {
      final DateTime date = DateTime.parse(value.toString()).toLocal();

      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return value.toString();
    }
  }
}

// ============================================================================
// STATUS CHIP
// ============================================================================

class _StatusChip extends StatelessWidget {
  final String text;
  final bool isActive;

  const _StatusChip({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
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

          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFO CHIP
// ============================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        // Subtle white overlay on top of the gradient
        color: Colors.white.withOpacity(0.55),

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: AppColor.formPrimaryColor.withOpacity(0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColor.formPrimaryColor.withOpacity(0.75),
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.formPrimaryColor.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY PARTICIPANTS
// ============================================================================

class _EmptyParticipants extends StatelessWidget {
  const _EmptyParticipants();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
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
          // ======================================================
          // EMPTY ICON
          // ======================================================
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.formPrimaryColor.withOpacity(0.14),
                  AppColor.formSecondaryColor.withOpacity(0.14),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 35,
              color: AppColor.formPrimaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // TITLE
          // ======================================================
          const Text(
            'No Participants Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 7),

          // ======================================================
          // DESCRIPTION
          // ======================================================
          Text(
            'There are no enrolled participants for this webinar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.formPrimaryColor.withOpacity(0.70),
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
          hintText: 'Search Participants...',
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

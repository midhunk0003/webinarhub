import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/permission_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/screen/trainer/resource_view_screen.dart';
import 'package:lms/presentation/screen/trainer/widget/course_detail_shimmer.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/languageandther_widget.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/rating_and_student_enroll_widget.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TrainerWebinarCourseDetailPage extends StatefulWidget {
  final String? courseId;
  const TrainerWebinarCourseDetailPage({required this.courseId, Key? key})
    : super(key: key);

  @override
  State<TrainerWebinarCourseDetailPage> createState() =>
      _TrainerWebinarCourseDetailPageState();
}

class _TrainerWebinarCourseDetailPageState
    extends State<TrainerWebinarCourseDetailPage> {
  bool _isDialogShowing = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialData();
    });
  }

  Future<void> _initialData() async {
    print('course id : : : ${widget.courseId}');
    if (!mounted) return;
    final courseDetailProvider = context.read<TrainerCourseProvider>();
    final permissionProvider = context.read<PermissionProvider>();
    await Future.wait([
      courseDetailProvider.getCourseDetailPro(widget.courseId ?? ''),
      courseDetailProvider.getCourseResourceListPro(widget.courseId ?? ''),
      permissionProvider.getPermissionPro(),
    ]);
    if (!mounted) return;
    _handleFailure(courseDetailProvider, permissionProvider);
  }

  void _handleFailure(
    TrainerCourseProvider courseDetailProvider,
    PermissionProvider permissionProvider,
  ) {
    if (_isDialogShowing) return;

    final failures = <Failure>[
      if (courseDetailProvider.failure != null) courseDetailProvider.failure!,
      if (permissionProvider.failure != null) permissionProvider.failure!,
    ];

    if (!mounted || failures.isEmpty) return;

    final failure = failures.first;

    // Ignore network failure
    if (failure is NetworkFailure) {
      return;
    }

    _isDialogShowing = true;

    AppDialogHelper.showFailureDialog(
      context: context,
      failure: failure,
      provider: courseDetailProvider,
      onTap: () {
        courseDetailProvider.clearFailure();
        permissionProvider.clearFailure();
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
      child: Consumer2<TrainerCourseProvider, PermissionProvider>(
        builder: (context, trainerCourseProvider, permissionProvider, _) {
          final failure = trainerCourseProvider.failure;
          if (failure is NetworkFailure) {
            return NetWorkRetry(
              failureMessage:
                  trainerCourseProvider.failure?.message ??
                  "No internet connection",
              onRetry: () async {
                await _initialData();
              },
            );
          }

          final course = trainerCourseProvider.trainerCourseDetail?.data;
          // Get data safely
          final resources =
              trainerCourseProvider.trainerCourseMeterialListModel?.data;
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth > 600;
              return RefreshIndicator(
                onRefresh: () async {
                  await _initialData();
                },
                child:
                    (trainerCourseProvider.isLoading || course == null)
                        ? CourseDetailShimmer(isTablet: isTablet)
                        : (course == null)
                        ? Center(child: Text('No Details'))
                        : SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: isTablet ? 40 : 110),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: isTablet ? 80 : 66),
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

                              SizedBox(height: isTablet ? 35 : 30),

                              // Course title
                              Text(
                                '${course.title ?? ''}',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: isTablet ? 26 : 24,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Course image
                              Container(
                                width: double.infinity,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: AppColor.borderGlassColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child:
                                    (course.thumbnailUrl == null ||
                                            course.thumbnailUrl!.trim().isEmpty)
                                        ? Icon(
                                          Icons.image_outlined,
                                          size: 60,
                                          color: Colors.grey.shade500,
                                        )
                                        : Image.network(
                                          course.thumbnailUrl!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.image_outlined,
                                              size: 60,
                                              color: Colors.grey.shade500,
                                            );
                                          },
                                        ),
                              ),

                              const SizedBox(height: 24),

                              // Overview
                              Text(
                                'Course Overview',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: isTablet ? 22 : 20,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                '${course?.description ?? ''}',
                                style: TextStyle(
                                  color: AppColor.lightgray,
                                  fontSize: isTablet ? 18 : 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Rating
                              RatingAndStudentEnrollWidget(
                                isTablet: isTablet,
                                stundEnrolled:
                                    '${course?.enrolledParticipantCount ?? ''}',
                                onTap: () {
                                  if (!permissionProvider.canViewParticipents) {
                                    if (!permissionProvider
                                        .canViewParticipents) {
                                      AppDialogHelper.showPermissionDeniedDialog(
                                        context: context,
                                        title: "Permission Required",
                                        message:
                                            "You don't have permission to View materials. Please contact your administrator.",
                                      );
                                    }
                                    return;
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    '/viewallparticipents',
                                    arguments: {'courseId': widget.courseId},
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Language / Course type
                              Row(
                                children: [
                                  Expanded(
                                    child: LanguageAndOtherWIdget(
                                      isTablet: isTablet,
                                      svgIcon: 'assets/svg/language.svg',
                                      title: 'Language',
                                      subTitle: '${course?.language ?? ''}',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: LanguageAndOtherWIdget(
                                      isTablet: isTablet,
                                      svgIcon: 'assets/svg/recordedclass.svg',
                                      title: 'Course Type',
                                      subTitle: '${course?.typeName ?? ''}',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: LanguageAndOtherWIdget(
                                      isTablet: isTablet,
                                      svgIcon: 'assets/svg/language.svg',
                                      title: 'PlatForm',
                                      subTitle: '${course?.platformName ?? ''}',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(child: SizedBox.fromSize()),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ================= DATE & TIME =================
                              Text(
                                'Webinar Schedule',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: isTablet ? 22 : 20,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: _WebinarInfoCard(
                                      isTablet: isTablet,
                                      icon: Icons.calendar_month_outlined,
                                      title: 'Start Date',
                                      value: formatWebinarDate(
                                        course?.startDateTime,
                                        course?.endDateTime,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              _WebinarInfoCard(
                                isTablet: isTablet,
                                icon: Icons.timer_outlined,
                                title: 'Duration',
                                value:
                                    '${formatWebinarDuration(course?.startDateTime, course?.endDateTime)}',
                                fullWidth: true,
                              ),

                              // ================= RESOURCES =================
                              const SizedBox(height: 30),
                              Text(
                                'Resources',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: isTablet ? 22 : 20,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              (trainerCourseProvider.isLoadingListOfresource)
                                  ? _ResourceShimmerWidget(isTablet: isTablet)
                                  : (resources == null || resources.isEmpty)
                                  ? Center(
                                    child: Text(
                                      'No resources available',
                                      style: TextStyle(
                                        color: AppColor.lightgray,
                                        fontSize: isTablet ? 15 : 13,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                  )
                                  : Consumer2<
                                    TrainerCourseProvider,
                                    PermissionProvider
                                  >(
                                    builder: (
                                      context,
                                      trainerCourseProvider,
                                      permissionProvider,
                                      child,
                                    ) {
                                      final resources =
                                          trainerCourseProvider
                                              .trainerCourseMeterialListModel
                                              ?.data ??
                                          [];

                                      if (trainerCourseProvider
                                          .isLoadingListOfresource) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (resources.isEmpty) {
                                        return Center(
                                          child: Text(
                                            'No resources available',
                                            style: TextStyle(
                                              color: AppColor.ghostwhite,
                                              fontFamily: 'Urbanist',
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,

                                        itemCount: resources.length,

                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 10);
                                        },

                                        itemBuilder: (context, index) {
                                          final resource = resources[index];

                                          final fileName =
                                              resource.fileName ??
                                              'resource.pdf';

                                          final fileUrl = resource.fileUrl;

                                          /// Check whether this resource is
                                          /// currently downloading.
                                          final isDownloading =
                                              trainerCourseProvider
                                                  .downloadingFileName ==
                                              fileName;

                                          return _ResourceWidget(
                                            isTablet: isTablet,

                                            title: fileName,

                                            subtitle:
                                                '${resource.fileType ?? 'PDF'} • '
                                                '${formatFileSize(resource.fileSize)}',

                                            icon: getFileIcon(
                                              resources[index].fileType,
                                            ),

                                            isDownloading: isDownloading,

                                            downloadProgress:
                                                isDownloading
                                                    ? trainerCourseProvider
                                                        .downloadProgress
                                                    : 0.0,
                                            // Provider controls the index
                                            isDeleting:
                                                trainerCourseProvider
                                                    .deletingIndex ==
                                                index,
                                            onTap: () async {
                                              if (!permissionProvider
                                                  .canViewMaterials) {
                                                if (!permissionProvider
                                                    .canViewMaterials) {
                                                  AppDialogHelper.showPermissionDeniedDialog(
                                                    context: context,
                                                    title:
                                                        "Permission Required",
                                                    message:
                                                        "You don't have permission to View materials. Please contact your administrator.",
                                                  );
                                                }
                                                return;
                                              }
                                              if (fileUrl == null ||
                                                  fileUrl.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'File URL is missing',
                                                    ),
                                                  ),
                                                );

                                                return;
                                              }

                                              // final result =
                                              //     await trainerCourseProvider
                                              //         .downloadResource(
                                              //           url: fileUrl,
                                              //           fileName: fileName,

                                              //           // If required:
                                              //           // token: authProvider.token,
                                              //         );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          ResourceViewerScreen(
                                                            fileUrl: fileUrl,
                                                            fileName: fileName,
                                                            fileType:
                                                                resource
                                                                    .fileType,
                                                          ),
                                                ),
                                              );
                                              // if (!context.mounted) {
                                              //   return;
                                              // }
                                              // switch (result) {
                                              //   case DownloadResult.success:
                                              //     AppDialogHelper.showSuccessDialog(
                                              //       context: context,
                                              //       message:
                                              //           '$fileName downloaded successfully.',
                                              //       provider:
                                              //           trainerCourseProvider,
                                              //     );
                                              //     break;

                                              //   case DownloadResult.failed:
                                              //     AppDialogHelper.showSuccessDialog(
                                              //       context: context,
                                              //       message:
                                              //           'Failed to download $fileName.',
                                              //       provider:
                                              //           trainerCourseProvider,
                                              //     );
                                              //     break;

                                              //   case DownloadResult
                                              //       .alreadyDownloading:
                                              //     ScaffoldMessenger.of(
                                              //       context,
                                              //     ).showSnackBar(
                                              //       const SnackBar(
                                              //         content: Text(
                                              //           'Another file is currently downloading.',
                                              //         ),
                                              //       ),
                                              //     );
                                              //     break;
                                              // }
                                            },
                                            onDelete: () async {
                                              print('delete');
                                              if (!permissionProvider
                                                  .canDeleteMaterials) {
                                                if (!permissionProvider
                                                    .canDeleteMaterials) {
                                                  AppDialogHelper.showPermissionDeniedDialog(
                                                    context: context,
                                                    title:
                                                        "Permission Required",
                                                    message:
                                                        "You don't have permission to Delete materials. Please contact your administrator.",
                                                  );
                                                }
                                                return;
                                              }
                                              final provider =
                                                  trainerCourseProvider;

                                              await provider.deleteResourcePro(
                                                courseId:
                                                    resource.id.toString(),
                                                index: index,
                                              );

                                              if (!context.mounted) return;

                                              // Failure
                                              if (provider.failure != null) {
                                                AppDialogHelper.showFailureDialog(
                                                  context: context,
                                                  failure: provider.failure,
                                                  provider: provider,
                                                  onTap: () {
                                                    provider.clearFailure();
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                return;
                                              }

                                              // Success
                                              if (provider.success != null) {
                                                AppDialogHelper.showSuccessDialog(
                                                  context: context,
                                                  message:
                                                      provider.success!.message,
                                                  provider: provider,
                                                  onTap: () {
                                                    // provider.clearFailure();
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                // Refresh resource list after successful upload
                                                await provider
                                                    .getCourseResourceListPro(
                                                      course.id.toString(),
                                                    );
                                                // getCourseResourceListPro clears success,
                                                // so set it again after refreshing.
                                                provider.clearFailure();
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),

                              const SizedBox(height: 24),
                              // ================= UPLOAD CONTENT =================
                              Text(
                                'Course Content',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: isTablet ? 22 : 20,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Consumer2<
                                      TrainerCourseProvider,
                                      PermissionProvider
                                    >(
                                      builder: (
                                        context,
                                        trainerCourseProvider,
                                        permissionProvider,
                                        _,
                                      ) {
                                        final selectedFile =
                                            trainerCourseProvider.selectedFile;

                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _UploadContentCard(
                                              isTablet: isTablet,
                                              icon:
                                                  selectedFile != null
                                                      ? Icons
                                                          .description_outlined
                                                      : Icons
                                                          .picture_as_pdf_outlined,
                                              title:
                                                  selectedFile != null
                                                      ? 'PDF Selected'
                                                      : 'Upload PDF',
                                              subtitle:
                                                  selectedFile != null
                                                      ? selectedFile.name
                                                      : 'Add course PDF resource',
                                              iconColor:
                                                  selectedFile != null
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                              onTap:
                                                  trainerCourseProvider
                                                          .isUploadingResource
                                                      ? () {}
                                                      : () async {
                                                        if (!permissionProvider
                                                            .canUploadMaterials) {
                                                          AppDialogHelper.showPermissionDeniedDialog(
                                                            context: context,
                                                            title:
                                                                "Permission Required",
                                                            message:
                                                                "You don't have permission to upload materials. Please contact your administrator.",
                                                          );
                                                          return;
                                                        }

                                                        await trainerCourseProvider
                                                            .pickAndUploadFile(
                                                              context,
                                                            );
                                                      },
                                            ),

                                            // Show upload button after selecting file
                                            if (selectedFile != null) ...[
                                              const SizedBox(height: 12),

                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  onPressed:
                                                      trainerCourseProvider
                                                              .isUploadingResource
                                                          ? null
                                                          : () async {
                                                            final provider =
                                                                trainerCourseProvider;

                                                            final filePath =
                                                                selectedFile
                                                                    .path;

                                                            if (filePath ==
                                                                    null ||
                                                                filePath
                                                                    .isEmpty) {
                                                              return;
                                                            }

                                                            await provider
                                                                .uploadResourcePro(
                                                                  courseId:
                                                                      course.id
                                                                          .toString(),
                                                                  file:
                                                                      filePath,
                                                                );

                                                            if (!context
                                                                .mounted)
                                                              return;

                                                            // ================= SUCCESS =================

                                                            print(
                                                              'ssssssssssssssssssssssssss : ${provider.success?.message}',
                                                            );
                                                            if (provider
                                                                    .success !=
                                                                null) {
                                                              AppDialogHelper.showSuccessDialog(
                                                                context:
                                                                    context,
                                                                message:
                                                                    provider
                                                                        .success!
                                                                        .message ??
                                                                    'Resource uploaded successfully',
                                                                provider:
                                                                    provider,
                                                                onTap: () {
                                                                  // provider.clearFailure();
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                              );
                                                              // Refresh resource list after successful upload
                                                              await provider
                                                                  .getCourseResourceListPro(
                                                                    course.id
                                                                        .toString(),
                                                                  );
                                                              // getCourseResourceListPro clears success,
                                                              // so set it again after refreshing.
                                                              // Clear selected file
                                                              provider
                                                                  .clearSelectedFile();
                                                            }
                                                            // ================= FAILURE =================
                                                            else if (provider
                                                                    .failure !=
                                                                null) {
                                                              AppDialogHelper.showFailureDialog(
                                                                context:
                                                                    context,
                                                                failure:
                                                                    provider
                                                                        .failure,
                                                                provider:
                                                                    provider,
                                                                onTap: () {
                                                                  provider
                                                                      .clearFailure();
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          },
                                                  icon:
                                                      trainerCourseProvider
                                                              .isUploadingResource
                                                          ? const SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          )
                                                          : const Icon(
                                                            Icons
                                                                .cloud_upload_outlined,
                                                          ),
                                                  label: Text(
                                                    trainerCourseProvider
                                                            .isUploadingResource
                                                        ? 'Uploading...'
                                                        : 'Upload File',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: SizedBox.fromSize(),

                                    //  _UploadContentCard(
                                    //   isTablet: isTablet,
                                    //   icon: Icons.video_library_outlined,
                                    //   title: 'Recorded Video',
                                    //   subtitle: 'Upload recorded class',
                                    //   iconColor: Colors.blueAccent,
                                    //   onTap: () async {
                                    //     await trainerCourseProvider
                                    //         .pickAndUploadFile(context);
                                    //   },
                                    // ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 36),
                              // Join button
                              CommonCustomeButtonWidget(
                                isTablet: isTablet,
                                text: "Join To Train",
                                onTap: () async {
                                  await trainerCourseProvider.launchZoomMeeting(
                                    course.meetingLink ?? '',
                                  );
                                },
                              ),

                              const SizedBox(height: 30),
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

// ============================================================
// WEBINAR INFO CARD
// ============================================================

class _WebinarInfoCard extends StatelessWidget {
  final bool isTablet;
  final IconData icon;
  final String title;
  final String value;
  final bool fullWidth;

  const _WebinarInfoCard({
    required this.isTablet,
    required this.icon,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(isTablet ? 18 : 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48 : 42,
            height: isTablet ? 48 : 42,
            decoration: BoxDecoration(
              color: AppColor.formPrimaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColor.ghostwhite,
              size: isTablet ? 24 : 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: isTablet ? 14 : 12,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: isTablet ? 17 : 15,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
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

// ============================================================
// RESOURCE WIDGET
// ============================================================
class _ResourceWidget extends StatelessWidget {
  final bool isTablet;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  /// Delete callback
  final VoidCallback onDelete;

  /// Whether this particular resource is downloading.
  final bool isDownloading;

  /// Download progress 0.0 - 1.0.
  final double downloadProgress;

  final bool isDeleting;

  const _ResourceWidget({
    required this.isTablet,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onDelete,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDownloading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 14,
          vertical: isTablet ? 15 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // ==================================================
            // FILE ICON
            // ==================================================
            Container(
              width: isTablet ? 48 : 42,
              height: isTablet ? 48 : 42,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.redAccent,
                size: isTablet ? 25 : 22,
              ),
            ),

            const SizedBox(width: 12),

            // ==================================================
            // TITLE + SUBTITLE + PROGRESS
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.ghostwhite,
                      fontSize: isTablet ? 16 : 14,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.lightgray,
                      fontSize: isTablet ? 13 : 12,
                      fontFamily: 'Urbanist',
                    ),
                  ),

                  // ==================================================
                  // DOWNLOAD PROGRESS
                  // ==================================================
                  if (isDownloading) ...[
                    const SizedBox(height: 8),

                    LinearProgressIndicator(
                      value: downloadProgress,
                      color: AppColor.primaryBlueDark,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${(downloadProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: AppColor.lightgray,
                        fontSize: 11,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // DOWNLOAD BUTTON / PROGRESS
            // ==================================================
            if (isDownloading)
              SizedBox(
                width: isTablet ? 30 : 26,
                height: isTablet ? 30 : 26,
                child: CircularProgressIndicator(
                  color: AppColor.primaryBlueDark,
                  value: downloadProgress == 0 ? null : downloadProgress,
                  strokeWidth: 2.5,
                ),
              )
            else
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  Icons.visibility_outlined,
                  color: AppColor.ghostwhite,
                  size: isTablet ? 25 : 22,
                ),
              ),

            // ==================================================
            // DELETE BUTTON
            // ==================================================
            (isDeleting)
                ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: isTablet ? 24 : 21,
                    height: isTablet ? 24 : 21,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.redAccent,
                    ),
                  ),
                )
                : IconButton(
                  onPressed: isDownloading ? null : onDelete,
                  tooltip: 'Delete',
                  icon: Icon(
                    Icons.delete_outline,
                    color:
                        isDownloading
                            ? AppColor.lightgray.withOpacity(0.3)
                            : Colors.redAccent,
                    size: isTablet ? 24 : 21,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _UploadContentCard extends StatelessWidget {
  final bool isTablet;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _UploadContentCard({
    required this.isTablet,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isTablet ? 52 : 46,
              height: isTablet ? 52 : 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: isTablet ? 27 : 24),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: TextStyle(
                color: AppColor.ghostwhite,
                fontSize: isTablet ? 17 : 15,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.lightgray,
                fontSize: isTablet ? 13 : 12,
                fontFamily: 'Urbanist',
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 11 : 9),
              decoration: BoxDecoration(
                color: AppColor.formPrimaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_outlined,
                    color: AppColor.ghostwhite,
                    size: isTablet ? 20 : 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Upload',
                    style: TextStyle(
                      color: AppColor.ghostwhite,
                      fontSize: isTablet ? 14 : 13,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
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

class _ResourceShimmerWidget extends StatelessWidget {
  final bool isTablet;

  const _ResourceShimmerWidget({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.06),
      highlightColor: Colors.white.withOpacity(0.12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 14,
          vertical: isTablet ? 15 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: isTablet ? 48 : 42,
              height: isTablet ? 48 : 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 12),

            // Title + subtitle placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: isTablet ? 16 : 14,
                    width: isTablet ? 180 : 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: isTablet ? 13 : 12,
                    width: isTablet ? 120 : 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Download icon placeholder
            Container(
              width: isTablet ? 25 : 22,
              height: isTablet ? 25 : 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatFileSize(dynamic size) {
  if (size == null) return '0 KB';

  final bytes = double.tryParse(size.toString()) ?? 0;

  if (bytes < 1024) {
    return '${bytes.toStringAsFixed(0)} B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

IconData getFileIcon(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf_outlined;

    case 'doc':
    case 'docx':
      return Icons.description_outlined;

    case 'ppt':
    case 'pptx':
      return Icons.slideshow_outlined;

    case 'xls':
    case 'xlsx':
      return Icons.table_chart_outlined;

    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
      return Icons.image_outlined;

    default:
      return Icons.insert_drive_file_outlined;
  }
}

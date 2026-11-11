import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/services/generateZoomJwt.dart';
import 'package:lms/core/services/zoom_meating_data.dart';
import 'package:lms/presentation/provider/payment_provider.dart';
import 'package:lms/presentation/provider/permission_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_course_provider.dart';
import 'package:lms/presentation/screen/google_drive_video_player.dart';
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
  static const platform = MethodChannel('lms.video.player');
  static const zoomPlatform = MethodChannel('lms.zoom');
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
    final userCourseProvider = context.read<UserCourseProvider>();

    await Future.wait([
      courseDetailProvider.getCourseDetailPro(widget.courseId ?? ''),
      courseDetailProvider.getCourseResourceListPro(widget.courseId ?? ''),
      courseDetailProvider.getRecordingsListPro(widget.courseId ?? ''),
      permissionProvider.getPermissionPro(),
    ]);
    if (!mounted) return;
    _handleFailure(
      courseDetailProvider,
      permissionProvider,
      userCourseProvider,
    );
  }

  void _handleFailure(
    TrainerCourseProvider courseDetailProvider,
    PermissionProvider permissionProvider,
    UserCourseProvider userCourseProvider,
  ) {
    if (_isDialogShowing) return;

    final failures = <Failure>[
      if (courseDetailProvider.failure != null) courseDetailProvider.failure!,
      if (permissionProvider.failure != null) permissionProvider.failure!,
      if (userCourseProvider.failure != null) userCourseProvider.failure!,
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
        userCourseProvider.clearFailure();
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
      child: Consumer3<
        TrainerCourseProvider,
        PermissionProvider,
        UserCourseProvider
      >(
        builder: (
          context,
          trainerCourseProvider,
          permissionProvider,
          userCourseProvider,
          _,
        ) {
          final failure =
              trainerCourseProvider.failure ?? permissionProvider.failure;
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

          // recordings
          final recordings =
              trainerCourseProvider.trainerWebinarRecordingsModel?.data;

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
                                          '${ApiEndPoint.serverUrl}${course.thumbnailUrl!}',
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
                                // stundEnrolled:
                                //     '${course?.enrolledParticipantCount ?? ''}',
                                maxParticipants: course.maxParticipants ?? '0',
                                onTap: () {
                                  if (!permissionProvider.canViewParticipents) {
                                    if (!permissionProvider
                                        .canViewParticipents) {
                                      AppDialogHelper.showPermissionDeniedDialog(
                                        context: context,
                                        title: "Permission Required",
                                        message:
                                            "You don't have permission to View Students. Please contact your administrator.",
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
                                                  onTap: () async {
                                                    provider.clearSuccess();
                                                    Navigator.pop(context);
                                                    // Refresh resource list after successful upload
                                                    await provider
                                                        .getCourseResourceListPro(
                                                          course.id.toString(),
                                                        );
                                                    // getCourseResourceListPro clears success,
                                                    // so set it again after refreshing.
                                                    provider.clearFailure();
                                                    print(
                                                      'Resource deleted successfully',
                                                    );
                                                  },
                                                );
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
                                              // Dynamic icon based on file extension
                                              icon:
                                                  selectedFile != null
                                                      ? trainerCourseProvider
                                                          .selectedFileIcon
                                                      : Icons
                                                          .picture_as_pdf_outlined,
                                              // Dynamic title based on file extension
                                              title:
                                                  selectedFile != null
                                                      ? '${trainerCourseProvider.extensionLabel(trainerCourseProvider.selectedFileExtension)} Selected'
                                                      : 'Upload PDF | Image',
                                              // Show selected filename
                                              subtitle:
                                                  selectedFile != null
                                                      ? trainerCourseProvider
                                                          .selectedFileName
                                                      : 'Add course PDF resource',
                                              // Dynamic color based on file extension
                                              iconColor:
                                                  selectedFile != null
                                                      ? trainerCourseProvider
                                                          .selectedFileColor
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
                                              CommonCustomeButtonWidget(
                                                isTablet: isTablet,
                                                text:
                                                    trainerCourseProvider
                                                            .isUploadingResource
                                                        ? 'Uploading...'
                                                        : 'Submit',
                                                icon:
                                                    Icons.cloud_upload_outlined,
                                                onTap:
                                                    trainerCourseProvider
                                                            .isUploadingResource
                                                        ? null
                                                        : () async {
                                                          final provider =
                                                              trainerCourseProvider;

                                                          final filePath =
                                                              selectedFile.path;

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
                                                                file: filePath,
                                                              );

                                                          if (!context.mounted)
                                                            return;

                                                          // ================= SUCCESS =================

                                                          print(
                                                            'ssssssssssssssssssssssssss : ${provider.success?.message}',
                                                          );
                                                          if (provider
                                                                  .success !=
                                                              null) {
                                                            AppDialogHelper.showSuccessDialog(
                                                              context: context,
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
                                                              context: context,
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

                              const SizedBox(height: 24),
                              // ================= UPLOAD CONTENT =================
                              Text(
                                'Recordings',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: isTablet ? 22 : 20,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 14),

                              (trainerCourseProvider
                                          .isLoadingListOfRecordings ||
                                      recordings == null)
                                  ? webinarRecordingsShimmer()
                                  : (recordings.isEmpty)
                                  ? SizedBox.shrink()
                                  : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 0.85,
                                        ),
                                    itemCount:
                                        trainerCourseProvider
                                            .trainerWebinarRecordingsModel
                                            ?.data
                                            ?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final recording =
                                          trainerCourseProvider
                                              .trainerWebinarRecordingsModel
                                              ?.data?[index];

                                      return GestureDetector(
                                        onTap: () async {
                                          // Play recording here
                                          if (!permissionProvider
                                              .canViewWebinarRecordings) {
                                            AppDialogHelper.showPermissionDeniedDialog(
                                              context: context,
                                              title: "Permission Required",
                                              message:
                                                  "You don't have permission to View materials. Please contact your administrator.",
                                            );

                                            return;
                                          }
                                          final videoUrl =
                                              recording?.recordingUrl?.trim() ??
                                              '';
                                          print('video url  : ${videoUrl}');
                                          if (videoUrl.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Video URL is missing',
                                                ),
                                              ),
                                            );

                                            return;
                                          }

                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder:
                                          //         (_) => GoogleDriveVideoPlayer(
                                          //           videoUrl: videoUrl,
                                          //           title:
                                          //               recording?.title ??
                                          //               'Recording',
                                          //         ),
                                          //   ),
                                          // );
                                          await openNativePlayer(
                                            videoUrl:
                                                recording?.recordingUrl ?? '',
                                            title:
                                                "Trading Forex Exchange Updated",
                                          );
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder:
                                          //         (_) => YoutubePlayerScreen(
                                          //           videoId:
                                          //               recording
                                          //                   ?.recordingUrl ??
                                          //               '',
                                          //           title:
                                          //               recording?.title ?? '',
                                          //         ),
                                          //   ),
                                          // );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColor.formPrimaryColor
                                                    .withOpacity(0.24),
                                                AppColor.formSecondaryColor
                                                    .withOpacity(0.24),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: AppColor.formBorderColor
                                                  .withOpacity(0.24),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.4,
                                                ),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Video / Play area
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: AppColor.goldDark,
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                  ),
                                                  child: const Center(
                                                    child: CircleAvatar(
                                                      radius: 28,
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Title
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Text(
                                                  recording?.title ?? 'Forex',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColor.glassHighlight,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              const SizedBox(height: 36),

                              // Join button
                              // CommonCustomeButtonWidget(
                              //   isTablet: isTablet,
                              //   text: "Join To Train",
                              //   onTap: () async {
                              //     await trainerCourseProvider.launchZoomMeeting(
                              //       course.meetingLink ?? '',
                              //     );
                              //   },
                              // ),

                              // Join button
                              CommonCustomeButtonWidget(
                                isTablet: false,
                                text:
                                    userCourseProvider.isLoadingJoinData
                                        ? 'Please wait...'
                                        : 'Join',

                                onTap:
                                    userCourseProvider.isLoadingJoinData
                                        ? null
                                        : () async {
                                          try {
                                            await userCourseProvider
                                                .userJoinDataPro(
                                                  widget.courseId.toString(),
                                                  '2',
                                                );
                                            print(
                                              'Join Webinar Result: ${userCourseProvider.success}',
                                            );
                                            if (!mounted) return;

                                            if (userCourseProvider
                                                    .userJoinWebinarModel !=
                                                null) {
                                              final meetingUrl =
                                                  userCourseProvider
                                                      .userJoinWebinarModel
                                                      ?.data
                                                      ?.meetingUrl ??
                                                  '';

                                              final userNameApi =
                                                  userCourseProvider
                                                      .userJoinWebinarModel
                                                      ?.data
                                                      ?.userName ??
                                                  '';

                                              final meetingIdApi =
                                                  userCourseProvider
                                                      .userJoinWebinarModel
                                                      ?.data
                                                      ?.meetingId ??
                                                  '';

                                              final meetingPassApi =
                                                  userCourseProvider
                                                      .userJoinWebinarModel
                                                      ?.data
                                                      ?.meetingPassword ??
                                                  '';

                                              final meetingJwtApi =
                                                  userCourseProvider
                                                      .userJoinWebinarModel
                                                      ?.data
                                                      ?.sdkJwt ??
                                                  '';

                                              // if (meetingUrl.isEmpty) {
                                              //   ScaffoldMessenger.of(
                                              //     context,
                                              //   ).showSnackBar(
                                              //     const SnackBar(
                                              //       content: Text(
                                              //         'Unable to open the webinar. Meeting link not found.',
                                              //       ),
                                              //     ),
                                              //   );
                                              //   return;
                                              // }

                                              // await userCourseProvider
                                              //     .launchZoomMeeting(
                                              //       meetingUrl,
                                              //     );
                                              // =====================================================
                                              // YOUR ZOOM URL
                                              // =====================================================

                                              // const zoomUrl =
                                              //     "https://app.zoom.us/wc/84228660846/start?fromPWA=1&pwd=3KNfc1lTxRv8XHK6rxuHSyvGiRH0Xa.1";

                                              const zoomUrl =
                                                  "https://zoom.us/j/95178322697?pwd=ydpyvnyR5kbIf6sxnWeNKLEtwpK3I7.1";
                                              final zoomData = parseZoomUrl(
                                                zoomUrl,
                                              );

                                              // =====================================================
                                              // VALIDATE MEETING ID
                                              // =====================================================

                                              if (zoomData
                                                  .meetingNumber
                                                  .isEmpty) {
                                                debugPrint(
                                                  "Zoom Meeting ID not found",
                                                );
                                                return;
                                              }

                                              // =====================================================
                                              // USER NAME
                                              // =====================================================

                                              const userName = "Test Student";

                                              // =====================================================
                                              // GENERATE ZOOM MEETING SDK JWT
                                              // =====================================================

                                              // final jwt = generateZoomJwt(
                                              //   clientId:
                                              //       "0qw_HEqbTJSsU1wSbPThw",
                                              //   clientSecret:
                                              //       "Fh1lhH5qMVbFHHOrFACJMf3CrcRRGtEu",
                                              //   meetingNumber:
                                              //       '${zoomData.meetingNumber}',
                                              // );

                                              // final jwt = generateZoomJwt(
                                              //   clientId:
                                              //       "ThCVsAiWRSag9kEVQbzZiw",
                                              //   clientSecret:
                                              //       "eE47oI40X2hU8vIjs8iY1hWvjaCF9Y39",
                                              //   meetingNumber:
                                              //       '${zoomData.meetingNumber}',
                                              // );

                                              final jwt = generateZoomJwt(
                                                clientId:
                                                    "ZZNZFQB3QWwJELuqS3L_Q",
                                                clientSecret:
                                                    "SWWlGF3Ng6rIPWjr7l8yMG0L3stpfPoQ",
                                                meetingNumber:
                                                    '${zoomData.meetingNumber}',
                                              );

                                              debugPrint(
                                                "Zoom Meeting ID : ${zoomData.meetingNumber}",
                                              );

                                              debugPrint(
                                                "Zoom Password: ${zoomData.password}",
                                              );

                                              debugPrint(
                                                "jwt print.......: $jwt",
                                              );

                                              // =====================================================
                                              // SEND TO ANDROID
                                              // =====================================================

                                              try {
                                                final bool?
                                                result = await zoomPlatform
                                                    .invokeMethod<bool>(
                                                      "joinZoomMeeting",
                                                      {
                                                        "meetingNumber":
                                                            '${meetingIdApi}',
                                                        "meetingPassword":
                                                            '${meetingPassApi}',
                                                        "userName": userNameApi,
                                                        "jwt": meetingJwtApi,
                                                      },
                                                    );

                                                // final bool? result =
                                                //     await zoomPlatform
                                                //         .invokeMethod<bool>(
                                                //           "joinZoomMeeting",
                                                //           {
                                                //             "meetingNumber":
                                                //                 meetingIdApi,
                                                //             "meetingPassword":
                                                //                 meetingPassApi,
                                                //             "userName":
                                                //                 userName,
                                                //             "jwt": jwt,
                                                //           },
                                                //         );

                                                if (!mounted) {
                                                  return;
                                                }

                                                debugPrint(
                                                  "Zoom finished. Result = $result",
                                                );

                                                // Refresh the Detail Page after returning from Zoom.
                                                await _initialData();

                                                if (!mounted) {
                                                  return;
                                                }

                                                setState(() {});
                                              } on PlatformException catch (e) {
                                                debugPrint(
                                                  "Zoom error: ${e.code} - ${e.message}",
                                                );

                                                if (!mounted) {
                                                  return;
                                                }

                                                // Stay on the existing Detail Page.
                                                // Optionally show an error message.
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.message ??
                                                          "Unable to join Zoom meeting",
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else if (userCourseProvider
                                                    .failure !=
                                                null) {
                                              // IMPORTANT: // Here you need to identify whether the API failure // means "payment required".
                                              // // // Replace this condition with your actual API // errorCode/status/message.
                                              final failureMessage =
                                                  userCourseProvider
                                                      .failure
                                                      ?.message
                                                      ?.toString() ??
                                                  '';
                                              final lowerMessage =
                                                  failureMessage.toLowerCase();
                                              debugPrint(
                                                'Join API Failure: $failureMessage',
                                              );

                                              _handleFailure(
                                                trainerCourseProvider,
                                                permissionProvider,
                                                userCourseProvider,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Something went wrong. Please try again.',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (!mounted) return;

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Unable to join the webinar. Please try again.',
                                                ),
                                              ),
                                            );

                                            debugPrint(
                                              'Join webinar error: $e',
                                            );
                                          }
                                        },
                              ),

                              // CommonCustomeButtonWidget(
                              //   isTablet: isTablet,
                              //   text: "Join To Train",
                              //   onTap: () async {
                              //     // =====================================================
                              //     // YOUR ZOOM URL
                              //     // =====================================================

                              //     const zoomUrl =
                              //         "https://app.zoom.us/wc/81150519342/start?fromPWA=1&pwd=fnYCVNOw1pF5WRdU3uQWDRX69ZBo5x.1";

                              //     final zoomData = parseZoomUrl(zoomUrl);

                              //     // =====================================================
                              //     // VALIDATE MEETING ID
                              //     // =====================================================

                              //     if (zoomData.meetingNumber.isEmpty) {
                              //       debugPrint("Zoom Meeting ID not found");
                              //       return;
                              //     }

                              //     // =====================================================
                              //     // USER NAME
                              //     // =====================================================

                              //     const userName = "Test Student";

                              //     // =====================================================
                              //     // GENERATE ZOOM MEETING SDK JWT
                              //     // =====================================================

                              //     final jwt = generateZoomJwt(
                              //       clientId: "0qw_HEqbTJSsU1wSbPThw",
                              //       clientSecret:
                              //           "Fh1lhH5qMVbFHHOrFACJMf3CrcRRGtEu",
                              //       meetingNumber: ' ${zoomData.meetingNumber}',
                              //     );

                              //     debugPrint(
                              //       "Zoom Meeting ID: ${zoomData.meetingNumber}",
                              //     );

                              //     debugPrint(
                              //       "Zoom Password: ${zoomData.password}",
                              //     );

                              //     debugPrint("jwt print: $jwt");

                              //     // =====================================================
                              //     // SEND TO ANDROID
                              //     // =====================================================

                              //     try {
                              //       final bool? result = await zoomPlatform
                              //           .invokeMethod<bool>("joinZoomMeeting", {
                              //             "meetingNumber":
                              //                 zoomData.meetingNumber,
                              //             "meetingPassword": zoomData.password,
                              //             "userName": userName,
                              //             "jwt": jwt,
                              //           });

                              //       if (!mounted) {
                              //         return;
                              //       }

                              //       debugPrint(
                              //         "Zoom finished. Result = $result",
                              //       );

                              //       // Refresh the Detail Page after returning from Zoom.
                              //       await _initialData();

                              //       if (!mounted) {
                              //         return;
                              //       }

                              //       setState(() {});
                              //     } on PlatformException catch (e) {
                              //       debugPrint(
                              //         "Zoom error: ${e.code} - ${e.message}",
                              //       );

                              //       if (!mounted) {
                              //         return;
                              //       }

                              //       // Stay on the existing Detail Page.
                              //       // Optionally show an error message.
                              //       ScaffoldMessenger.of(context).showSnackBar(
                              //         SnackBar(
                              //           content: Text(
                              //             e.message ??
                              //                 "Unable to join Zoom meeting",
                              //           ),
                              //         ),
                              //       );
                              //     }
                              //   },
                              // ),
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

  Future<void> openNativePlayer({
    required String videoUrl,
    required String title,
  }) async {
    try {
      final convertedUrl = convertGoogleDriveUrl(videoUrl);

      debugPrint('Original URL: $videoUrl');
      debugPrint('Converted URL: $convertedUrl');

      await platform.invokeMethod('openVideoPlayer', {
        "videoUrl": convertedUrl,
        "title": title,
        "lastPosition": 0,
      });
    } on PlatformException catch (e) {
      debugPrint("Error: ${e.message}");
    }
  }

  String convertGoogleDriveUrl(String url) {
    final regex = RegExp(r'drive\.google\.com/file/d/([^/]+)');

    final match = regex.firstMatch(url);

    if (match != null) {
      final fileId = match.group(1);

      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }

    // Already converted / normal video URL
    return url;
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
                      color: AppColor.goldDark,
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
                  color: AppColor.goldDark,
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

Widget webinarRecordingsShimmer() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    itemCount: 6,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
    ),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / video placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
              ),

              // Title placeholder
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

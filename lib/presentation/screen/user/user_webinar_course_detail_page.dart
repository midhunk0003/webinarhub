import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/user_course_detail_model/user_course_detail_model.dart';
import 'package:lms/presentation/provider/permission_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_course_provider.dart';
import 'package:lms/presentation/screen/trainer/resource_view_screen.dart';
import 'package:lms/presentation/screen/trainer/widget/course_detail_shimmer.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/languageandther_widget.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/rating_and_student_enroll_widget.dart';
import 'package:lms/presentation/screen/user/my_course_screen/youtube_play_screen.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/formatWebinarDate.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class UserWebinarCourseDetailPage extends StatefulWidget {
  final String? courseId;
  const UserWebinarCourseDetailPage({required this.courseId, Key? key})
    : super(key: key);

  @override
  State<UserWebinarCourseDetailPage> createState() =>
      _UserWebinarCourseDetailPageState();
}

class _UserWebinarCourseDetailPageState
    extends State<UserWebinarCourseDetailPage> {
  static const platform = MethodChannel('lms.video.player');
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
    final courseDetailProvider = context.read<UserCourseProvider>();
    final permissionProvider = context.read<PermissionProvider>();
    await Future.wait([
      courseDetailProvider.getCourseDetailPro(widget.courseId ?? ''),
      courseDetailProvider.getCourseResourceListPro(widget.courseId ?? ''),
      courseDetailProvider.getRecordingsListPro(widget.courseId ?? ''),
      permissionProvider.getPermissionPro(),
    ]);
    if (!mounted) return;
    _handleFailure(courseDetailProvider, permissionProvider);
  }

  void _handleFailure(
    UserCourseProvider courseDetailProvider,
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
      child: Consumer2<UserCourseProvider, PermissionProvider>(
        builder: (context, userCourseProvider, permissionProvider, _) {
          final failure = userCourseProvider.failure;
          if (failure is NetworkFailure) {
            return NetWorkRetry(
              failureMessage:
                  userCourseProvider.failure?.message ??
                  "No internet connection",
              onRetry: () async {
                await _initialData();
              },
            );
          }

          final course = userCourseProvider.courseDetailModel?.data;
          // Get data safely
          final resources =
              userCourseProvider.userCourseMeterialListModel?.data;

          // recordings
          final recordings =
              userCourseProvider.userWebinarRecordingsModel?.data;
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth > 600;
              return RefreshIndicator(
                onRefresh: () async {
                  await _initialData();
                },
                child:
                    (userCourseProvider.isLoading || course == null)
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
                                    AppDialogHelper.showPermissionDeniedDialog(
                                      context: context,
                                      title: "Permission Required",
                                      message:
                                          "You don't have permission to View materials. Please contact your administrator.",
                                    );

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
                                  Expanded(
                                    child: LanguageAndOtherWIdget(
                                      isTablet: isTablet,
                                      svgIcon: 'assets/svg/language.svg',
                                      title: 'Trainer Name',
                                      subTitle: '${course?.trainerName ?? ''}',
                                    ),
                                  ),
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
                              (userCourseProvider.isLoadingListOfresource)
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
                                    UserCourseProvider,
                                    PermissionProvider
                                  >(
                                    builder: (
                                      context,
                                      userCourseProvider,
                                      permissionProvider,
                                      child,
                                    ) {
                                      final resources =
                                          userCourseProvider
                                              .userCourseMeterialListModel
                                              ?.data ??
                                          [];

                                      if (userCourseProvider
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
                                              userCourseProvider
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
                                                    ? userCourseProvider
                                                        .downloadProgress
                                                    : 0.0,
                                            // Provider controls the index
                                            isDeleting:
                                                userCourseProvider
                                                    .deletingIndex ==
                                                index,
                                            onTap: () async {
                                              if (!permissionProvider
                                                  .canViewMaterials) {
                                                AppDialogHelper.showPermissionDeniedDialog(
                                                  context: context,
                                                  title: "Permission Required",
                                                  message:
                                                      "You don't have permission to View materials. Please contact your administrator.",
                                                );
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
                                              // print('delete');
                                              // if (!permissionProvider
                                              //     .canDeleteMaterials) {
                                              //   if (!permissionProvider
                                              //       .canDeleteMaterials) {
                                              //     AppDialogHelper.showPermissionDeniedDialog(
                                              //       context: context,
                                              //       title:
                                              //           "Permission Required",
                                              //       message:
                                              //           "You don't have permission to Delete materials. Please contact your administrator.",
                                              //     );
                                              //   }
                                              //   return;
                                              // }
                                              // final provider =
                                              //     userCourseProvider;

                                              // await provider.deleteResourcePro(
                                              //   courseId:
                                              //       resource.id.toString(),
                                              //   index: index,
                                              // );

                                              // if (!context.mounted) return;

                                              // // Failure
                                              // if (provider.failure != null) {
                                              //   AppDialogHelper.showFailureDialog(
                                              //     context: context,
                                              //     failure: provider.failure,
                                              //     provider: provider,
                                              //     onTap: () {
                                              //       provider.clearFailure();
                                              //       Navigator.pop(context);
                                              //     },
                                              //   );
                                              //   return;
                                              // }

                                              // // Success
                                              // if (provider.success != null) {
                                              //   AppDialogHelper.showSuccessDialog(
                                              //     context: context,
                                              //     message:
                                              //         provider.success!.message,
                                              //     provider: provider,
                                              //     onTap: () {
                                              //       // provider.clearFailure();
                                              //       Navigator.pop(context);
                                              //     },
                                              //   );
                                              //   // Refresh resource list after successful upload
                                              //   await provider
                                              //       .getCourseResourceListPro(
                                              //         course.id.toString(),
                                              //       );
                                              //   // getCourseResourceListPro clears success,
                                              //   // so set it again after refreshing.
                                              //   provider.clearFailure();
                                              // }
                                            },
                                          );
                                        },
                                      );
                                    },
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

                              (userCourseProvider.isLoadingListOfRecordings ||
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
                                        userCourseProvider
                                            .userWebinarRecordingsModel
                                            ?.data
                                            ?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final recording =
                                          userCourseProvider
                                              .userWebinarRecordingsModel
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
                                                    color:
                                                        AppColor
                                                            .primaryBlueDark,
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
                              CommonCustomeButtonWidget(
                                isTablet: isTablet,
                                text:
                                    userCourseProvider.isLoadingJoinData
                                        ? 'Try to join....'
                                        : "Join",
                                onTap:
                                    userCourseProvider.isLoadingJoinData
                                        ? null
                                        : () async {
                                          try {
                                            await userCourseProvider
                                                .userJoinDataPro(
                                                  widget.courseId.toString(),
                                                );

                                            if (!mounted) return;

                                            if (userCourseProvider.success ==
                                                true) {
                                              final meetingUrl =
                                                  userCourseProvider
                                                      .userJoinWebinarModel
                                                      ?.data
                                                      ?.meetingUrl ??
                                                  '';

                                              if (meetingUrl.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Unable to open the webinar. Meeting link not found.',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              await userCourseProvider
                                                  .launchZoomMeeting(
                                                    meetingUrl,
                                                  );
                                            } else if (userCourseProvider
                                                    .failure !=
                                                null) {
                                              _handleFailure(
                                                userCourseProvider,
                                                permissionProvider,
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

  Future<dynamic> DilogeOfPayment(BuildContext context, UserDetailData course) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Webinar icon
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: const Icon(
                                Icons.videocam_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Premium Webinar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Unlock access to this live session',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Webinar title
                            Text(
                              course.title ?? 'Webinar',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Paid badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFED7AA),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 15,
                                    color: Color(0xFFEA580C),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'PAID WEBINAR',
                                    style: TextStyle(
                                      color: Color(0xFFEA580C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Price card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.currency_rupee_rounded,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Registration Fee',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'One-time payment',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF334155),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    '₹${course.price ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Complete the payment to get access to this live webinar.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () {
                                              Navigator.pop(dialogContext);
                                            },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Color(0xFF475569),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () async {
                                              setState(() {
                                                isLoading = true;
                                              });

                                              // TODO:
                                              // Payment logic here
                                              //
                                              // await paymentProvider
                                              //     .makePayment(
                                              //       course.price,
                                              //     );

                                              // After successful payment:
                                              //
                                              // await userCourseProvider
                                              //     .launchZoomMeeting(
                                              //       course.meetingLink ?? '',
                                              //     );

                                              setState(() {
                                                isLoading = false;
                                              });

                                              // Navigator.pop(dialogContext);
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        isLoading
                                            ? const SizedBox(
                                              height: 21,
                                              width: 21,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.lock_open_rounded,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Continue to Pay',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Secure payment
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Secure payment • Instant access',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void showWebinarEndedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  size: 36,
                  color: Colors.red.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Webinar Ended",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                "This webinar has already ended.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "You can no longer join this session.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Got it",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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

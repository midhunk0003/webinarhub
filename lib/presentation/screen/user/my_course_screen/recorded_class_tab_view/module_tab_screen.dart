import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/iconHelperWidget.dart';
import 'package:lms/presentation/screen/user/my_course_screen/youtube_play_screen.dart';
import 'package:provider/provider.dart';

class ModuleTabScreen extends StatefulWidget {
  const ModuleTabScreen({Key? key}) : super(key: key);

  @override
  _ModuleTabScreenState createState() => _ModuleTabScreenState();
}

class _ModuleTabScreenState extends State<ModuleTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyCourseProvider>(
      builder: (context, mycourseProvider, _) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              mycourseProvider
                  .courseModule!
                  .modules
                  .length, // Example number of modules
          itemBuilder: (context, index) {
            final module =
                mycourseProvider
                    .courseModule!
                    .modules[index]; // Example number of modules
            final isExpanded = mycourseProvider.indexShowModuleContent == index;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.formPrimaryColor.withOpacity(0.24),
                    AppColor.formSecondaryColor.withOpacity(0.24),
                  ],
                ),
                border: Border.all(
                  color: AppColor.formBorderColor.withOpacity(0.24),
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/tick.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${module.title}',
                                  // maxLines: 1,
                                  // overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColor.lightgray,
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            mycourseProvider.showModuleContent(index);
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColor.glassHighlight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isExpanded ? 20 : 0),
                    isExpanded
                        ? ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              mycourseProvider
                                  .courseModule!
                                  .modules[index]
                                  .contents
                                  .length,
                          itemBuilder: (context, moduleCintentIndex) {
                            final moduleContent =
                                mycourseProvider
                                    .courseModule!
                                    .modules[index]
                                    .contents[moduleCintentIndex];
                            return InkWell(
                              onTap: () async {
                                if (moduleContent.type == ContentType.video) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => YoutubePlayerScreen(
                                            videoId: moduleContent.videoId!,
                                            title: moduleContent.title,
                                          ),
                                    ),
                                  );
                                }

                                if (moduleContent.type ==
                                    ContentType.liveClass) {
                                  await mycourseProvider.launchZoomMeeting(
                                    moduleContent.meetingUrl!,
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.formPrimaryColor.withOpacity(
                                        0.35,
                                      ),
                                      AppColor.formSecondaryColor.withOpacity(
                                        0.24,
                                      ),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColor.formBorderColor.withOpacity(
                                      0.24,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(12),

                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          getIconBasedOnContentHelper(
                                            type: moduleContent.type,
                                            fileUrl:
                                                moduleContent.fileUrl ?? '',
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${moduleContent.title}',
                                                  // maxLines: 1,
                                                  // overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: AppColor.ghostwhite,
                                                    fontSize: 14,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  'Dr. Anya Sharma | 15 min',
                                                  // maxLines: 1,
                                                  // overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: AppColor.lightgray,
                                                    fontSize: 14,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w400,
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
                            );
                          },
                          separatorBuilder: (context, moduleContentIndex) {
                            return SizedBox(height: 14);
                          },
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 18);
          },
        );
      },
    );
  }
}

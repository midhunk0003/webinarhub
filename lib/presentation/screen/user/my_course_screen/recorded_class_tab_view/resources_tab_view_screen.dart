import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/iconHelperWidget.dart';
import 'package:provider/provider.dart';

class ResourcesTabViewScreen extends StatefulWidget {
  const ResourcesTabViewScreen({Key? key}) : super(key: key);

  @override
  _ResourcesTabViewScreenState createState() => _ResourcesTabViewScreenState();
}

class _ResourcesTabViewScreenState extends State<ResourcesTabViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyCourseProvider>(
      builder: (context, mycourseProvider, _) {
        return ListView.separated(
          itemCount: mycourseProvider.resources.length,
          itemBuilder: (context, resourceIndex) {
            final resourceCource = mycourseProvider.resources[resourceIndex];
            final isExpanded =
                mycourseProvider.indexShowResourceContent == resourceIndex;
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
                                  '${resourceCource.title}',
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
                            mycourseProvider.showResourceContent(resourceIndex);
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
                                  .resources[resourceIndex]
                                  .resourceContents
                                  .length,
                          itemBuilder: (context, resourceContentIndex) {
                            final resourcesContentData =
                                mycourseProvider
                                    .resources[resourceIndex]
                                    .resourceContents[resourceContentIndex];
                            return InkWell(
                              onTap: () async {
                                print('open pdf');
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
                                            type: resourcesContentData.type,
                                            fileUrl:
                                                resourcesContentData.fileUrl,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${resourcesContentData.title}',
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

                                          SvgPicture.asset(
                                            'assets/svg/downloadicon.svg',
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
          separatorBuilder: (context, moduleIndex) {
            return SizedBox(height: 10);
          },
        );
      },
    );
  }
}

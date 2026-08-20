import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/widgets/shimmer_widgets/countinue_learning_shimmer_widget.dart';
import 'package:provider/provider.dart';

class CountinueLearningWidget extends StatelessWidget {
  const CountinueLearningWidget({super.key, required bool isTablet})
    : _isTablet = isTablet;

  final bool _isTablet;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<MyCourseProvider>(
      builder: (context, myCourseProvider, _) {
        return (myCourseProvider.isLoading ||
                myCourseProvider.continueLearningList.isEmpty)
            ? ContinueLearningShimmer(isTablet: _isTablet)
            : (myCourseProvider.continueLearningList.isEmpty)
            ? Center(child: Text('NO Data'))
            : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue Learning',
                    style: TextStyle(
                      color: AppColor.lightgray,
                      fontSize: _isTablet ? 26 : 20,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: _isTablet ? 28 : 20),
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(_isTablet ? 16 : 10),
                        width: double.infinity,
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
                        child: Row(
                          children: [
                            Container(
                              width:
                                  _isTablet
                                      ? screenWidth * 0.16
                                      : screenWidth * 0.24,
                              height:
                                  _isTablet
                                      ? screenWidth * 0.16
                                      : screenWidth * 0.24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[300],
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/imgclearn.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: _isTablet ? 18 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'The Psychology of \nRelationships',
                                    style: TextStyle(
                                      color: AppColor.ghostwhite,
                                      fontSize: _isTablet ? 20 : 15,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: _isTablet ? 24 : 18),

                                  Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: LinearProgressIndicator(
                                                  value: 0.7, // 70%
                                                  minHeight: _isTablet ? 10 : 7,
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.08),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFF004B70)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: _isTablet ? 10 : 6,
                                              ),

                                              Text(
                                                '70% Completed',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: _isTablet ? 15 : 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: _isTablet ? 24 : 14),

                                        Container(
                                          width: _isTablet ? 54 : 42,
                                          height: _isTablet ? 54 : 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors:
                                                  AppColor.primaryBlueGradient,
                                            ),
                                            border: Border.all(
                                              color: AppColor.gradientEnd
                                                  .withOpacity(0.1),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/svg/playIcon.svg',
                                              width: _isTablet ? 22 : 16,
                                              height: _isTablet ? 22 : 16,
                                              color: AppColor.ghostwhite,
                                            ),
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
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: _isTablet ? 22 : 16);
                    },
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            );
      },
    );
  }
}

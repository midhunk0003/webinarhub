import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/countinue_learning_widget.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/languageandther_widget.dart';
import 'package:lms/presentation/screen/user/my_course_screen/widget/rating_and_student_enroll_widget.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_text_form_widget_field.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class CourseDetailPage extends StatefulWidget {
  final bool isPaid;
  const CourseDetailPage({Key? key, required this.isPaid}) : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool _isTablet = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _isTablet ? 80 : 66),
                CommonCustomAppBarWidget(
                  isTablet: _isTablet,
                  showBackButton: true,
                  title: "",
                  onBackButtonPressed: () {
                    Navigator.pop(context);
                  },
                  onShareButtonPressed: () {
                    print('share');
                  },
                  showShareButton: true,
                ),
                SizedBox(height: _isTablet ? 35 : 30),
                Text(
                  'Trading Strategies for Success',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 26 : 24,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/img3.png'),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Course Overview',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 22 : 20,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Discover the essential techniques for mastering the art of trading. This course will guide you through the fundamentals of market analysis, risk management, and effective trading strategies to enhance your financial acumen and achieve your investment goals.',
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: _isTablet ? 18 : 16,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                RatingAndStudentEnrollWidget(
                  isTablet: _isTablet,
                  stundEnrolled: '0',
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    Row(
                      children: [
                        LanguageAndOtherWIdget(
                          isTablet: _isTablet,
                          svgIcon: 'assets/svg/language.svg',
                          title: 'Language',
                          subTitle: 'English',
                        ),
                        SizedBox(width: 14),
                        LanguageAndOtherWIdget(
                          isTablet: _isTablet,
                          svgIcon: 'assets/svg/recordedclass.svg',
                          title: 'Course Type',
                          subTitle: 'Recorded',
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        LanguageAndOtherWIdget(
                          isTablet: _isTablet,
                          svgIcon: 'assets/svg/module.svg',
                          title: 'Module',
                          subTitle: '3 modules',
                        ),
                        SizedBox(width: 14),
                        LanguageAndOtherWIdget(
                          isTablet: _isTablet,
                          svgIcon: 'assets/svg/isFinish.svg',
                          title: 'To Finish',
                          subTitle: '3 weeks',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 36),
                CommonCustomeButtonWidget(
                  isTablet: _isTablet,
                  text: "Enroll for free",
                  onTap: () {
                    print('enroll free course');
                    showEnrollmentSuccessDialog(context, _isTablet, () {
                      print('start learning ');
                      Navigator.pushNamed(context, '/lecturescreen');
                    }, "Start Learning");
                  },
                ),
                SizedBox(height: 30),
                Text(
                  'What You\'ll Learn',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 22 : 20,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
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
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/tick.svg',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Understand market dynamics and trends',
                                style: TextStyle(
                                  color: AppColor.ghostwhite,
                                  fontSize: _isTablet ? 16 : 14,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 14);
                  },
                  itemCount: 5,
                ),
                SizedBox(height: 30),
                Text(
                  'Course Curriculum',
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: _isTablet ? 22 : 20,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30),
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Module 1',
                                  style: TextStyle(
                                    color: AppColor.lightgray,
                                    fontSize: _isTablet ? 16 : 12,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '|',
                                  style: TextStyle(color: AppColor.lightgray),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '65 minutes to complete',
                                  style: TextStyle(
                                    color: AppColor.lightgray,
                                    fontSize: _isTablet ? 16 : 12,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Foundations of Human Connection',
                                  style: TextStyle(
                                    color: AppColor.ghostwhite,
                                    fontSize: _isTablet ? 18 : 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: AppColor.ghostwhite,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // title
                            Text(
                              'Welcome to the course! This module lays the groundwork by exploring the core psychological principles that drive all human relationships. You\'ll learn about attachment theory, the role of empathy, and the science behind why we connect with others. This knowledge is essential for building stronger bonds in every area of your life',
                              style: TextStyle(
                                color: AppColor.lightgray,
                                fontSize: _isTablet ? 16 : 14,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 13),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/videoicon.svg',
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '3 videos',
                                      style: TextStyle(
                                        color: AppColor.lightgray,
                                        fontSize: _isTablet ? 16 : 12,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '|',
                                  style: TextStyle(color: AppColor.lightgray),
                                ),
                                SizedBox(width: 10),
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/svg/pdficon.svg'),
                                    SizedBox(width: 6),
                                    Text(
                                      '1 pdf',
                                      style: TextStyle(
                                        color: AppColor.lightgray,
                                        fontSize: _isTablet ? 16 : 12,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  itemCount: 6,
                ),
                SizedBox(height: 30),
                Text(
                  'About Your Mentor',
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: _isTablet ? 22 : 20,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/img4.jpg'),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. Leo Martinez, Ph.D.',
                                  style: TextStyle(
                                    color: AppColor.ghostwhite,
                                    fontSize: _isTablet ? 18 : 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Expert in Financial Psychology',
                                  style: TextStyle(
                                    color: AppColor.lightgray,
                                    fontSize: _isTablet ? 14 : 12,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Dr. Anya Sharma is a distinguished financial psychologist and a leading expert in the field of trading psychology, focusing on the mental aspects that influence trading decisions.',
                          style: TextStyle(
                            color: AppColor.lightgray,
                            fontSize: _isTablet ? 14 : 12,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

void showEnrollmentSuccessDialog(
  BuildContext context,
  bool isTablet,
  VoidCallback onTap,
  String? buttonText,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0B1220), Color(0xFF111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/svg/successimage.svg'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: AppColor.primaryBlueGradient,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Enrollment Successful!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                "The course has been added to your library.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isTablet ? 15 : 12,
                ),
              ),

              const SizedBox(height: 24),

              CommonCustomeButtonWidget(
                isTablet: isTablet,
                text: "${buttonText ?? ''}",
                onTap: onTap,
              ),

              const SizedBox(height: 12),

              // Go Back Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0284C7)),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Go Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                    ),
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

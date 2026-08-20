import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';

import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';

import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({Key? key}) : super(key: key);

  @override
  _TrainerProfileScreenState createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialData();
  }

  void initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<MyCourseProvider>(
        context,
        listen: false,
      );
      // final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      profileProvider.getMyCoursesPro();
      // homeProvider.getTopRatedCourses();
    });
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
                HomeHeaderSectionWidget(
                  isTablet: _isTablet,
                  title: 'Hello profile',
                  subTitle: 'Ready to pick up where you left off?',
                  showNotificationIcon: true,
                  showProfileImage: false,
                ),
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

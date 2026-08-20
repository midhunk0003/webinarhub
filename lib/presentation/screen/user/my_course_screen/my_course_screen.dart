import 'package:flutter/material.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/countinue_learning_widget.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_text_form_widget_field.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({Key? key}) : super(key: key);

  @override
  _MyCourseScreenState createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shortAnswerController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialData();
  }

  void initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MyCourseProvider>(context, listen: false);
      provider.getMyCoursesPro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool _isTablet = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: _isTablet ? 80 : 66),
                  CommonCustomAppBarWidget(
                    isTablet: _isTablet,
                    showBackButton: false,
                    title: "My Courses",
                    onBackButtonPressed: () {
                      Navigator.pop(context);
                    },
                    onShareButtonPressed: () {
                      print('share');
                    },
                    showShareButton: false,
                  ),
                  SizedBox(height: _isTablet ? 35 : 30),
                  CountinueLearningWidget(isTablet: _isTablet),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

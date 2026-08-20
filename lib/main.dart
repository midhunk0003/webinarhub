import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/dependence_injection.dart';
import 'package:lms/core/navigator_service.dart';
import 'package:lms/core/services/file_download_service.dart';
import 'package:lms/firebase_options.dart';
import 'package:lms/firebasemessagingservice.dart';
import 'package:lms/presentation/provider/auth_provider.dart';
import 'package:lms/presentation/provider/permission_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_all_wbinar_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_course_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';
import 'package:lms/presentation/provider/user_provider/onboard_provider.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/provider/user_provider/search_course_provider.dart';
import 'package:lms/presentation/screen/auth_screen/login_screen.dart';
import 'package:lms/presentation/screen/auth_screen/register_screen.dart';
import 'package:lms/presentation/screen/trainer/trainer_notification_screen.dart';
import 'package:lms/presentation/screen/trainer/trainer_webinar_course_detail_page.dart';
import 'package:lms/presentation/screen/trainer/view_all_participents.dart';
import 'package:lms/presentation/screen/user/certificates/certificates_preview_screen.dart';
import 'package:lms/presentation/screen/user/home_screen/user_home_screen.dart';
import 'package:lms/presentation/screen/user/my_course_screen/course_detail_page.dart';
import 'package:lms/presentation/screen/user/my_course_screen/lecture_screen.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/edit_profile_screen.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/help_center_screen.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/my_cart_screen.dart';
import 'package:lms/presentation/screen/user/onboard_screen/onboard_screen.dart';
import 'package:lms/presentation/screen/user/splash_screen/splash_screen.dart';
import 'package:lms/presentation/screen/user/user_all_webinar_screen.dart';
import 'package:lms/presentation/screen/user/user_webinar_course_detail_page.dart';
import 'package:lms/presentation/widgets/custom_bottom_navbar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  // await FileDownloadService.initialize();
  // Firebase + FCM should NEVER prevent app startup.
  try {
    // Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Register background handler FIRST
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // Initialize FCM + local notifications
    await FirebaseMessagingService().initialize();
    debugPrint('Firebase/FCM initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Firebase/FCM initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);

    // IMPORTANT:
    // Do not rethrow.
    // App continues without Firebase notifications.
  }
  runApp(
    DevicePreview(
      enabled: false, // 🔥 set false in production
      builder: (context) {
        return const MyApp();
      },
    ),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Background message: ${message.messageId}');

    print('Background data: ${message.data}');
  } catch (e) {
    print('Background FCM error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardProvider()),
        ChangeNotifierProvider(create: (_) => getIt<UserDashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => MyCourseProvider()),
        ChangeNotifierProvider(create: (_) => SearchCourseProvider()),
        ChangeNotifierProvider(create: (_) => getIt<TrainerCourseProvider>()),
        ChangeNotifierProvider(
          create: (_) => getIt<TrainerAllWebinarProvider>(),
        ),

        // trainer
        ChangeNotifierProvider(
          create: (_) => getIt<TrainerDashboardProvider>(),
        ),
        // trainer
        ChangeNotifierProvider(create: (_) => getIt<PermissionProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserAllWbinarProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserCourseProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ProfileProvider>()),
      ],

      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'IPO LMS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _customPageRoute(SplashScreen());
            case '/onboardscreen':
              return _customPageRoute(OnboardScreen());
            case '/loginscreen':
              return _customPageRoute(LoginScreen());
            case '/registerscreen':
              return _customPageRoute(RegisterScreen());
            case '/userhomescreen':
              return _customPageRoute(UserHomeScreen());
            case '/custombottomnavbarwidget':
              final args = settings.arguments as Map<String, dynamic>;
              final userRole = args["userrole"];
              print('user role : ${userRole}');
              return _customPageRoute(
                CustomBottomNavbarWidget(userRole: userRole.toString()),
              );
            case '/editprofilescreen':
              final args = settings.arguments as Map<String, dynamic>;
              final firstname = args["firstname"];
              final lastname = args["lastname"];
              final phonenumber = args["phonenumber"];
              return _customPageRoute(
                EditProfileScreen(
                  firstName: firstname,
                  lastName: lastname,
                  phoneNumber: phonenumber,
                ),
              );
            case '/mycartscreen':
              return _customPageRoute(MyCartScreen());
            case '/helpcenterscreen':
              return _customPageRoute(HelpCenterScreen());
            case '/userallwebinarscreen':
              return _customPageRoute(UserAllWebinarScreen());
            case '/coursedetailpage':
              return _customPageRoute(CourseDetailPage(isPaid: true));
            case '/lecturescreen':
              return _customPageRoute(LectureScreen());
            case '/certificatespreviewscreen':
              return _customPageRoute(CertificatesPreviewScreen());
            case '/trainerwebinardetailpage':
              final args = settings.arguments as Map<String, dynamic>;
              final courseId = args["courseId"];
              return _customPageRoute(
                TrainerWebinarCourseDetailPage(courseId: courseId),
              );
            case '/viewallparticipents':
              final args = settings.arguments as Map<String, dynamic>;
              final courseId = args["courseId"];
              return _customPageRoute(ViewAllParticipents(courseId: courseId));

            case '/trainernotificationscreen':
              return _customPageRoute(TrainerNotificationScreen());

            case '/userwebinarcoursedetailpage':
              final args = settings.arguments as Map<String, dynamic>;
              final courseId = args["courseId"];
              return _customPageRoute(
                UserWebinarCourseDetailPage(courseId: courseId),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

PageRouteBuilder _customPageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; // No animation
    },
    transitionDuration: Duration.zero, // Instantly switch pages
  );
}

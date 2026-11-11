import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// ✅ Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _navigateCheck();
  }

  Future<void> _navigateCheck() async {
    final stopwatch = Stopwatch()..start();

    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 10),
      );

      final onboard = prefs.getString('onboard');
      final role = prefs.getString('role')?.trim();
      final token = prefs.getString('accessToken')?.trim();

      final hasCompletedOnboarding = onboard != null;
      final hasToken = token != null && token.isNotEmpty;
      final hasRole = role != null && role.isNotEmpty;

      final String destination;
      Object? arguments;

      if (!hasCompletedOnboarding) {
        destination = '/onboardscreen';
      } else if (hasToken && hasRole) {
        destination = '/custombottomnavbarwidget';
        arguments = {'userrole': role};
      } else {
        destination = '/loginscreen';
      }

      debugPrint('Splash destination: $destination');
      debugPrint('Has token: $hasToken');
      debugPrint('Has role: $hasRole');

      // Keep the splash visible for at least 2 seconds.
      final remaining = const Duration(seconds: 2) - stopwatch.elapsed;

      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;

      await Navigator.pushNamedAndRemoveUntil(
        context,
        destination,
        (_) => false,
        arguments: arguments,
      );
    } catch (e, stackTrace) {
      debugPrint('Splash navigation error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      // Ensure this route is registered in MaterialApp.
      Navigator.pushNamedAndRemoveUntil(context, '/loginscreen', (_) => false);
    } finally {
      stopwatch.stop();
    }
  }
  // void _navigateCheck() async {
  //   try {
  //     final pref = await SharedPreferences.getInstance().timeout(
  //       const Duration(seconds: 10),
  //     );
  //     ;
  //     final isOnboardFinish = pref.getString('onboard');
  //     final userRole = pref.getString('role');
  //     print('is onboard finish: ${isOnboardFinish}');
  //     print('Role.................: ${userRole}');

  //     /// TOKEN CHECK
  //     final hasUserToken = await _hasToken();
  //     print('has user token: ${hasUserToken}');
  //     if (isOnboardFinish != null) {
  //       if (hasUserToken && userRole != null && userRole.isNotEmpty) {
  //         await Future.delayed(const Duration(seconds: 2));
  //         if (!mounted) return;
  //         Navigator.pushNamedAndRemoveUntil(
  //           context,
  //           '/custombottomnavbarwidget', // ✅ your route name
  //           arguments: {'userrole': userRole},
  //           (route) => false, // ✅ remove all previous routes
  //         );
  //         return;
  //       }
  //       await Future.delayed(const Duration(seconds: 2));
  //       if (!mounted) return;
  //       Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         '/loginscreen', // ✅ your route name
  //         (route) => false, // ✅ remove all previous routes
  //       );
  //       return;
  //     }
  //     await Future.delayed(const Duration(seconds: 2));
  //     if (!mounted) return;
  //     Navigator.pushNamedAndRemoveUntil(
  //       context,
  //       '/onboardscreen', // ✅ your route name
  //       (route) => false, // ✅ remove all previous routes
  //     );
  //   } catch (e, stackTrace) {
  //     debugPrint('Splash Error: $e');
  //     debugPrintStack(stackTrace: stackTrace);

  //     if (!mounted) return;

  //     // Safe fallback
  //     Navigator.pushNamedAndRemoveUntil(context, '/loginscreen', (_) => false);
  //   }
  // }

  Future<bool> _hasToken() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString('accessToken');
      print('tokenaaaaaaaaaaaa: ${token}');
      return token?.isNotEmpty ?? false;
    } catch (e) {
      debugPrint("Token read failed: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'WWITPL',
                style: TextStyle(
                  color: AppColor.goldDark,
                  fontFamily: 'AfacadFlux',
                  fontWeight: FontWeight.w400,
                  fontSize: 60,
                ),
              ),
              Text(
                'The journey to knowing',
                style: TextStyle(
                  color: AppColor.ghostwhite,
                  fontFamily: 'AfacadFlux',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/profile_model/profile_model.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/model/user_dashboard_upcomming_and_recent_model/user_dashboard_upcomming_and_recent_model.dart';
import 'package:lms/data/model/user_join_webinar_model/user_join_webinar_model.dart';
import 'package:lms/data/model/user_over_view_model/user_over_view_model.dart';
import 'package:lms/domain/repository/profile_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';
import 'package:lms/domain/repository/user_repo/user_course_repository.dart';
import 'package:lms/domain/repository/user_repo/user_dashboard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDashboardProvider extends ChangeNotifier {
  final UserDashboardRepository userDashboardRepository;
  final UserCourseRepository userCourseRepository;
  final ProfileRepository profileRepository;

  UserDashboardProvider({
    required this.userDashboardRepository,
    required this.userCourseRepository,
    required this.profileRepository,
  });

  bool _isLoading = false;
  bool _isLoadingOverView = false;
  bool _isLoadingJoinData = false;
  bool _isLoadingProfile = false;
  Failure? _failure;
  Success? _success;
  UserDashboardUpcommingAndRecentModel? _userDashboardUpcommingAndRecentModel;
  UserOverViewModel? _userOverViewModel;
  UserJoinWebinarModel? _userJoinWebinarModel;
  ProfileModel? _profileModel;

  // getter

  bool get isLoading => _isLoading;
  bool get isLoadingOverView => _isLoadingOverView;
  bool get isLoadingJoinData => _isLoadingJoinData;
  bool get isLoadingProfile => _isLoadingProfile;
  Failure? get failure => _failure;
  Success? get success => _success;
  UserDashboardUpcommingAndRecentModel?
  get userDashboardUpcommingAndRecentModel =>
      _userDashboardUpcommingAndRecentModel;
  UserOverViewModel? get userOverViewModel => _userOverViewModel;
  UserJoinWebinarModel? get userJoinWebinarModel => _userJoinWebinarModel;
  ProfileModel? get profileModel => _profileModel;

  // functions

  void clearFailure() {
    _failure = null;
    print('aaaaaaaaaaaa');
    notifyListeners();
  }

  void clearSuccess() {
    _success = null;
    notifyListeners();
  }

  Future<void> getUserDashUpcommingAndAssignPro() async {
    _isLoading = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result =
        await userDashboardRepository.getUserDashboardUpcommAndAssigned();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _userDashboardUpcommingAndRecentModel = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getUserDashOverViewPro() async {
    _isLoadingOverView = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await userDashboardRepository.getUserDashboardOverView();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingOverView = false;
        notifyListeners();
      },
      (success) {
        _userOverViewModel = success;
        _isLoadingOverView = false;
        notifyListeners();
      },
    );
  }

  // ============================================================
  // JOIN DATA
  // ============================================================
  Future<void> userJoinDataPro(String? courseId) async {
    _isLoadingJoinData = true;
    _failure = null;
    _success = null;

    notifyListeners();

    final result = await userCourseRepository.getUserToJoinWebinar(courseId);

    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingJoinData = false;

        notifyListeners();
      },
      (success) {
        _userJoinWebinarModel = success;
        _isLoadingJoinData = false;

        notifyListeners();
      },
    );
  }

  Future<void> getProfilePro() async {
    _isLoadingProfile = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      _failure = ClientFailure('User ID not found');
      _isLoadingProfile = false;
      notifyListeners();
      return;
    }

    final result = await profileRepository.getProfileData();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingProfile = false;
        notifyListeners();
      },
      (success) {
        _profileModel = success;
        _isLoadingProfile = false;
        notifyListeners();
      },
    );
  }

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('sssssssssssssss : ${meetingUrl}');
    final Uri uri = Uri.parse(meetingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

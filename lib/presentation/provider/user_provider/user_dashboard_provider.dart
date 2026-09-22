import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/profile_model/profile_model.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/model/user_dashboard_upcomming_and_recent_model/user_dashboard_upcomming_and_recent_model.dart';
import 'package:lms/data/model/user_join_webinar_model/user_join_webinar_model.dart';
import 'package:lms/data/model/user_over_view_model/user_over_view_model.dart';
import 'package:lms/data/model/user_policy_and_agree_model/user_policy_and_agree_model.dart';
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
  bool _isLoadingAccept = false;
  bool _isLoadingPrivacyAndAgree = false;
  bool _isLoadingOverView = false;
  bool _isLoadingJoinData = false;
  bool _isLoadingProfile = false;
  Failure? _failure;
  Success? _success;
  UserDashboardUpcommingAndRecentModel? _userDashboardUpcommingAndRecentModel;
  UserOverViewModel? _userOverViewModel;
  UserJoinWebinarModel? _userJoinWebinarModel;
  ProfileModel? _profileModel;
  UserPolicyAndAgreeModel? _userPolicyAndAgreeModel;

  // ============================================================
  // PRIVACY POLICY
  // ============================================================

  bool _requiresPolicyAcceptance = false;

  // getter

  bool get isLoading => _isLoading;
  bool get isLoadingAccept => _isLoadingAccept;
  bool get isLoadingPrivacyAndAgree => _isLoadingPrivacyAndAgree;
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

  UserPolicyAndAgreeModel? get userPolicyAndAgreeModel =>
      _userPolicyAndAgreeModel;
  // Privacy Policy getter
  bool get requiresPolicyAcceptance => _requiresPolicyAcceptance;
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

  // ============================================================
  // LOAD PRIVACY POLICY STATUS
  // ============================================================

  Future<void> loadPolicyAcceptanceStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final value = prefs.getString('requiresPolicyAcceptance');

      // "true"  -> true
      // "false" -> false
      // null    -> false
      _requiresPolicyAcceptance = value?.toLowerCase() == 'true';

      debugPrint('requiresPolicyAcceptance String: $value');

      debugPrint('requiresPolicyAcceptance Bool: $_requiresPolicyAcceptance');

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading policy acceptance status: $e');

      // Safe default
      _requiresPolicyAcceptance = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ACCEPT PRIVACY POLICY
  // ============================================================

  Future<void> acceptPrivacyPolicyPro(List<int> policyIds) async {
    _isLoadingAccept = true;
    _failure = null;
    _success = null;

    notifyListeners();

    try {
      // Validate policy ID before API call
      if (policyIds.isEmpty) {
        _failure = ClientFailure('Policy ID is required');
        _isLoadingAccept = false;
        notifyListeners();
        return;
      }

      final result = await userDashboardRepository.acceptPolicy(policyIds);

      result.fold(
        (failure) {
          // API FAILED
          _failure = failure;
          _isLoadingAccept = false;

          notifyListeners();
        },
        (success) async {
          // API SUCCESS
          _success = success;
          _isLoadingAccept = false;

          // Save locally ONLY after successful API response
          try {
            final prefs = await SharedPreferences.getInstance();

            await prefs.setString('requiresPolicyAcceptance', 'false');

            _requiresPolicyAcceptance = false;

            debugPrint('Privacy policy accepted successfully');
          } catch (e) {
            debugPrint('Error saving privacy policy acceptance: $e');
          }

          notifyListeners();
        },
      );
    } catch (e) {
      _failure = OtherFailureNon200('Unable to accept privacy policy: $e');

      _isLoadingAccept = false;

      notifyListeners();

      debugPrint('acceptPrivacyPolicyPro error: $e');
    }
  }

  Future<void> getUserPolicyAndAgreePro() async {
    _isLoadingPrivacyAndAgree = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await userDashboardRepository.getUserPolicyAndAgree();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingPrivacyAndAgree = false;
        notifyListeners();
      },
      (success) {
        _userPolicyAndAgreeModel = success;
        _isLoadingPrivacyAndAgree = false;
        notifyListeners();
      },
    );
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
  Future<void> userJoinDataPro(String? courseId, String? mobile) async {
    _isLoadingJoinData = true;
    _failure = null;
    _success = null;

    notifyListeners();

    final result = await userCourseRepository.getUserToJoinWebinar(
      courseId,
      mobile,
    );

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

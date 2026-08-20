import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainerDashboardProvider extends ChangeNotifier {
  final TrainerDashboardRepository trainerDashboardRepository;

  TrainerDashboardProvider({required this.trainerDashboardRepository});

  bool _isLoading = false;
  bool _isLoadingOverView = false;
  Failure? _failure;
  Success? _success;
  TrainerUpcommingAndAssignedModel? _trainerUpcommingAndAssignedModel;
  TrainerOverViewModel? _trainerOverViewModel;

  // getter

  bool get isLoading => _isLoading;
  bool get isLoadingOverView => _isLoadingOverView;
  Failure? get failure => _failure;
  Success? get success => _success;
  TrainerUpcommingAndAssignedModel? get trainerUpcommingAndAssignedModel =>
      _trainerUpcommingAndAssignedModel;
  TrainerOverViewModel? get trainerOverViewModel => _trainerOverViewModel;

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

  Future<void> getDashUpcommingAndAssignPro() async {
    _isLoading = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result =
        await trainerDashboardRepository.getDashboardUpcommAndAssigned();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _trainerUpcommingAndAssignedModel = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getDashOverViewPro() async {
    _isLoadingOverView = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await trainerDashboardRepository.getDashboardOverView();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingOverView = false;
        notifyListeners();
      },
      (success) {
        _trainerOverViewModel = success;
        _isLoadingOverView = false;
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

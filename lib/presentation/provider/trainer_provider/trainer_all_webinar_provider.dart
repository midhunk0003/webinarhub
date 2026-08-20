import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/notification_model/notification_model.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_webinar_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainerAllWebinarProvider extends ChangeNotifier {
  final TrainerWebinarRepository trainerWebinarRepository;

  TrainerAllWebinarProvider({required this.trainerWebinarRepository});

  bool _isLoading = false;
  Failure? _failure;
  Success? _success;
  TrainerFullListWebinarModel? _trainerFullListWebinarModel;
  NotificationModel? _notificationModel;

  // getter

  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  Success? get success => _success;
  TrainerFullListWebinarModel? get trainerFullListWebinarModel =>
      _trainerFullListWebinarModel;

  NotificationModel? get notificationModel => _notificationModel;

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

  Future<void> getAllWebinarPro(String? status, String? search) async {
    _isLoading = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await trainerWebinarRepository.getAllWebinars(
      status,
      search,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _trainerFullListWebinarModel = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getAllNotification(String? isRead) async {
    _isLoading = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await trainerWebinarRepository.getAllNotification(isRead);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _notificationModel = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAsReadNotification(String? notificationId) async {
    _isLoading = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await trainerWebinarRepository.makeIsRead(notificationId);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoading = false;
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

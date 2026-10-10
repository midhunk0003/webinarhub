import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/notification_model/notification_model.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/model/user_full_list_webinar_model/user_full_list_webinar_model.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_webinar_repository.dart';
import 'package:lms/domain/repository/user_repo/user_webinar_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAllWbinarProvider extends ChangeNotifier {
  final UserWebinarRepository userWebinarRepository;

  UserAllWbinarProvider({required this.userWebinarRepository});

  bool _isLoading = false;

  bool _isLoadingMore = false;
  bool _hasMore = true;

  Failure? _failure;
  Success? _success;
  UserFullListWebinarModel? _fullListWebinarModel;
  NotificationModel? _notificationModel;

  int _currentPage = 1;
  final int _pageSize = 5;

  // All loaded webinar items
  final List<AllWebinarItem> _webinarItems = [];

  // getter

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Failure? get failure => _failure;
  Success? get success => _success;
  UserFullListWebinarModel? get fullListWebinarModel => _fullListWebinarModel;

  NotificationModel? get notificationModel => _notificationModel;

  int get currentPage => _currentPage;

  List<AllWebinarItem> get webinarItems => List.unmodifiable(_webinarItems);

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

  Future<void> getAllWebinarPro(
    String? status,
    String? search, {
    int? paymentStatus,
    bool loadMore = false,
  }) async {
    // Avoid duplicate requests
    if (_isLoading || _isLoadingMore) return;

    if (loadMore && !_hasMore) return;
    if (loadMore) {
      _isLoadingMore = true;
    } else {
      // New search/filter/refresh starts from page 1
      _isLoading = true;
      _failure = null;
      _success = null;
      _currentPage = 1;
      _hasMore = true;
      _webinarItems.clear();
    }

    final requestedPage = loadMore ? _currentPage + 1 : 1;

    notifyListeners();

    try {
      final result = await userWebinarRepository.getAllUserWebinars(
        status,
        search,
        paymentStatus,
        page: requestedPage,
        pageSize: _pageSize,
      );
      result.fold(
        (failure) {
          _failure = failure;
          _isLoading = false;
          _isLoadingMore = false; // Important fix
          notifyListeners();
        },
        (success) {
          _fullListWebinarModel = success;
          final newItems = success.data?.items ?? [];
          _webinarItems.addAll(newItems);

          _currentPage = requestedPage;

          // If fewer than 5 items arrive, there are no more
          // full pages to load.
          _hasMore = newItems.length == _pageSize;
          _isLoading = false;
          _isLoadingMore = false;
          notifyListeners();
        },
      );
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Future<void> getAllNotification(String? isRead) async {
  //   _isLoading = true;
  //   _failure = null;
  //   _success = null;
  //   notifyListeners();
  //   final result = await trainerWebinarRepository.getAllNotification(isRead);
  //   result.fold(
  //     (failure) {
  //       _failure = failure;
  //       _isLoading = false;
  //       notifyListeners();
  //     },
  //     (success) {
  //       _notificationModel = success;
  //       _isLoading = false;
  //       notifyListeners();
  //     },
  //   );
  // }

  // Future<void> markAsReadNotification(String? notificationId) async {
  //   _isLoading = true;
  //   _failure = null;
  //   _success = null;
  //   notifyListeners();
  //   final result = await trainerWebinarRepository.makeIsRead(notificationId);
  //   result.fold(
  //     (failure) {
  //       _failure = failure;
  //       _isLoading = false;
  //       notifyListeners();
  //     },
  //     (success) {
  //       _success = success;
  //       _isLoading = false;
  //       notifyListeners();
  //     },
  //   );
  // }

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('sssssssssssssss : ${meetingUrl}');
    final Uri uri = Uri.parse(meetingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

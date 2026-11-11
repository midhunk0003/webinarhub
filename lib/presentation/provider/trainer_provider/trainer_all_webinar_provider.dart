import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/get_notification_count_model/get_notification_count_model.dart';
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
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isLoadingCount = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingMoreNotifications = false;
  bool _hasMoreNotifications = true;
  Failure? _failure;
  Success? _success;
  TrainerFullListWebinarModel? _trainerFullListWebinarModel;
  NotificationModel? _notificationModel;
  GetNotificationCountModel? _getNotificationCountModel;
  int _notificationCurrentPage = 1;
  static const int _notificationPageSize = 5;

  final List<NotificationItem> _notificationItems = [];

  int _currentPage = 1;
  final int _pageSize = 5;

  // All loaded webinar items
  final List<Item> _webinarTrainerItems = [];

  // getter

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isLoadingCount => _isLoadingCount;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isLoadingMoreNotifications => _isLoadingMoreNotifications;
  bool get hasMoreNotifications => _hasMoreNotifications;
  Failure? get failure => _failure;
  Success? get success => _success;
  TrainerFullListWebinarModel? get trainerFullListWebinarModel =>
      _trainerFullListWebinarModel;

  NotificationModel? get notificationModel => _notificationModel;
  GetNotificationCountModel? get getNotificationCountModel =>
      _getNotificationCountModel;

  List<NotificationItem> get notificationItems =>
      List.unmodifiable(_notificationItems);

  int get currentPage => _currentPage;

  List<Item> get webinarItems => List.unmodifiable(_webinarTrainerItems);

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
      _webinarTrainerItems.clear();
    }

    final requestedPage = loadMore ? _currentPage + 1 : 1;

    notifyListeners();
    final result = await trainerWebinarRepository.getAllWebinars(
      status,
      search,
      page: requestedPage,
      pageSize: _pageSize,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
      (success) {
        _trainerFullListWebinarModel = success;
        final newItems = success.data?.items ?? [];
        _webinarTrainerItems.addAll(newItems);

        _currentPage = requestedPage;

        // If fewer than 5 items arrive, there are no more
        // full pages to load.
        _hasMore = newItems.length == _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> getAllNotification(
    String? isRead, {
    bool loadMore = false,
  }) async {
    // Prevent duplicate requests.
    if (_isLoadingNotifications || _isLoadingMoreNotifications) {
      return;
    }

    if (loadMore && !_hasMoreNotifications) {
      return;
    }

    final int requestedPage = loadMore ? _notificationCurrentPage + 1 : 1;

    if (loadMore) {
      _isLoadingMoreNotifications = true;
    } else {
      // Fresh request: reset the previous filter's data.
      _isLoadingNotifications = true;
      _notificationCurrentPage = 1;
      _hasMoreNotifications = true;
      _notificationItems.clear();
      _notificationModel = null;
      _failure = null;
    }

    notifyListeners();

    try {
      final result = await trainerWebinarRepository.getAllNotification(
        isRead,
        page: requestedPage,
        pageSize: _notificationPageSize,
      );

      result.fold(
        (failure) {
          _failure = failure;
        },
        (success) {
          _notificationModel = success;

          final newItems = success.data?.items ?? [];

          if (!loadMore) {
            // All / Read / Unread: replace the list.
            _notificationItems
              ..clear()
              ..addAll(newItems);
          } else {
            // Pagination: append only notifications not already present.
            final existingIds =
                _notificationItems.map((item) => item.id.toString()).toSet();

            for (final item in newItems) {
              if (existingIds.add(item.id.toString())) {
                _notificationItems.add(item);
              }
            }
          }

          _notificationCurrentPage = requestedPage;

          // Assumes the API returns at most pageSize items per page.
          _hasMoreNotifications = newItems.length >= _notificationPageSize;

          _failure = null;
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Get all notifications failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoadingNotifications = false;
      _isLoadingMoreNotifications = false;
      notifyListeners();
    }
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

  Future<void> getNotificationCountPro() async {
    _isLoadingCount = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await trainerWebinarRepository.getNotificationCount();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingCount = false;
        notifyListeners();
      },
      (success) {
        _getNotificationCountModel = success;
        _isLoadingCount = false;
        notifyListeners();
      },
    );
  }
}

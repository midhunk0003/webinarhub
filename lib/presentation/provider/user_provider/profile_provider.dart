import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/get_contact_model/get_contact_model.dart';
import 'package:lms/data/model/help_and_support_model/help_and_support_model.dart';
import 'package:lms/data/model/help_center_model/help_center_model.dart';
import 'package:lms/data/model/profile_model/profile_model.dart';
import 'package:lms/domain/repository/profile_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CartCourseModel {
  final String title;
  final String image;
  final String price;
  final double rating;
  final bool isNew;
  final bool isBest;

  CartCourseModel({
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    this.isNew = false,
    this.isBest = false,
  });
}

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository profileRepository;

  ProfileProvider({required this.profileRepository});

  bool _isLoadingProfile = false;
  bool _isLoadingupdate = false;
  bool _isLoadingProfileImage = false;
  bool _isLoadingGetContact = false;
  bool _isLoadingGetHelpAndSupport = false;
  bool _notificationEnabled = false;
  bool _isRequestingPermission = false;
  Failure? _failure;
  Success? _success;
  ProfileModel? _profileModel;

  List<bool> _selectedItems = [];
  bool _selectionMode = false;
  bool _showHideQuestionANdAnswer = false;

  List<CartCourseModel> _cartCourses = [];
  List<HelpCenter>? _helpCenterData = [];
  HelpAndSupportModel? _helpAndSupportModel;
  // Help & Support
  List<Category> _helpAndSupportCategories = [];

  String? _selectedHelpCategoryId;
  String? _expandedFaqId;

  String _helpSearchQuery = '';

  int _helpRequestId = 0;

  List<Category> get helpAndSupportCategories => _helpAndSupportCategories;

  String? get selectedHelpCategoryId => _selectedHelpCategoryId;

  String? get expandedFaqId => _expandedFaqId;

  String get helpSearchQuery => _helpSearchQuery;

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedProfileImage;

  // getter
  List<bool> get selectedItems => _selectedItems;
  bool get selectionMode => _selectionMode;
  bool get showHideQuestionANdAnswer => _showHideQuestionANdAnswer;
  List<CartCourseModel> get cartCourses => _cartCourses;
  List<HelpCenter>? get helpCenterData => _helpCenterData;
  HelpAndSupportModel? get helpAndSupportModel => _helpAndSupportModel;
  GetContactModel? _contactModel;

  // getter

  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingupdate => _isLoadingupdate;
  bool get isLoadingProfileImage => _isLoadingProfileImage;
  bool get isLoadingGetContact => _isLoadingGetContact;
  bool get isLoadingGetHelpAndSupport => _isLoadingGetHelpAndSupport;
  bool get notificationEnabled => _notificationEnabled;
  bool get isRequestingPermission => _isRequestingPermission;
  Failure? get failure => _failure;
  Success? get success => _success;
  ProfileModel? get profileModel => _profileModel;
  GetContactModel? get contactModel => _contactModel;

  File? get selectedProfileImage => _selectedProfileImage;

  static const String _notifPrefKey = 'notifications_enabled';

  /// Switch always mirrors the real phone permission.
  Future<void> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      _notificationEnabled = status.isGranted || status.isProvisional;
    } catch (e, stackTrace) {
      debugPrint('Check notification permission failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
    notifyListeners();
  }

  Future<void> handleNotificationToggle(bool enable) async {
    if (_isRequestingPermission) return;

    _isRequestingPermission = true;
    notifyListeners();

    try {
      final status = await Permission.notification.status;

      if (!enable) {
        // Can't revoke from code -> send the user to system settings.
        await openAppSettings();
      } else if (status.isGranted || status.isProvisional) {
        // Already allowed, nothing to do.
        _notificationEnabled = true;
      } else if (status.isPermanentlyDenied) {
        // System dialog won't show again -> settings is the only way.
        await openAppSettings();
      } else {
        // First time or denied once -> show the system dialog.
        final result = await Permission.notification.request();
        _notificationEnabled = result.isGranted || result.isProvisional;

        // Dialog was blocked (Android often does this after 2 denials).
        if (!_notificationEnabled) {
          await openAppSettings();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Notification toggle error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRequestingPermission = false;
      notifyListeners();
    }
  }

  Future<void> loadCartCourses() async {
    _cartCourses = [
      CartCourseModel(
        title: 'The Complete Guitar Course',
        image: 'assets/images/toprated.png',
        price: '₹2,799',
        rating: 4.9,
        isBest: true,
      ),

      CartCourseModel(
        title: 'The Science of Decision Making',
        image: 'assets/images/toprated.png',
        price: '₹3,799',
        rating: 4.9,
        isNew: true,
      ),

      CartCourseModel(
        title: 'Cognitive Psychology: An Introduction',
        image: 'assets/images/toprated.png',
        price: '₹2,999',
        rating: 4.8,
      ),

      CartCourseModel(
        title: 'Advanced UI UX Design Masterclass',
        image: 'assets/images/toprated.png',
        price: '₹4,499',
        rating: 5.0,
        isBest: true,
      ),

      CartCourseModel(
        title: 'Flutter App Development Bootcamp',
        image: 'assets/images/toprated.png',
        price: '₹5,999',
        rating: 4.7,
        isNew: true,
      ),
    ];
    // IMPORTANT
    _selectedItems = List.generate(_cartCourses.length, (index) => false);
    notifyListeners();
  }

  void onLongPress(int indexPass) {
    _selectionMode = true;
    _selectedItems[indexPass] = true;
    notifyListeners();
  }

  void onTap(int index) {
    if (!selectionMode) return;

    _selectedItems[index] = !_selectedItems[index];

    if (!_selectedItems.contains(true)) {
      _selectionMode = false;
    }

    notifyListeners();
  }

  int get selectedCount {
    return selectedItems.where((e) => e).length;
  }

  // helpcenter
  void getHelpCenterData() {
    _helpCenterData = [
      HelpCenter(
        categoryId: 1,
        categoryName: "Getting Started",
        questions: [
          Question(
            questionId: 1,
            question: "How do I find courses on this app?",
            answer:
                "After you log in, you can explore the Find a Live Class section from the home screen.",
          ),
          Question(
            questionId: 2,
            question: "How do I join a live class?",
            answer:
                "Open the course details page and click the Join Live Class button.",
          ),
        ],
      ),

      HelpCenter(
        categoryId: 2,
        categoryName: "My Account & Payments",
        questions: [
          Question(
            questionId: 3,
            question: "How do I update my profile information?",
            answer:
                "Go to Profile > Settings > Edit Profile to update your information.",
          ),
          Question(
            questionId: 4,
            question: "What payment methods are accepted?",
            answer:
                "We support debit cards, credit cards, UPI, wallets, and net banking.",
          ),
        ],
      ),

      HelpCenter(
        categoryId: 3,
        categoryName: "Course & Technical Issues",
        questions: [
          Question(
            questionId: 5,
            question: "The video is not playing. What should I do?",
            answer:
                "Please check your internet connection and restart the application.",
          ),
          Question(
            questionId: 6,
            question: "Where can I find my course resources?",
            answer:
                "Course resources are available inside the course details page.",
          ),
        ],
      ),
    ];

    notifyListeners();
  }

  void showHideQuestionAnswerPro(int indexindexCategory, int indexQuestion) {
    _showHideQuestionANdAnswer = !_showHideQuestionANdAnswer;
    notifyListeners();
  }

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

  Future<void> updateProfileData(
    String? firstMame,
    String? lastName,
    String? mobileNumber,
  ) async {
    _isLoadingupdate = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await profileRepository.updateProfile(
      firstMame,
      lastName,
      mobileNumber,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingupdate = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoadingupdate = false;
        notifyListeners();
      },
    );
  }

  Future<void> changePassword(
    String? currentPassword,
    String? newPassword,
  ) async {
    _isLoadingupdate = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final result = await profileRepository.changePassword(
      currentPassword ?? '',
      newPassword ?? '',
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingupdate = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoadingupdate = false;
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

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) {
        // User cancelled
        return;
      }

      _selectedProfileImage = File(image.path);

      notifyListeners();

      print('Selected image: ${image.path}');
    } catch (e) {
      print('Image picker error: $e');
    }
  }

  // functions

  void clearSelectedFile() {
    _selectedProfileImage = null;
    print('aaaaaaaaaaaa');
    notifyListeners();
  }

  Future<void> getContactPro() async {
    _isLoadingGetContact = true;
    _failure = null;
    _success = null;
    notifyListeners();

    final result = await profileRepository.getContactData();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingGetContact = false;
        notifyListeners();
      },
      (success) {
        _contactModel = success;
        _isLoadingGetContact = false;
        notifyListeners();
      },
    );
  }

  Future<void> uploadProfileImage() async {
    _isLoadingProfileImage = true;
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

    print('Uploading profile image for user ID: $userId');
    print('Selected profile image: ${_selectedProfileImage?.path}');

    final result = await profileRepository.uploadProfileImage(
      _selectedProfileImage?.path ?? '',
      userId,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingProfileImage = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoadingProfileImage = false;
        notifyListeners();
      },
    );
  }

  // INITIAL API + SEARCH + CATEGORY FILTER

  Future<void> getHelpAndSupportPro(String? search, String? categoryId) async {
    final requestId = ++_helpRequestId;

    _isLoadingGetHelpAndSupport = true;
    _failure = null;

    _helpSearchQuery = search ?? '';
    _selectedHelpCategoryId = categoryId;

    _expandedFaqId = null;

    notifyListeners();

    try {
      final result = await profileRepository.getHelpAndSupport(
        search,
        categoryId,
      );

      // Ignore outdated API responses.
      if (requestId != _helpRequestId) return;

      result.fold(
        (failure) {
          _failure = failure;
        },
        (success) {
          _helpAndSupportModel = success;

          // Cache all categories on initial unfiltered API response.
          if ((search == null || search.isEmpty) &&
              (categoryId == null || categoryId.isEmpty)) {
            _helpAndSupportCategories = success.data?.categories ?? [];
          }
        },
      );
    } catch (e) {
      if (requestId == _helpRequestId) {
        _failure = AuthFailure(e.toString());
      }
    } finally {
      if (requestId == _helpRequestId) {
        _isLoadingGetHelpAndSupport = false;
        notifyListeners();
      }
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/help_center_model/help_center_model.dart';
import 'package:lms/data/model/profile_model/profile_model.dart';
import 'package:lms/domain/repository/profile_repository.dart';
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
  Failure? _failure;
  Success? _success;
  ProfileModel? _profileModel;

  List<bool> _selectedItems = [];
  bool _selectionMode = false;
  bool _showHideQuestionANdAnswer = false;

  List<CartCourseModel> _cartCourses = [];
  List<HelpCenter>? _helpCenterData = [];

  // getter
  List<bool> get selectedItems => _selectedItems;
  bool get selectionMode => _selectionMode;
  bool get showHideQuestionANdAnswer => _showHideQuestionANdAnswer;
  List<CartCourseModel> get cartCourses => _cartCourses;
  List<HelpCenter>? get helpCenterData => _helpCenterData;

  // getter

  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingupdate => _isLoadingupdate;
  Failure? get failure => _failure;
  Success? get success => _success;
  ProfileModel? get profileModel => _profileModel;

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

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('sssssssssssssss : ${meetingUrl}');
    final Uri uri = Uri.parse(meetingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

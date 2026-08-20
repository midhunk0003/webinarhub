import 'package:flutter/material.dart';

class CategoryModel {
  final String title;
  final String courseCount;
  final String icon;

  CategoryModel({
    required this.title,
    required this.courseCount,
    required this.icon,
  });
}

class SearchCourseProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<CategoryModel> _categoryList = [];
  bool _showSearchScreen = false;

  // getter
  bool get isLoading => _isLoading;
  List<CategoryModel> get categoryList => _categoryList;
  bool get showSearchScreen => _showSearchScreen;

  Future<void> fetchCourseCategory() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _categoryList = [
      CategoryModel(
        title: "Technology",
        courseCount: "24 Courses",
        icon: "assets/svg/techonology.svg",
      ),

      CategoryModel(
        title: "Business",
        courseCount: "24 Courses",
        icon: "assets/svg/business.svg",
      ),

      CategoryModel(
        title: "Design",
        courseCount: "18 Courses",
        icon: "assets/svg/designe.svg",
      ),

      CategoryModel(
        title: "Data Science",
        courseCount: "18 Courses",
        icon: "assets/svg/datascience.svg",
      ),

      CategoryModel(
        title: "Marketing",
        courseCount: "30 Courses",
        icon: "assets/svg/marketing.svg",
      ),

      CategoryModel(
        title: "Psychology",
        courseCount: "30 Courses",
        icon: "assets/svg/psycology.svg",
      ),

      CategoryModel(
        title: "UX Design",
        courseCount: "20 Courses",
        icon: "assets/svg/uxdesigne.svg",
      ),

      CategoryModel(
        title: "Music",
        courseCount: "20 Courses",
        icon: "assets/svg/music.svg",
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  void showSearchScreenPro(String value) {
    if (value.trim().isEmpty) {
      _showSearchScreen = false;
    } else {
      _showSearchScreen = true;
    }

    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardProvider extends ChangeNotifier {
  int currentIndex = 0;

  void setIndex(int index) {
    currentIndex = index;
    print('${currentIndex}');
    notifyListeners();
  }

  bool isLastPage(int totalPages) {
    return currentIndex == totalPages - 1;
  }

  void nextPage(PageController controller, int totalPages) {
    if (currentIndex < totalPages - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void pareviousPage(PageController controller) {
    if (currentIndex > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<bool> saveOnboardCompleteInSharedPref(String? onboardData) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.setString('onboard', '${onboardData}');
  }
}

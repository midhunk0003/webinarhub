import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/screen/trainer/trainer_home_screen.dart';
import 'package:lms/presentation/screen/trainer/trainer_profile_screen.dart';
import 'package:lms/presentation/screen/trainer/trainer_webinar_screen.dart';
import 'package:lms/presentation/screen/user/home_screen/user_home_screen.dart';
import 'package:lms/presentation/screen/user/my_course_screen/my_course_screen.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/my_profile_screen.dart';
import 'package:lms/presentation/screen/user/user_all_webinar_screen.dart';

class BottomNavItem {
  final Widget page;
  final String icon;
  final bool isProfile;

  const BottomNavItem({
    required this.page,
    required this.icon,
    this.isProfile = false,
  });
}

class CustomBottomNavbarWidget extends StatefulWidget {
  final String? userRole;
  const CustomBottomNavbarWidget({super.key, required this.userRole});

  @override
  State<CustomBottomNavbarWidget> createState() =>
      _CustomBottomNavbarWidgetState();
}

class _CustomBottomNavbarWidgetState extends State<CustomBottomNavbarWidget> {
  List<BottomNavItem> _navItems = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    print('................ user role: ${widget.userRole}');
  }

  Future<void> _loadUserRole() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? role = prefs.getString('role');
    setState(() {
      _navItems = _getNavItemsForRole(widget.userRole);
      // Reset in case a previous role's index is now out of range.
      currentIndex = 0;
    });
  }

  List<BottomNavItem> _getNavItemsForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'trainer':
        return [
          BottomNavItem(
            page: TrainerHomeScreen(
              onViewAll: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),
            icon: 'assets/svg/home.svg',
          ),
          BottomNavItem(
            page: TrainerWebinarScreen(),
            icon: 'assets/svg/mycourse.svg',
          ),
          BottomNavItem(
            page: MyProfileScreen(),
            icon: 'assets/svg/plans.svg',
            isProfile: true,
          ),
        ];
      case 'client':
        return [
          BottomNavItem(
            page: UserHomeScreen(
              onViewAll: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),
            icon: 'assets/svg/home.svg',
          ),
          BottomNavItem(
            page: UserAllWebinarScreen(),
            icon: 'assets/svg/mycourse.svg',
          ),
          BottomNavItem(
            page: const MyProfileScreen(),
            icon: "assets/svg/mycourse.svg",
            isProfile: true,
          ),
        ];
      default:
        return [
          BottomNavItem(
            page: Center(
              child: Text('🏠 Home', style: TextStyle(fontSize: 24)),
            ),
            icon: 'assets/icons/home.svg',
          ),
          BottomNavItem(
            page: Center(
              child: Text('🏠 Home', style: TextStyle(fontSize: 24)),
            ),
            icon: 'assets/icons/home.svg',
          ),
          BottomNavItem(
            page: Center(
              child: Text('🏠 Home', style: TextStyle(fontSize: 24)),
            ),
            icon: 'assets/icons/home.svg',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // _navItems can still be empty on the very first build, before
    // _loadUserRole()'s setState has run. Guard against indexing into it.
    if (_navItems.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Extra safety: if currentIndex ever drifts out of range for the
    // current _navItems (e.g. role changed), clamp it instead of crashing.
    final int safeIndex = currentIndex < _navItems.length ? currentIndex : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 700;

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,

          /// BODY
          body: _navItems[safeIndex].page,

          /// BOTTOM NAVBAR
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 120 : 68,
                vertical: isTablet ? 6 : 6,
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(isTablet ? 50 : 40),

                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

                  child: Container(
                    height: isTablet ? 90 : 70,

                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 18 : 12,
                      vertical: isTablet ? 12 : 8,
                    ),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.formPrimaryColor.withOpacity(0.24),
                          AppColor.formSecondaryColor.withOpacity(0.24),
                        ],
                      ),

                      borderRadius: BorderRadius.circular(isTablet ? 50 : 40),

                      border: Border.all(
                        color: AppColor.formBorderColor.withOpacity(0.24),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_navItems.length, (index) {
                        final item = _navItems[index];

                        return Expanded(
                          child:
                              item.isProfile
                                  ? _buildProfileItem(isTablet, index)
                                  : _buildItem(
                                    selectedIcon: item.icon,
                                    index: index,
                                    isTablet: isTablet,
                                  ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem({
    required String selectedIcon,
    required int index,
    required bool isTablet,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: isTablet ? 58 : 46,
        height: isTablet ? 58 : 46,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient:
              isSelected
                  ? LinearGradient(colors: AppColor.primaryBlueGradient)
                  : null,

          color: isSelected ? null : Colors.white.withOpacity(0.04),

          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.0 : 0.08),
          ),
        ),

        child: Center(
          child: SvgPicture.asset(
            selectedIcon,
            width: isTablet ? 28 : 22,
            height: isTablet ? 28 : 22,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white : AppColor.blueGrey,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(bool isTablet, int index) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: isTablet ? 58 : 46,
        height: isTablet ? 58 : 46,

        padding: const EdgeInsets.all(3),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient:
              isSelected
                  ? LinearGradient(colors: AppColor.primaryBlueGradient)
                  : null,
        ),

        child: Icon(Icons.person, color: AppColor.ghostwhite),
      ),
    );
  }
}

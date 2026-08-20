import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/onboard_provider.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class OnboardScreen extends StatelessWidget {
  OnboardScreen({Key? key}) : super(key: key);

  final PageController _controller = PageController();

  final List<Map<String, String>> onboardData = [
    {
      "image": "assets/svg/onboard_one.svg",
      "title": "Discover Your Next Passion",
      "desc":
          "Dive into a world of knowledge. Explore thousands of courses across diverse subjects, from cutting-edge tech to creative arts. Your journey to new skills starts here.",
    },
    {
      "image": "assets/svg/onboard_two.svg",
      "title": "Learn Live from Experts",
      "desc":
          "Dive into a world of knowledge. Explore thousands of courses across diverse subjects, from cutting-edge tech to creative arts. Your journey to new skills starts here.",
    },
    {
      "image": "assets/svg/onboard_three.svg",
      "title": "Your Learning, Your Way",
      "desc":
          "Dive into a world of knowledge. Explore thousands of courses across diverse subjects, from cutting-edge tech to creative arts. Your journey to new skills starts here.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardProvider>();

    return Reusablebackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return Column(
              children: [
                /// 🔹 TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/loginscreen');
                      },
                      child: Row(
                        children: [
                          Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColor.ghostwhite,
                              fontSize: isTablet ? 18 : 16,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                /// PAGE VIEW
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardData.length,
                    onPageChanged: provider.setIndex,
                    itemBuilder: (context, index) {
                      final data = onboardData[index];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// IMAGE
                          SvgPicture.asset(
                            data["image"] ?? '',
                            height: isTablet ? 300 : 220,
                          ),

                          SizedBox(height: isTablet ? 30 : 20),

                          /// TITLE
                          Text(
                            data["title"] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.ghostwhite,
                              fontSize: isTablet ? 30 : 24,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 10),

                          /// DESCRIPTION
                          Text(
                            data["desc"] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.lightgray,
                              fontFamily: 'Urbanist',
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                /// 🔹 DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: provider.currentIndex == index ? 18 : 10,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: AppColor.primaryBlueGradient,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 30 : 25),

                /// 🔹 BUTTONS
                Row(
                  children: [
                    /// BACK BUTTON
                    if (provider.currentIndex != 0)
                      InkWell(
                        onTap: () {
                          provider.pareviousPage(_controller);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.ghostwhite),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left,
                            color: AppColor.ghostwhite,
                          ),
                        ),
                      ),

                    if (provider.currentIndex != 0) const SizedBox(width: 10),

                    /// NEXT BUTTON
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (provider.isLastPage(onboardData.length)) {
                            final isSaved = await provider
                                .saveOnboardCompleteInSharedPref(
                                  'finishedData',
                                );

                            if (isSaved) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/loginscreen',
                              );
                            } else {
                              debugPrint("Failed to save onboarding data");
                            }
                          } else {
                            provider.nextPage(_controller, onboardData.length);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 20 : 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: AppColor.primaryBlueGradient,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              provider.isLastPage(onboardData.length)
                                  ? "Get Started"
                                  : "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 40 : 100),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';

class FindLiveClassWidget extends StatelessWidget {
  const FindLiveClassWidget({super.key, required bool isTablet})
    : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a Live Class',
            style: TextStyle(
              color: AppColor.lightgray,
              fontSize: _isTablet ? 26 : 20,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _isTablet ? 28 : 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(2, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: _isTablet ? 24 : 18),
                  child: Container(
                    width: _isTablet ? 320 : 230,
                    padding: EdgeInsets.all(_isTablet ? 16 : 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.formPrimaryColor.withOpacity(0.24),
                          AppColor.formSecondaryColor.withOpacity(0.24),
                        ],
                      ),

                      border: Border.all(
                        color: AppColor.formBorderColor.withOpacity(0.24),
                      ),

                      borderRadius: BorderRadius.circular(10),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: _isTablet ? 160 : 120,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),

                            image: const DecorationImage(
                              image: AssetImage('assets/images/image2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: _isTablet ? 16 : 12),

                        Text(
                          'The Psychology of Color in UX',
                          style: TextStyle(
                            color: AppColor.ghostwhite,
                            fontSize: _isTablet ? 20 : 16,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: _isTablet ? 18 : 14),
                        Row(
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                'assets/svg/calender.svg',
                                width: _isTablet ? 22 : 16,
                                height: _isTablet ? 22 : 16,
                                color: AppColor.lightgray,
                              ),
                            ),
                            SizedBox(width: _isTablet ? 8 : 6),
                            Expanded(
                              child: Text(
                                ': Starts Sep 25',
                                style: TextStyle(
                                  color: AppColor.lightgray,
                                  fontSize: _isTablet ? 18 : 14,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: AppColor.lightgray.withOpacity(0.1),
                          height: _isTablet ? 18 : 14,
                        ),
                        Row(
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                'assets/svg/mentor.svg',
                                width: _isTablet ? 22 : 16,
                                height: _isTablet ? 22 : 16,
                                color: AppColor.lightgray,
                              ),
                            ),
                            SizedBox(width: _isTablet ? 8 : 6),
                            Expanded(
                              child: Text(
                                ': Mentor Jane Doe',
                                style: TextStyle(
                                  color: AppColor.lightgray,
                                  fontSize: _isTablet ? 18 : 14,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

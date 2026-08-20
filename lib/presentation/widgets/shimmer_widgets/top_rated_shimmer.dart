import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:shimmer/shimmer.dart';

class TopRatedShimmer extends StatelessWidget {
  const TopRatedShimmer({super.key, required bool isTablet})
    : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(height: _isTablet ? 22 : 16);
          },
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(_isTablet ? 16 : 10),
              width: double.infinity,
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
              child: Row(
                children: [
                  Stack(
                    children: [
                      // IMAGE SHIMMER
                      Container(
                        width: 168,
                        height: 194,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      ),

                      // PAID BUTTON SHIMMER
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(2),
                            bottomLeft: Radius.circular(2),
                            bottomRight: Radius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: _isTablet ? 18 : 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE
                        Container(
                          width: double.infinity,
                          height: _isTablet ? 20 : 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        SizedBox(height: _isTablet ? 13 : 10),

                        // PRICE
                        Container(
                          width: 100,
                          height: _isTablet ? 22 : 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        SizedBox(height: _isTablet ? 10 : 8),

                        // DESCRIPTION
                        Container(
                          width: double.infinity,
                          height: _isTablet ? 18 : 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        SizedBox(height: _isTablet ? 8 : 6),

                        Container(
                          width: 180,
                          height: _isTablet ? 18 : 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        SizedBox(height: _isTablet ? 16 : 12),

                        // RATING
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),

                            SizedBox(width: _isTablet ? 8 : 6),

                            Row(
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Container(
                                    width: _isTablet ? 20 : 16,
                                    height: _isTablet ? 20 : 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

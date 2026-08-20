import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lms/core/colors.dart';

class ContinueLearningShimmer extends StatelessWidget {
  const ContinueLearningShimmer({super.key, required bool isTablet})
    : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Shimmer
          Container(
            width: 180,
            height: _isTablet ? 28 : 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          SizedBox(height: _isTablet ? 28 : 20),

          ListView.separated(
            itemCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            separatorBuilder: (_, __) {
              return SizedBox(height: _isTablet ? 22 : 16);
            },
            itemBuilder: (context, index) {
              return Container(
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
                ),

                child: Row(
                  children: [
                    /// Image Shimmer
                    Container(
                      width:
                          _isTablet ? screenWidth * 0.16 : screenWidth * 0.24,
                      height:
                          _isTablet ? screenWidth * 0.16 : screenWidth * 0.24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    SizedBox(width: _isTablet ? 18 : 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title Shimmer
                          Container(
                            width: double.infinity,
                            height: _isTablet ? 22 : 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          SizedBox(height: 8),

                          Container(
                            width: screenWidth * 0.4,
                            height: _isTablet ? 22 : 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          SizedBox(height: _isTablet ? 24 : 18),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Progress Bar Shimmer
                                    Container(
                                      height: _isTablet ? 10 : 7,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),

                                    SizedBox(height: _isTablet ? 10 : 6),

                                    /// Percentage Text
                                    Container(
                                      width: 100,
                                      height: _isTablet ? 16 : 12,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: _isTablet ? 24 : 14),

                              /// Play Button Shimmer
                              Container(
                                width: _isTablet ? 54 : 42,
                                height: _isTablet ? 54 : 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
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
        ],
      ),
    );
  }
}

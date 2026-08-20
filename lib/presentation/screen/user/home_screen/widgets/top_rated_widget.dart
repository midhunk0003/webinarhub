// import 'package:flutter/material.dart';
// import 'package:lms/core/colors.dart';
// import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
// import 'package:lms/presentation/widgets/shimmer_widgets/top_rated_shimmer.dart';
// import 'package:provider/provider.dart';

// class TopRatedWidget extends StatelessWidget {
//   const TopRatedWidget({super.key, required bool isTablet})
//     : _isTablet = isTablet;

//   final bool _isTablet;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeProvider>(
//       builder: (context, homeProvider, _) {
//         return (homeProvider.isLoading ||
//                 homeProvider.topRatedCourseList.isEmpty)
//             ? TopRatedShimmer(isTablet: _isTablet)
//             : (homeProvider.topRatedCourseList == null ||
//                 homeProvider.topRatedCourseList.isEmpty)
//             ? SizedBox()
//             : Container(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Top Rated in Your Field',
//                     style: TextStyle(
//                       color: AppColor.lightgray,
//                       fontSize: _isTablet ? 26 : 20,
//                       fontFamily: 'Urbanist',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: _isTablet ? 28 : 20),
//                   ListView.separated(
//                     itemCount: homeProvider.topRatedCourseList.length,
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     itemBuilder: (context, index) {
//                       final topRatedList =
//                           homeProvider.topRatedCourseList[index];
//                       return InkWell(
//                         onTap: () {
//                           topRatedList.isPaid
//                               ? Navigator.pushNamed(
//                                 context,
//                                 '/coursedetailpage',
//                                 arguments: {'isPaid': topRatedList.isPaid},
//                               )
//                               : Navigator.pushNamed(
//                                 context,
//                                 '/coursedetailpage',
//                                 arguments: {'isPaid': topRatedList.isPaid},
//                               );
//                         },
//                         child: Container(
//                           padding: EdgeInsets.all(_isTablet ? 16 : 10),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 AppColor.formPrimaryColor.withOpacity(0.24),
//                                 AppColor.formSecondaryColor.withOpacity(0.24),
//                               ],
//                             ),
//                             border: Border.all(
//                               color: AppColor.formBorderColor.withOpacity(0.24),
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.4),
//                                 offset: const Offset(0, 2),
//                                 blurRadius: 4,
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Stack(
//                                 children: [
//                                   Container(
//                                     width: 168,
//                                     height: 194,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: Colors.grey[300],
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/images/toprated.png',
//                                         ),
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),

//                                   Container(
//                                     decoration: BoxDecoration(
//                                       gradient:
//                                           topRatedList.isPaid
//                                               ? LinearGradient(
//                                                 begin: Alignment.centerLeft,
//                                                 end: Alignment.centerRight,
//                                                 colors:
//                                                     AppColor
//                                                         .primaryBlueGradient,
//                                               )
//                                               : LinearGradient(
//                                                 begin: Alignment.centerLeft,
//                                                 end: Alignment.centerRight,
//                                                 colors:
//                                                     AppColor
//                                                         .primaryGreenGradient,
//                                               ),
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(12),
//                                         topRight: Radius.circular(2),
//                                         bottomLeft: Radius.circular(2),
//                                         bottomRight: Radius.circular(2),
//                                       ),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 10,
//                                         vertical: 2,
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           '${topRatedList.isPaid ? 'Paid' : 'Free'}',
//                                           style: TextStyle(
//                                             color: AppColor.ghostwhite,
//                                             fontSize: 10,
//                                             fontFamily: 'Urbanist',
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(width: _isTablet ? 18 : 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${topRatedList.title ?? ''}',
//                                       style: TextStyle(
//                                         color: AppColor.ghostwhite,
//                                         fontSize: _isTablet ? 20 : 16,
//                                         fontFamily: 'Urbanist',
//                                         fontWeight: FontWeight.w500,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                     SizedBox(height: _isTablet ? 13 : 10),
//                                     Text(
//                                       '${topRatedList.price ?? ''}',
//                                       style: TextStyle(
//                                         color: AppColor.ghostwhite,
//                                         fontSize: _isTablet ? 22 : 18,
//                                         fontFamily: 'Urbanist',
//                                         fontWeight: FontWeight.w600,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                     SizedBox(height: _isTablet ? 10 : 8),
//                                     Text(
//                                       '${topRatedList.description ?? ''}',
//                                       style: TextStyle(
//                                         color: AppColor.lightgray,
//                                         fontSize: _isTablet ? 18 : 14,
//                                         fontFamily: 'Urbanist',
//                                         fontWeight: FontWeight.w400,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                     SizedBox(height: _isTablet ? 16 : 12),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           '${topRatedList.rating ?? ''}',
//                                           style: TextStyle(
//                                             color: AppColor.lightgray,
//                                             fontSize: _isTablet ? 18 : 14,
//                                             fontFamily: 'Urbanist',
//                                             fontWeight: FontWeight.w400,
//                                             height: 1.4,
//                                           ),
//                                         ),
//                                         SizedBox(width: _isTablet ? 8 : 6),
//                                         Row(
//                                           children: List.generate(5, (index) {
//                                             final rating =
//                                                 topRatedList.rating ?? 0.0;

//                                             if (index < rating.floor()) {
//                                               // Full Star
//                                               return Icon(
//                                                 Icons.star,
//                                                 color: Colors.amber,
//                                                 size: _isTablet ? 20 : 16,
//                                               );
//                                             } else if (index < rating) {
//                                               // Half Star
//                                               return Icon(
//                                                 Icons.star_half,
//                                                 color: Colors.amber,
//                                                 size: _isTablet ? 20 : 16,
//                                               );
//                                             } else {
//                                               // Empty Star
//                                               return Icon(
//                                                 Icons.star_border,
//                                                 color: Colors.amber,
//                                                 size: _isTablet ? 20 : 16,
//                                               );
//                                             }
//                                           }),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                     separatorBuilder: (context, index) {
//                       return SizedBox(height: _isTablet ? 22 : 16);
//                     },
//                   ),
//                 ],
//               ),
//             );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:lms/presentation/screen/user/my_profile_screen/widgets/myprofile_menu_list_widget.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_text_form_widget_field.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({Key? key}) : super(key: key);

  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialData();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();

      // API call
      provider.loadCartCourses();

      // Navigation
      // Navigator.push(...);

      // Snackbar/Dialog
      // ScaffoldMessenger.of(context).showSnackBar(...);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool _isTablet = constraints.maxWidth > 600;
          return Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: _isTablet ? 80 : 66),
                    CommonCustomAppBarWidget(
                      isTablet: _isTablet,
                      showBackButton: true,
                      title: "My Cart",
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {
                        print('share');
                      },
                      showShareButton: false,
                    ),
                    SizedBox(height: _isTablet ? 35 : 30),
                    Text(
                      '${profileProvider.selectedCount}/${profileProvider.cartCourses.length}course selected',
                      style: TextStyle(
                        color: AppColor.ghostwhite,
                        fontSize: _isTablet ? 20 : 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: _isTablet ? 29 : 24),
                    ListView.separated(
                      itemCount: profileProvider.cartCourses.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () {
                            print('long press');
                            profileProvider.onLongPress(index);
                            print('${index}');
                          },
                          onTap: () {
                            print('tap');
                            profileProvider.onTap(index);
                          },
                          child: Container(
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
                                color: AppColor.formBorderColor.withOpacity(
                                  0.24,
                                ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Checkbox Left Side
                                if (profileProvider.selectionMode)
                                  GestureDetector(
                                    onTap: () {
                                      profileProvider.onTap(index);
                                    },
                                    child: Container(
                                      width: _isTablet ? 28 : 22,
                                      height: _isTablet ? 28 : 22,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.primaryBlueLight,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(3),

                                        gradient:
                                            profileProvider.selectedItems[index]
                                                ? LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors:
                                                      AppColor
                                                          .primaryBlueGradient,
                                                )
                                                : null,
                                      ),
                                      child:
                                          profileProvider.selectedItems[index]
                                              ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: _isTablet ? 18 : 14,
                                              )
                                              : null,
                                    ),
                                  ),
                                SizedBox(
                                  width:
                                      profileProvider.selectionMode
                                          ? _isTablet
                                              ? 16
                                              : 13
                                          : 0,
                                ),
                                Container(
                                  width: 168,
                                  height: 126,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[300],
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/toprated.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: _isTablet ? 18 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cognitive Psychology: An Introduction',
                                        style: TextStyle(
                                          color: AppColor.ghostwhite,
                                          fontSize: _isTablet ? 20 : 16,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: _isTablet ? 13 : 10),
                                      Text(
                                        '₹2,999',
                                        style: TextStyle(
                                          color: AppColor.ghostwhite,
                                          fontSize: _isTablet ? 22 : 18,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: _isTablet ? 16 : 12),
                                      Row(
                                        children: [
                                          Text(
                                            '4.8',
                                            style: TextStyle(
                                              color: AppColor.lightgray,
                                              fontSize: _isTablet ? 18 : 14,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w400,
                                              height: 1.4,
                                            ),
                                          ),
                                          SizedBox(width: _isTablet ? 8 : 6),
                                          Row(
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < 4
                                                    ? Icons.star
                                                    : Icons.star_border,

                                                color: Colors.amber,
                                                size: _isTablet ? 20 : 16,
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
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: _isTablet ? 22 : 16);
                      },
                    ),
                    SizedBox(height: _isTablet ? 55 : 40),
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price details',
                              style: TextStyle(
                                color: AppColor.blueGrey,
                                fontSize: _isTablet ? 18 : 14,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: _isTablet ? 40 : 20),
                            PriceDetailWidget(
                              isTablet: _isTablet,
                              leftText: "Total MRP",
                              rightText: "₹ 3500",
                            ),
                            SizedBox(height: _isTablet ? 20 : 10),
                            PriceDetailWidget(
                              isTablet: _isTablet,
                              leftText: "Discount on MRP",
                              rightText: "₹ 701",
                              discount: true,
                            ),
                            SizedBox(height: _isTablet ? 18 : 16),
                            PriceDetailWidget(
                              isTablet: _isTablet,
                              leftText: "Total Amount",
                              rightText: "₹ 2,799",
                              totalPriceSize: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: _isTablet ? 130 : 100),
                    // CommonCustomeButtonWidget(
                    //   isTablet: _isTablet,
                    //   text: "Save Changes",
                    //   onTap: () async {
                    //     print('login');
                    //     if (_formKey.currentState!.validate()) {
                    //       print('login');
                    //       // await authProvider.loginProvider(
                    //       //   userNameController.text.trim(),
                    //       //   passwordController.text.trim(),
                    //       // );

                    //       /// ✅ SUCCESS
                    //       // if (authProvider.success != null) {
                    //       //   ScaffoldMessenger.of(context).showSnackBar(
                    //       //     SnackBar(
                    //       //       content: Text(authProvider.success!.message),
                    //       //       backgroundColor: Colors.green,
                    //       //     ),
                    //       //   );

                    //       //   Navigator.pushReplacementNamed(
                    //       //     context,
                    //       //     '/custombottomnavbarwidget',
                    //       //   );
                    //       // }

                    //       /// ❌ FAILURE
                    //       // if (authProvider.failure != null) {
                    //       //   ScaffoldMessenger.of(context).showSnackBar(
                    //       //     SnackBar(
                    //       //       content: Text(
                    //       //         authProvider.failure!.message ?? '',
                    //       //       ),
                    //       //       backgroundColor: Colors.red,
                    //       //     ),
                    //       //   );
                    //       // }
                    //     }
                    //   },
                    // ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PriceDetailWidget extends StatelessWidget {
  final String? leftText;
  final String? rightText;
  final bool discount;
  final bool totalPriceSize;
  const PriceDetailWidget({
    super.key,
    required bool isTablet,
    this.leftText,
    this.rightText,
    this.discount = false,
    this.totalPriceSize = false,
  }) : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${leftText ?? ''}',
          style: TextStyle(
            color: AppColor.ghostwhite,
            fontSize:
                totalPriceSize
                    ? _isTablet
                        ? 20
                        : 16
                    : _isTablet
                    ? 18
                    : 14,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),

        Text(
          '${rightText ?? ''}',
          style: TextStyle(
            color: discount ? Colors.green : AppColor.ghostwhite,
            fontSize:
                totalPriceSize
                    ? _isTablet
                        ? 20
                        : 16
                    : _isTablet
                    ? 18
                    : 14,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

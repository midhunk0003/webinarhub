import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/common_custome_button_widget.dart';
import 'package:lms/presentation/widgets/common_text_form_widget_field.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialData();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      provider.getHelpCenterData();
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
                      title: "Help centre",
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {
                        print('share');
                      },
                      showShareButton: false,
                    ),
                    SizedBox(height: _isTablet ? 35 : 30),
                    CommonTextFormField(
                      isTablet: _isTablet,
                      hintText: "Search for a question or topic..",
                      controller: searchController,
                      isSearch: true,
                    ),
                    SizedBox(height: _isTablet ? 28 : 24),
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      physics: NeverScrollableScrollPhysics(),

                      itemCount: profileProvider.helpCenterData!.length,
                      itemBuilder: (context, indexCategory) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profileProvider.helpCenterData![indexCategory].categoryName ?? ''}',
                              style: TextStyle(
                                color: AppColor.blueGrey,
                                fontSize: _isTablet ? 14 : 12,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: _isTablet ? 20 : 18),
                            ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),

                              itemCount:
                                  profileProvider
                                      .helpCenterData![indexCategory]
                                      .questions!
                                      .length,
                              itemBuilder: (context, indexQuestion) {
                                final questions =
                                    profileProvider
                                        .helpCenterData![indexCategory]
                                        .questions![indexQuestion];
                                return InkWell(
                                  onTap: () {
                                    print('down');
                                    profileProvider.showHideQuestionAnswerPro(
                                      indexCategory,
                                      indexQuestion,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColor.formPrimaryColor.withOpacity(
                                            0.24,
                                          ),
                                          AppColor.formSecondaryColor
                                              .withOpacity(0.24),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: AppColor.formBorderColor
                                            .withOpacity(0.24),
                                      ),
                                      borderRadius: BorderRadius.circular(20),
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
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${questions.question ?? ''}',
                                                  style: TextStyle(
                                                    color: AppColor.ghostwhite,
                                                    fontSize:
                                                        _isTablet ? 18 : 16,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                profileProvider
                                                        .showHideQuestionANdAnswer
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_up,
                                                color: AppColor.ghostwhite,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                profileProvider
                                                        .showHideQuestionANdAnswer
                                                    ? _isTablet
                                                        ? 20
                                                        : 18
                                                    : 0,
                                          ),
                                          profileProvider
                                                  .showHideQuestionANdAnswer
                                              ? Text(
                                                '${questions.answer ?? ''}',
                                                style: TextStyle(
                                                  color: AppColor.lightgray,
                                                  fontSize: _isTablet ? 16 : 14,
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 18);
                              },
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                    ),
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

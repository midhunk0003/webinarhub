import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class TermsAndPrivacyScreen extends StatefulWidget {
  const TermsAndPrivacyScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndPrivacyScreen> createState() => _TermsAndPrivacyScreenState();
}

class _TermsAndPrivacyScreenState extends State<TermsAndPrivacyScreen> {
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialData();
      }
    });
  }

  Future<void> _initialData() async {
    final provider = context.read<UserDashboardProvider>();
    if (!mounted) return;

    await provider.getUserPolicyAndAgreePro();

    if (!mounted) return;

    _handleFailure(provider);
  }

  void _handleFailure(UserDashboardProvider provider) {
    if (_isDialogShowing || !mounted) return;

    final Failure? failure = provider.failure;

    if (failure == null || failure is NetworkFailure) return;

    _isDialogShowing = true;

    AppDialogHelper.showFailureDialog(
      context: context,
      failure: failure,
      provider: provider,
      onTap: () {
        provider.clearFailure();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isTablet ? 80 : 66),

              // Fixed app bar
              CommonCustomAppBarWidget(
                isTablet: isTablet,
                showBackButton: true,
                title: 'Terms and Privacy',
                onBackButtonPressed: () {
                  Navigator.pop(context);
                },
                onShareButtonPressed: () {},
                showShareButton: false,
              ),

              SizedBox(height: isTablet ? 25 : 20),

              // Only this area scrolls.
              Expanded(
                child: Consumer<UserDashboardProvider>(
                  builder: (context, provider, child) {
                    final policies =
                        provider.userPolicyAndAgreeModel?.data ?? [];

                    if (policies.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Terms and privacy content is not available.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.secondaryText,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: isTablet ? 32 : 16,
                          right: isTablet ? 32 : 16,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < policies.length; i++)
                              if ((policies[i].content ?? '').trim().isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < policies.length - 1 ? 24 : 0,
                                  ),
                                  child: HtmlWidget(
                                    policies[i].content!.trim(),
                                    textStyle: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      height: 1.7,
                                      color: AppColor.secondaryText,
                                    ),
                                    customStylesBuilder: (element) {
                                      switch (element.localName) {
                                        case 'h1':
                                        case 'h2':
                                        case 'h3':
                                        case 'h4':
                                          return {
                                            'color': '#CEA96A',
                                            'font-weight': '700',
                                          };
                                        case 'a':
                                          return {'color': '#CEA96A'};
                                        case 'strong':
                                        case 'b':
                                          return {'color': '#FFFFFF'};
                                        default:
                                          return null;
                                      }
                                    },
                                  ),
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

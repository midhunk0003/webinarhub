import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/get_contact_model/get_contact_model.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/diloges/app_dialog_helper.dart';
import 'package:lms/presentation/widgets/network_retry_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  bool _isDialogShowing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialData();
    });
  }

  Future<void> _initialData() async {
    if (!mounted) return;
    final profileProvider = context.read<ProfileProvider>();
    await Future.wait([profileProvider.getContactPro()]);
    if (!mounted) return;
  }

  void _handleFailure(ProfileProvider profileProvider) {
    if (_isDialogShowing) return;

    final failures = <Failure>[
      if (profileProvider.failure != null) profileProvider.failure!,
    ];

    if (!mounted || failures.isEmpty) return;

    final failure = failures.first;

    // Ignore network failure
    if (failure is NetworkFailure) {
      return;
    }

    _isDialogShowing = true;

    AppDialogHelper.showFailureDialog(
      context: context,
      failure: failure,
      provider: profileProvider,
      onTap: () {
        profileProvider.clearFailure();
        Navigator.pop(context);
      },
    );

    if (mounted) {
      _isDialogShowing = false;
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet = constraints.maxWidth > 600;

            return Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) {
                final failure = profileProvider.failure;
                if (failure is NetworkFailure) {
                  return NetWorkRetry(
                    failureMessage:
                        profileProvider.failure?.message ??
                        "No internet connection",
                    onRetry: () async {
                      await _initialData();
                    },
                  );
                }
                final contacts = profileProvider.contactModel?.data ?? [];
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isTablet ? 25 : 15),

                      CommonCustomAppBarWidget(
                        isTablet: isTablet,
                        showBackButton: true,
                        title: "Contact Us",
                        onBackButtonPressed: () {
                          Navigator.pop(context);
                        },
                        onShareButtonPressed: () {},
                        showShareButton: false,
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      _buildHeader(isTablet),

                      SizedBox(height: isTablet ? 35 : 28),

                      if (profileProvider.isLoadingGetContact)
                        _buildLoadingState(isTablet)
                      /*
                       * EMPTY
                       */
                      else if (contacts == null || contacts.isEmpty)
                        _buildEmptyState(isTablet)
                      /*
                       * CONTACT LIST
                       */
                      else
                        _buildContactList(
                          contacts: contacts,
                          isTablet: isTablet,
                        ),

                      SizedBox(height: isTablet ? 50 : 35),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 28 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.28),
            AppColor.formSecondaryColor.withOpacity(0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            height: isTablet ? 70 : 58,
            width: isTablet ? 70 : 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColor.formPrimaryColor,
                  AppColor.formSecondaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.formPrimaryColor.withOpacity(0.25),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: AppColor.ghostwhite,
              size: isTablet ? 36 : 30,
            ),
          ),

          SizedBox(width: isTablet ? 20 : 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We're here to help",
                  style: TextStyle(
                    color: AppColor.ghostwhite,
                    fontSize: isTablet ? 24 : 20,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Have a question or need assistance? "
                  "Get in touch with our support team.",
                  style: TextStyle(
                    color: AppColor.lightgray,
                    fontSize: isTablet ? 16 : 13,
                    height: 1.4,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList({
    required List<ContactList> contacts,
    required bool isTablet,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      separatorBuilder: (_, __) {
        return SizedBox(height: isTablet ? 22 : 16);
      },
      itemBuilder: (context, index) {
        final contact = contacts[index];

        return _buildContactCard(contact: contact, isTablet: isTablet);
      },
    );
  }

  Widget _buildContactCard({
    required ContactList contact,
    required bool isTablet,
  }) {
    final String name = contact.name?.trim() ?? '';
    final String email = contact.email?.trim() ?? '';
    final String phone = contact.phoneNumber?.trim() ?? '';
    final String address = contact.address?.trim() ?? '';
    final String description = contact.description?.trim() ?? '';

    final String initials = _getInitials(name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 26 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.formPrimaryColor.withOpacity(0.20),
            AppColor.formSecondaryColor.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 26 : 22),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
           * PROFILE HEADER
           */
          Row(
            children: [
              Container(
                height: isTablet ? 68 : 56,
                width: isTablet ? 68 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColor.formPrimaryColor,
                      AppColor.formSecondaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: AppColor.ghostwhite,
                      fontSize: isTablet ? 22 : 18,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(width: isTablet ? 18 : 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.ghostwhite,
                        fontSize: isTablet ? 21 : 18,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: isTablet ? 17 : 15,
                            color: AppColor.lightgray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColor.lightgray,
                                fontSize: isTablet ? 14 : 12,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 24 : 20),

          Container(
            height: 1,
            color: AppColor.formBorderColor.withOpacity(0.18),
          ),

          SizedBox(height: isTablet ? 22 : 18),

          /*
           * EMAIL
           */
          if (email.isNotEmpty)
            _buildInfoRow(
              icon: Icons.email_outlined,
              title: "Email",
              value: email,
              isTablet: isTablet,
            ),

          if (email.isNotEmpty && phone.isNotEmpty)
            SizedBox(height: isTablet ? 16 : 13),

          /*
           * PHONE
           */
          if (phone.isNotEmpty)
            _buildInfoRow(
              icon: Icons.phone_outlined,
              title: "Phone",
              value: phone,
              isTablet: isTablet,
            ),

          if (phone.isNotEmpty && address.isNotEmpty)
            SizedBox(height: isTablet ? 16 : 13),

          /*
           * ADDRESS
           */
          if (address.isNotEmpty)
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              title: "Address",
              value: address,
              isTablet: isTablet,
            ),

          if (description.isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 13),
            _buildInfoRow(
              icon: Icons.info_outline_rounded,
              title: "About",
              value: description,
              isTablet: isTablet,
            ),
          ],

          SizedBox(height: isTablet ? 24 : 20),

          /*
           * ACTION BUTTONS
           */
          Row(
            children: [
              if (phone.isNotEmpty)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: "Call",
                    isTablet: isTablet,
                    onTap: () {
                      _makePhoneCall(phone);
                    },
                  ),
                ),

              if (phone.isNotEmpty && email.isNotEmpty)
                SizedBox(width: isTablet ? 14 : 10),

              if (email.isNotEmpty)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.email_rounded,
                    label: "Email",
                    isTablet: isTablet,
                    onTap: () {
                      _sendEmail(email);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: isTablet ? 42 : 36,
          width: isTablet ? 42 : 36,
          decoration: BoxDecoration(
            color: AppColor.formPrimaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColor.ghostwhite,
            size: isTablet ? 21 : 18,
          ),
        ),

        SizedBox(width: isTablet ? 14 : 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColor.lightgray.withOpacity(0.75),
                  fontSize: isTablet ? 13 : 11,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: TextStyle(
                  color: AppColor.ghostwhite,
                  fontSize: isTablet ? 15 : 13,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: isTablet ? 52 : 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.formPrimaryColor.withOpacity(0.85),
                AppColor.formSecondaryColor.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColor.formBorderColor.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColor.ghostwhite, size: isTablet ? 20 : 18),

              const SizedBox(width: 8),

              Text(
                label,
                style: TextStyle(
                  color: AppColor.ghostwhite,
                  fontSize: isTablet ? 15 : 13,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 80 : 60),
        child: Column(
          children: [
            SizedBox(
              height: isTablet ? 42 : 35,
              width: isTablet ? 42 : 35,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColor.formPrimaryColor,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "Loading contact information...",
              style: TextStyle(
                color: AppColor.lightgray,
                fontSize: isTablet ? 16 : 13,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 80 : 60),
        child: Column(
          children: [
            Container(
              height: isTablet ? 80 : 65,
              width: isTablet ? 80 : 65,
              decoration: BoxDecoration(
                color: AppColor.formPrimaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_outlined,
                color: AppColor.lightgray,
                size: isTablet ? 40 : 32,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "No contact information available",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.ghostwhite,
                fontSize: isTablet ? 18 : 15,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Please try again later.",
              style: TextStyle(
                color: AppColor.lightgray,
                fontSize: isTablet ? 15 : 13,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) {
      return "?";
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return "${parts.first.substring(0, 1)}"
            "${parts.last.substring(0, 1)}"
        .toUpperCase();
  }
}

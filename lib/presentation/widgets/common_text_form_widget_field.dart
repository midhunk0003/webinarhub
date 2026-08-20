import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/provider/auth_provider.dart';
import 'package:lms/presentation/provider/user_provider/search_course_provider.dart';
import 'package:provider/provider.dart';

class CommonTextFormField<T extends ChangeNotifier> extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final bool passVisible;
  final bool obscureText;
  final String? Function(String?)? validator;
  final T? provider;
  final bool isSearch;
  final bool searchCourse;

  const CommonTextFormField({
    super.key,
    required bool isTablet,
    required this.hintText,
    required this.controller,
    this.passVisible = false,
    this.obscureText = false,
    this.validator,
    this.provider,
    this.isSearch = false,
    this.searchCourse = false,
  }) : _isTablet = isTablet;

  final bool _isTablet;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    /// ✅ scale factor (base width 375)
    final scale = (width / 375).clamp(0.9, 1.3);

    double rs(double size) => size * scale;

    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: rs(_isTablet ? 58 : 54),
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
                borderRadius: BorderRadius.circular(rs(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),

              child: Consumer<SearchCourseProvider>(
                builder: (context, searchCourseProvider, _) {
                  return TextFormField(
                    controller: controller,
                    obscureText: obscureText,
                    cursorColor: AppColor.formSecondaryColor,
                    style: TextStyle(
                      color: AppColor.primaryText,
                      fontSize: rs(_isTablet ? 15 : 14),
                    ),
                    decoration: InputDecoration(
                      prefixIcon:
                          isSearch
                              ? Icon(
                                Icons.search_rounded,
                                weight: 20,
                                size: 20,
                                color: AppColor.blueGrey,
                              )
                              : null,
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: AppColor.formTextColor,
                        fontSize: rs(_isTablet ? 14 : 13),
                      ),

                      /// Password toggle
                      suffixIcon:
                          passVisible
                              ? IconButton(
                                onPressed: () {
                                  final dynamic p = provider;
                                  if (p is AuthProvider) {
                                    p.showHidePassword();
                                  }
                                },
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: rs(18),
                                ),
                                color: AppColor.formTextColor,
                              )
                              : null,

                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: rs(16),
                        vertical: rs(16),
                      ),

                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      field.didChange(value);
                      field.validate();
                      isSearch ? print('search') : null;
                      searchCourse
                          ? searchCourseProvider.showSearchScreenPro(value)
                          : null;
                    },
                  );
                },
              ),
            ),

            /// ✅ Error text
            if (field.hasError) ...[
              SizedBox(height: rs(6)),
              Padding(
                padding: EdgeInsets.only(left: rs(4)),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: rs(12)),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

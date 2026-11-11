import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/data/model/help_and_support_model/help_and_support_model.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _debounce;

  String? _selectedCategoryId;
  String? _expandedFaqId;
  static const Color primaryColor = AppColor.gold;
  static const Color backgroundColor = AppColor.background;
  static const Color cardColor = AppColor.cardBackground;
  static const Color textColor = AppColor.primaryText;
  static const Color secondaryTextColor = AppColor.secondaryText;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProfileProvider>().getHelpAndSupportPro(null, null);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // Search API with debounce
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _expandedFaqId = null;
      });

      context.read<ProfileProvider>().getHelpAndSupportPro(
        value.trim().isEmpty ? null : value.trim(),
        _selectedCategoryId,
      );
    });
  }

  // Category selection
  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _expandedFaqId = null;
    });

    context.read<ProfileProvider>().getHelpAndSupportPro(
      searchController.text.trim().isEmpty
          ? null
          : searchController.text.trim(),
      categoryId,
    );
  }

  // FAQ accordion
  void _toggleFaq(String faqId) {
    setState(() {
      _expandedFaqId = _expandedFaqId == faqId ? null : faqId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;

          return Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final categories = provider.helpAndSupportCategories;

              // API response after category/search filtering
              final filteredCategories =
                  provider.helpAndSupportModel?.data?.categories ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isTablet ? 80 : 66),

                    // APP BAR
                    CommonCustomAppBarWidget(
                      isTablet: isTablet,
                      showBackButton: true,
                      title: 'Help & Support',
                      showShareButton: false,
                      onBackButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onShareButtonPressed: () {},
                    ),

                    SizedBox(height: 24),

                    // ==================================================
                    // SEARCH BAR
                    // ==================================================
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 0,
                      ),
                      child: _WebinarSearchBar(
                        controller: searchController,
                        onChanged: _onSearchChanged,
                      ),
                    ),

                    SizedBox(height: 20),

                    // CATEGORY FILTER
                    if (categories.isNotEmpty)
                      _buildCategoryFilters(categories, isTablet),

                    SizedBox(height: 24),

                    // LOADING
                    if (provider.isLoadingGetHelpAndSupport)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColor.gold,
                          ),
                        ),
                      )
                    // ERROR
                    else if (provider.failure != null)
                      _buildEmptyState(
                        'Something went wrong',
                        'Please try again later.',
                        Icons.error_outline,
                      )
                    // FAQ LIST
                    else if (filteredCategories.isNotEmpty)
                      _buildFaqList(filteredCategories, isTablet)
                    // EMPTY STATE
                    else
                      _buildEmptyState(
                        'No FAQs found',
                        'Try another search or select a different category.',
                        Icons.help_outline,
                      ),

                    SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // CATEGORY CHIPS
  Widget _buildCategoryFilters(List<Category> categories, bool isTablet) {
    return SizedBox(
      height: isTablet ? 46 : 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(
            title: 'All',
            selected: _selectedCategoryId == null,
            onTap: () => _onCategorySelected(null),
            isTablet: isTablet,
          ),

          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildCategoryChip(
                title: category.name ?? '',
                selected: _selectedCategoryId == category.id,
                onTap: () => _onCategorySelected(category.id),
                isTablet: isTablet,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 22 : 16,
          vertical: isTablet ? 12 : 9,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColor.gold : AppColor.formSecondaryColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                selected
                    ? AppColor.gold
                    : AppColor.formBorderColor.withOpacity(0.45),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? AppColor.buttonText : AppColor.secondaryText,
              fontSize: isTablet ? 14 : 11,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // CATEGORY HEADING + FAQ ITEMS
  Widget _buildFaqList(List<Category> categories, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          categories.map((category) {
            final faqs = category.faqs ?? [];

            if (faqs.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY TITLE
                  Text(
                    (category.name ?? '').toUpperCase(),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: isTablet ? 14 : 11,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),

                  SizedBox(height: isTablet ? 18 : 14),

                  // FAQ QUESTIONS
                  ...List.generate(faqs.length, (index) {
                    final faq = faqs[index];

                    final faqId =
                        faq.id ?? '${category.id ?? category.name}_$index';

                    final isExpanded = _expandedFaqId == faqId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildFaqCard(
                        question: faq.question ?? '',
                        answer: faq.answer ?? '',
                        isExpanded: isExpanded,
                        isTablet: isTablet,
                        onTap: () => _toggleFaq(faqId),
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
    );
  }

  // FAQ CARD
  Widget _buildFaqCard({
    required String question,
    required String answer,
    required bool isExpanded,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 22 : 16),
          decoration: BoxDecoration(
            color: AppColor.formSecondaryColor,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color:
                  isExpanded
                      ? AppColor.gold.withOpacity(0.65)
                      : AppColor.formBorderColor.withOpacity(0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        color: textColor,
                        fontSize: isTablet ? 18 : 15,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: textColor,
                      size: 22,
                    ),
                  ),
                ],
              ),

              // ANSWER
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      answer,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: isTablet ? 15 : 12,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                crossFadeState:
                    isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55),
        child: Column(
          children: [
            Icon(icon, size: 48, color: secondaryTextColor),
            SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 17,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondaryTextColor,
                fontSize: 13,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebinarSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _WebinarSearchBar({required this.controller, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColor.cardBackground.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.formBorderColor.withOpacity(0.10)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: AppColor.gold,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search FAQs, payments, or live sessions...',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColor.gold,
            size: 22,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

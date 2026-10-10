import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/screen/user/home_screen/widgets/home_header_section.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';
import 'package:provider/provider.dart';

import 'package:lms/presentation/provider/payment_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  int? _selectedStatus;
  int? _selectedPaymentMethod;

  String _selectedDate = 'This month';

  DateTime? _fromDate;
  DateTime? _toDate;

  static const Color _background = Color(0xFF000000);
  static const Color _surface = Color(0xFF171717);
  static const Color _sheet = Color(0xFF303030);
  static const Color _primary = Color(0xFFD5E3FF);
  static const Color _secondaryText = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    await context.read<PaymentProvider>().paymentHistoryPro(
      search: _searchController.text.trim(),
      status: _selectedStatus,
      paymentMethod: _selectedPaymentMethod,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), _loadHistory);
  }

  void _selectDateRange(String value) {
    final now = DateTime.now();

    setState(() {
      _selectedDate = value;

      switch (value) {
        case 'This month':
          _fromDate = DateTime(now.year, now.month, 1);
          _toDate = DateTime(now.year, now.month + 1, 1);
          break;

        case 'Last 30 days':
          _fromDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 29));

          _toDate = DateTime(now.year, now.month, now.day + 1);
          break;

        case 'Last 90 days':
          _fromDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 89));

          _toDate = DateTime(now.year, now.month, now.day + 1);
          break;

        default:
          _fromDate = null;
          _toDate = null;
      }
    });

    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 600;

          return Column(
            children: [
              SizedBox(height: isTablet ? 80 : 66),
              // App Bar
              // ==================================================
              // HEADER
              // ==================================================
              CommonCustomAppBarWidget(
                isTablet: isTablet,
                showBackButton: true,
                title: 'Payment History',
                onBackButtonPressed: () {
                  Navigator.pop(context);
                },
                onShareButtonPressed: () {
                  print('share');
                },
                showShareButton: false,
              ),

              const SizedBox(height: 18),
              // ==================================================
              // SEARCH BAR
              // ==================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 0),
                child: _WebinarSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 18),
              _buildFilterBar(),
              const SizedBox(height: 18),
              Expanded(
                child: Consumer<PaymentProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoadingPaymentHistory) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primary),
                      );
                    }

                    if (provider.failure != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              color: _secondaryText,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to load payment history',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loadHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Replace this with the actual public list getter
                    // exposed by your PaymentProvider.
                    final items = provider.items?.data?.items ?? [];

                    if (items.isEmpty) {
                      return RefreshIndicator(
                        color: _primary,
                        onRefresh: _loadHistory,
                        child: ListView(
                          children: const [
                            SizedBox(height: 120),
                            Icon(
                              Icons.receipt_long_outlined,
                              color: _secondaryText,
                              size: 55,
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Your payments will appear here.',
                                style: TextStyle(color: _secondaryText),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _primary,
                      onRefresh: _loadHistory,
                      child: _buildGroupedTransactions(items),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search transactions',
            hintStyle: const TextStyle(color: _secondaryText),
            prefixIcon: const Icon(Icons.search, color: _secondaryText),
            suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              icon: const Icon(Icons.close, color: _secondaryText),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 46,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _filterButton(
            _selectedStatus == null ? 'Status' : _statusLabel(_selectedStatus!),
            () => _showStatusSheet(),
            selected: _selectedStatus != null,
          ),
          const SizedBox(width: 10),
          _filterButton(
            _selectedPaymentMethod == null
                ? 'Payment method'
                : _methodLabel(_selectedPaymentMethod!),
            () => _showPaymentMethodSheet(),
            selected: _selectedPaymentMethod != null,
          ),
          const SizedBox(width: 10),
          _filterButton(
            _selectedDate,
            () => _showDateSheet(),
            selected: _selectedDate != 'All dates',
          ),
        ],
      ),
    );
  }

  Widget _filterButton(
    String label,
    VoidCallback onTap, {
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColor.gold : _background,
          border: Border.all(color: selected ? AppColor.gold : Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColor.formPrimaryColor : Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              Icons.keyboard_arrow_down,
              color: selected ? AppColor.formPrimaryColor : Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'Not Required';
      case 2:
        return 'Pending';
      case 3:
        return 'Processing';
      case 4:
        return 'Paid';
      case 5:
        return 'Failed';
      case 6:
        return 'Cancelled';
      case 7:
        return 'Expired';
      case 8:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 4: // Paid
        return const Color(0xFF69D69B);
      case 5: // Failed
        return const Color(0xFFF1A1A7);
      case 3: // Processing
        return const Color(0xFFF2D5A5);
      default:
        return Colors.white70;
    }
  }

  // Replace these mappings with the actual payment-method
  // values defined by your backend.
  String _methodLabel(int method) {
    switch (method) {
      case 1:
        return 'UPI';
      case 2:
        return 'Razorpay';
      case 3:
        return 'Other';
      default:
        return 'Method $method';
    }
  }

  // Implement these three methods using the bottom-sheet
  // layout shown in your screenshots.
  Future<void> _showStatusSheet() async {
    final value = await _showChoiceSheet<int>(
      title: 'Status',
      options: const [(4, 'Completed'), (5, 'Failed'), (3, 'Processing')],
      selected: _selectedStatus,
      labelBuilder: (value) => value.$2,
    );

    if (value == -1) {
      setState(() => _selectedStatus = null);
    } else if (value != null) {
      setState(() => _selectedStatus = value);
    } else {
      return;
    }

    await _loadHistory();
  }

  Future<void> _showPaymentMethodSheet() async {
    final value = await _showChoiceSheet<int>(
      title: 'Payment method',
      options: const [(1, 'UPI'), (2, 'Razorpay'), (3, 'Other')],
      selected: _selectedPaymentMethod,
      labelBuilder: (value) => value.$2,
    );

    if (value == -1) {
      setState(() => _selectedPaymentMethod = null);
    } else if (value != null) {
      setState(() => _selectedPaymentMethod = value);
    } else {
      return;
    }

    await _loadHistory();
  }

  Future<void> _showDateSheet() async {
    final value = await _showChoiceSheet<String>(
      title: 'Date',
      options: const [
        ('This month', 'This month'),
        ('Last 30 days', 'Last 30 days'),
        ('Last 90 days', 'Last 90 days'),
        ('All dates', 'All dates'),
      ],
      selected: _selectedDate,
      labelBuilder: (value) => value.$2,
    );

    if (value == null) return;

    _selectDateRange(value);
  }

  Future<T?> _showChoiceSheet<T>({
    required String title,
    required List<(T, String)> options,
    required T? selected,
    required String Function((T, String)) labelBuilder,
  }) {
    T? draft = selected;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: _sheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...options.map((option) {
                      final value = option.$1;
                      final isSelected = draft == value;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            if (title == 'Status') ...[
                              Icon(
                                value == 1
                                    ? Icons.check_circle
                                    : value == 2
                                    ? Icons.cancel
                                    : Icons.hourglass_bottom_rounded,
                                color:
                                    value == 1
                                        ? const Color(0xFF69D69B)
                                        : value == 2
                                        ? const Color(0xFFF1A1A7)
                                        : const Color(0xFFF2D5A5),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                labelBuilder(option),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Radio<T>(
                          value: value,
                          groupValue: draft,
                          activeColor: _primary,
                          onChanged: (value) {
                            setSheetState(() => draft = value);
                          },
                        ),
                        onTap: () {
                          setSheetState(() => draft = value);
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: const Color(0xFF17345F),
                        ),
                        onPressed: () => Navigator.pop(sheetContext, draft),
                        child: const Text('Apply'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: () => Navigator.pop(sheetContext, null),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupedTransactions(List<dynamic> items) {
    // Use createdAt when paidAt is absent so failed payments
    // are also included in their appropriate month.
    final datedItems =
        items.where((item) {
          return item.createdAt != null || item.paidAt != null;
        }).toList();

    datedItems.sort((a, b) {
      final aDate = DateTime.tryParse((a.paidAt ?? a.createdAt).toString());
      final bDate = DateTime.tryParse((b.paidAt ?? b.createdAt).toString());

      return (bDate ?? DateTime(1970)).compareTo(aDate ?? DateTime(1970));
    });

    final Map<String, List<dynamic>> groups = {};

    for (final item in datedItems) {
      final rawDate = item.paidAt ?? item.createdAt;
      final date = DateTime.tryParse(rawDate.toString())?.toLocal();

      if (date == null) continue;

      final key = DateFormat('yyyy-MM').format(date);
      groups.putIfAbsent(key, () => []).add(item);
    }

    if (groups.isEmpty) {
      return const Center(
        child: Text(
          'No dated transactions found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children:
          groups.entries.map((entry) {
            final date = DateFormat('yyyy-MM').parse(entry.key);

            // This is a signed total of the displayed amounts.
            // Adjust the sign convention if your backend uses
            // different accounting rules for failed/refunded payments.
            final total = entry.value.fold<double>(0, (sum, item) {
              final amount =
                  double.tryParse(item.amount?.toString() ?? '0') ?? 0;

              return sum + amount;
            });

            final currency = entry.value.first.currency?.toString() ?? 'INR';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFF101010),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy').format(date),
                            style: const TextStyle(
                              color: _secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('MMMM').format(date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '$currency ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF69D69B),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map((item) => _buildTransactionTile(item)),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildTransactionTile(dynamic item) {
    final title =
        item.webinarTitle?.toString().trim().isNotEmpty == true
            ? item.webinarTitle.toString()
            : 'Payment transaction';

    final rawDate = item.paidAt ?? item.createdAt;
    final date = DateTime.tryParse(rawDate.toString())?.toLocal();

    final status = int.tryParse(item.status?.toString() ?? '');

    final amount = double.tryParse(item.amount?.toString() ?? '0') ?? 0;

    final currency = item.currency?.toString() ?? 'INR';

    final dateLabel =
        date == null ? 'Date unavailable' : DateFormat('d MMMM').format(date);

    final statusLabel =
        item.statusName?.toString().trim().isNotEmpty == true
            ? item.statusName.toString()
            : _statusLabel(status ?? 0);

    final color = _statusColor(status ?? 0);

    return InkWell(
      onTap: () => _showTransactionDetails(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF242424),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.white70,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dateLabel,
                    style: const TextStyle(color: _secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        status == 1
                            ? Icons.check_circle
                            : status == 2
                            ? Icons.cancel
                            : Icons.hourglass_bottom_rounded,
                        color: color,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          statusLabel,
                          style: TextStyle(color: color, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$currency ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _detailRow(
                  'Transaction ID',
                  item.transactionId?.toString() ?? '-',
                ),
                _detailRow('Payment ID', item.paymentId?.toString() ?? '-'),
                _detailRow(
                  'Payment method',
                  item.paymentMethodName?.toString() ?? '-',
                ),
                _detailRow(
                  'Gateway payment ID',
                  item.gatewayPaymentId?.toString() ?? '-',
                ),
                _detailRow('Status', item.statusName?.toString() ?? '-'),
                _detailRow(
                  'Amount',
                  '${item.currency ?? 'INR'} '
                      '${item.amount ?? 0}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: _secondaryText)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
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
          hintText: 'Search webinars...',
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

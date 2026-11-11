import 'package:flutter/material.dart';

import 'package:lms/core/failure.dart';

import 'package:lms/core/success.dart';

import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';

import 'package:lms/data/model/create_payment_order_model/create_payment_order_model.dart';
import 'package:lms/data/model/monthly_transation_summery_model/monthly_transation_summery_model.dart';

import 'package:lms/data/model/payment_history_model/payment_history_model.dart';

import 'package:lms/data/model/payment_session_model.dart';

import 'package:lms/data/model/payment_verify_model/payment_verify_model.dart';

import 'package:lms/domain/repository/payment_repository.dart';

import 'package:url_launcher/url_launcher.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository paymentRepository;

  PaymentProvider({required this.paymentRepository});

  // ============================================================

  // LOADING STATES

  // ============================================================

  bool _isLoadingAvailablePayment = false;

  bool _isLoadingCreatePaymentOrder = false;

  bool _isLoadingVerifyPayment = false;

  bool _isLoadingPaymentHistory = false;

  bool _isLoadingMorePaymentHistory = false;

  bool _hasMorePaymentHistory = true;

  int _paymentHistoryCurrentPage = 1;

  final int _paymentHistoryPageSize = 7;

  // ============================================================

  // PAYMENT STATE

  // ============================================================

  int? _selectedPaymentIndex;

  /// Holds payment information while Razorpay checkout is running.

  ///

  /// This MUST remain available until backend verification succeeds.

  PaymentSession? _paymentSession;

  Failure? _failure;

  Success? _success;

  AvailablePaymentGateWaysModel? _availablePaymentGateWaysModel;

  CreatePaymentOrderModel? _createPaymentOrderModel;

  PaymentVerifyModel? _paymentVerifyModel;

  PaymentHistoryModel? _items;

  final List<dynamic> _paymentHistoryItems = [];

  MonthlyTransationSummeryModel? _monthlySummaryModel;

  MonthlyTransationSummeryModel? get monthlySummaryModel =>
      _monthlySummaryModel;

  List<MonthlySummeryDataList> get monthlySummaryItems =>
      _monthlySummaryModel?.data ?? [];

  // ============================================================

  // GETTERS

  // ============================================================

  bool get isLoadingAvailablePayment => _isLoadingAvailablePayment;

  bool get isLoadingCreatePaymentOrder => _isLoadingCreatePaymentOrder;

  bool get isLoadingVerifyPayment => _isLoadingVerifyPayment;

  bool get isLoadingPaymentHistory => _isLoadingPaymentHistory;

  bool get isLoadingMorePaymentHistory => _isLoadingMorePaymentHistory;

  bool get hasMorePaymentHistory => _hasMorePaymentHistory;

  int get paymentHistoryCurrentPage => _paymentHistoryCurrentPage;

  int? get selectedPaymentIndex => _selectedPaymentIndex;

  Failure? get failure => _failure;

  Success? get success => _success;

  AvailablePaymentGateWaysModel? get availablePaymentGateWaysModel =>
      _availablePaymentGateWaysModel;

  CreatePaymentOrderModel? get createPaymentOrderModel =>
      _createPaymentOrderModel;

  PaymentVerifyModel? get paymentVerifyModel => _paymentVerifyModel;

  PaymentSession? get paymentSession => _paymentSession;

  PaymentHistoryModel? get items => _items;

  List<dynamic> get paymentHistoryItems =>
      List.unmodifiable(_paymentHistoryItems);

  // ============================================================

  // PAYMENT SESSION

  // ============================================================

  /// Store the pending payment session.

  ///

  /// This is called after the backend successfully creates

  /// the payment order and BEFORE opening Razorpay.

  void setPaymentSession(PaymentSession session) {
    _paymentSession = session;

    debugPrint('========================================');

    debugPrint('PAYMENT SESSION CREATED');

    debugPrint('Backend Payment ID: ${session.backendPaymentId}');

    debugPrint('Razorpay Order ID: ${session.razorpayOrderId}');

    debugPrint('Amount: ${session.amount}');

    debugPrint('Currency: ${session.currency}');

    debugPrint('========================================');

    notifyListeners();
  }

  /// Clear pending payment session.

  ///

  /// IMPORTANT:

  /// Call this ONLY after backend payment verification succeeds.

  void clearPaymentSession() {
    debugPrint('========================================');

    debugPrint('CLEARING PAYMENT SESSION');

    debugPrint('Previous session: $_paymentSession');

    debugPrint('========================================');

    _paymentSession = null;

    notifyListeners();
  }

  // ============================================================

  // SELECTED PAYMENT INDEX

  // ============================================================

  void setSelectedPaymentIndex(int index) {
    _selectedPaymentIndex = index;

    notifyListeners();
  }

  void clearSelectedPaymentIndex() {
    _selectedPaymentIndex = null;

    notifyListeners();
  }

  // ============================================================

  // FAILURE / SUCCESS

  // ============================================================

  void clearFailure() {
    _failure = null;

    notifyListeners();
  }

  void clearSuccess() {
    _success = null;

    notifyListeners();
  }

  // ============================================================

  // AVAILABLE PAYMENT GATEWAYS

  // ============================================================

  Future<void> getAvailablePaymentWayPro() async {
    _isLoadingAvailablePayment = true;

    _availablePaymentGateWaysModel = null;

    _failure = null;

    _success = null;

    notifyListeners();

    try {
      final result = await paymentRepository.getAvailablePayment();

      result.fold(
        (failure) {
          _failure = failure;
        },

        (success) {
          _availablePaymentGateWaysModel = success;
        },
      );
    } catch (e) {
      debugPrint('getAvailablePaymentWayPro exception: $e');

      _failure = ServerFailure('Unable to load payment gateways.');
    } finally {
      _isLoadingAvailablePayment = false;

      notifyListeners();
    }
  }

  // ============================================================

  // CLEAR PAYMENT STATE

  // ============================================================

  void clearPaymentState() {
    _paymentSession = null;

    _createPaymentOrderModel = null;

    _failure = null;

    _success = null;

    _isLoadingCreatePaymentOrder = false;

    _isLoadingAvailablePayment = false;

    _selectedPaymentIndex = null;

    notifyListeners();
  }

  // ============================================================

  // CREATE PAYMENT ORDER

  // ============================================================

  Future<void> createPaymentOrderPro(
    String? gatewaySettingId,

    String? webinarId,

    int selectedIndex,
  ) async {
    _isLoadingCreatePaymentOrder = true;

    _selectedPaymentIndex = selectedIndex;

    _createPaymentOrderModel = null;

    _failure = null;

    _success = null;

    _paymentSession = null;

    notifyListeners();

    try {
      final result = await paymentRepository.createPaymentOrder(
        gatewaySettingId,

        webinarId,
      );

      result.fold(
        (failure) {
          _failure = failure;

          _isLoadingCreatePaymentOrder = false;

          _selectedPaymentIndex = null;
        },

        (success) {
          _createPaymentOrderModel = success;

          _isLoadingCreatePaymentOrder = false;

          _selectedPaymentIndex = null;
        },
      );
    } catch (e) {
      debugPrint('createPaymentOrderPro exception: $e');

      _failure = ServerFailure('Unable to create payment order.');
    } finally {
      notifyListeners();
    }
  }

  // ============================================================

  // VERIFY PAYMENT

  // ============================================================

  Future<void> verifyPaymentPro(
    String? paymentId,

    String? gatewayOrderId,

    String? gatewayPaymentId,

    String? signature,
  ) async {
    _isLoadingVerifyPayment = true;

    _paymentVerifyModel = null;

    _failure = null;

    _success = null;

    notifyListeners();

    final result = await paymentRepository.paymentVerify(
      paymentId,

      gatewayOrderId,

      gatewayPaymentId,

      signature,
    );

    result.fold(
      (failure) {
        _failure = failure;

        _isLoadingVerifyPayment = false;

        notifyListeners();
      },

      (success) {
        _paymentVerifyModel = success;

        _isLoadingVerifyPayment = false;

        notifyListeners();
      },
    );
  }

  // ============================================================

  // CHECK VERIFICATION SUCCESS

  // ============================================================

  bool get isPaymentVerified {
    final model = _paymentVerifyModel;

    if (model == null) {
      return false;
    }

    return model.success?.trim().toLowerCase() == 'true';
  }

  Future<void> paymentHistoryPro({
    String? search,

    int? status,

    int? paymentMethod,

    DateTime? fromDate,

    DateTime? toDate,

    bool loadMore = false,
  }) async {
    if (_isLoadingPaymentHistory || _isLoadingMorePaymentHistory) return;

    if (loadMore && !_hasMorePaymentHistory) return;

    if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
      _failure = ServerFailure('From date cannot be after To date.');

      notifyListeners();

      return;
    }

    if (loadMore) {
      _isLoadingMorePaymentHistory = true;
    } else {
      _isLoadingPaymentHistory = true;

      _failure = null;

      _paymentHistoryCurrentPage = 0;

      _hasMorePaymentHistory = true;

      _paymentHistoryItems.clear();

      _items = null;
    }

    final requestedPage = loadMore ? _paymentHistoryCurrentPage + 1 : 1;

    notifyListeners();

    try {
      final result = await paymentRepository.getPaymentHistory(
        search: search,

        status: status,

        paymentMethod: paymentMethod,

        fromDate: fromDate,

        toDate: toDate,

        // Important: pass the requested page and page size.
        page: requestedPage,

        pageSize: _paymentHistoryPageSize,
      );

      result.fold(
        (failure) {
          _failure = failure;
        },

        (model) {
          _items = model;

          final List<dynamic> newItems = List<dynamic>.from(
            model.data?.items ?? const <dynamic>[],
          );

          if (!loadMore) {
            _paymentHistoryItems.clear();
          }

          final existingKeys =
              _paymentHistoryItems
                  .map(_paymentHistoryKey)
                  .where((key) => key.isNotEmpty)
                  .toSet();

          var addedCount = 0;

          for (final item in newItems) {
            final key = _paymentHistoryKey(item);

            if (key.isEmpty) {
              _paymentHistoryItems.add(item);

              addedCount++;
            } else if (existingKeys.add(key)) {
              _paymentHistoryItems.add(item);

              addedCount++;
            }
          }

          _paymentHistoryCurrentPage = requestedPage;

          _hasMorePaymentHistory =
              newItems.length >= _paymentHistoryPageSize &&
              (addedCount > 0 || !loadMore);

          _failure = null;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('paymentHistoryPro error: $e');

      debugPrintStack(stackTrace: stackTrace);

      _failure = ServerFailure('Unable to load payment history.');
    } finally {
      _isLoadingPaymentHistory = false;

      _isLoadingMorePaymentHistory = false;

      notifyListeners();
    }
  }

  Future<void> getMonthlySummaryPro() async {
    try {
      final result = await paymentRepository.getMonthlyTransactionSummary();

      result.fold(
        (failure) {
          debugPrint('Monthly summary error: $failure');
        },
        (success) {
          _monthlySummaryModel = success;
        },
      );
    } catch (e) {
      debugPrint('Monthly summary exception: $e');
    } finally {
      notifyListeners();
    }
  }

  String _paymentHistoryKey(dynamic item) {
    final transactionId = item.transactionId?.toString().trim() ?? '';

    if (transactionId.isNotEmpty && transactionId != 'null') {
      return 'transaction:$transactionId';
    }

    final paymentId = item.paymentId?.toString().trim() ?? '';

    if (paymentId.isNotEmpty && paymentId != 'null') {
      return 'payment:$paymentId';
    }

    final gatewayPaymentId = item.gatewayPaymentId?.toString().trim() ?? '';

    if (gatewayPaymentId.isNotEmpty && gatewayPaymentId != 'null') {
      return 'gateway:$gatewayPaymentId';
    }

    return '';
  }

  // ZOOM

  // ============================================================

  Future<void> launchZoomMeeting(String meetingUrl) async {
    final Uri uri = Uri.parse(meetingUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

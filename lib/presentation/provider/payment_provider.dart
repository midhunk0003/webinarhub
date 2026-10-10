import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';
import 'package:lms/data/model/create_payment_order_model/create_payment_order_model.dart';
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

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoadingAvailablePayment => _isLoadingAvailablePayment;

  bool get isLoadingCreatePaymentOrder => _isLoadingCreatePaymentOrder;

  bool get isLoadingVerifyPayment => _isLoadingVerifyPayment;

  bool get isLoadingPaymentHistory => _isLoadingPaymentHistory;

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
  }) async {
    if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
      _failure = ServerFailure('From date cannot be after To date.');
      notifyListeners();
      return;
    }
    _isLoadingPaymentHistory = true;
    _failure = null;
    notifyListeners();
    try {
      final result = await paymentRepository.getPaymentHistory(
        search: search,
        status: status,
        paymentMethod: paymentMethod,
        fromDate: fromDate,
        toDate: toDate,
      );
      result.fold((f) => _failure = f, (model) => _items = model);
    } catch (_) {
      _failure = ServerFailure('Unable to load payment history.');
    } finally {
      _isLoadingPaymentHistory = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ZOOM
  // ============================================================

  Future<void> launchZoomMeeting(String meetingUrl) async {
    final Uri uri = Uri.parse(meetingUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';
import 'package:lms/data/model/create_payment_order_model/create_payment_order_model.dart';
import 'package:lms/domain/repository/payment_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository paymentRepository;

  PaymentProvider({required this.paymentRepository});

  bool _isLoadingAvailablePayment = false;
  bool _isLoadingCreatePaymentOrder = false;

  int? _selectedPaymentIndex;

  Failure? _failure;
  Success? _success;
  AvailablePaymentGateWaysModel? _availablePaymentGateWaysModel;
  CreatePaymentOrderModel? _createPaymentOrderModel;

  // getter

  bool get isLoadingAvailablePayment => _isLoadingAvailablePayment;
  bool get isLoadingCreatePaymentOrder => _isLoadingCreatePaymentOrder;

  int? get selectedPaymentIndex => _selectedPaymentIndex;

  Failure? get failure => _failure;
  Success? get success => _success;
  AvailablePaymentGateWaysModel? get availablePaymentGateWaysModel =>
      _availablePaymentGateWaysModel;
  CreatePaymentOrderModel? get createPaymentOrderModel =>
      _createPaymentOrderModel;

  // functions

  // ============================================================
  // SET SELECTED PAYMENT INDEX
  // ============================================================

  void setSelectedPaymentIndex(int index) {
    _selectedPaymentIndex = index;
    notifyListeners();
  }

  // ============================================================
  // CLEAR SELECTED INDEX
  // ============================================================

  void clearSelectedPaymentIndex() {
    _selectedPaymentIndex = null;
    notifyListeners();
  }

  void clearFailure() {
    _failure = null;
    print('aaaaaaaaaaaa');
    notifyListeners();
  }

  void clearSuccess() {
    _success = null;
    notifyListeners();
  }

  Future<void> getAvailablePaymentWayPro() async {
    _isLoadingAvailablePayment = true;
    _availablePaymentGateWaysModel = null;
    _failure = null;
    _success = null;
    notifyListeners();

    final result = await paymentRepository.getAvailablePayment();
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingAvailablePayment = false;
        notifyListeners();
      },
      (success) {
        _availablePaymentGateWaysModel = success;
        _isLoadingAvailablePayment = false;
        notifyListeners();
      },
    );
  }

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
    notifyListeners();

    final result = await paymentRepository.createPaymentOrder(
      gatewaySettingId,
      webinarId,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingCreatePaymentOrder = false;
        _selectedPaymentIndex = null;
        notifyListeners();
      },
      (success) {
        _createPaymentOrderModel = success;
        _isLoadingCreatePaymentOrder = false;
        _selectedPaymentIndex = null;
        notifyListeners();
      },
    );
  }

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('sssssssssssssss : ${meetingUrl}');
    final Uri uri = Uri.parse(meetingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

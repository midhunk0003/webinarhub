import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();

  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  bool _isInitialized = false;
  bool _isCheckoutOpen = false;
  bool _isDisposed = false;

  void initialize({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    if (_isDisposed) {
      throw StateError('RazorpayService has already been disposed.');
    }

    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;

    if (_isInitialized) {
      return;
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isInitialized = true;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _isCheckoutOpen = false;

    debugPrint('[Razorpay] Payment success: ${response.paymentId}');

    // Don't log signature in production.
    _onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isCheckoutOpen = false;

    debugPrint(
      '[Razorpay] Payment failed: '
      '${response.code} - ${response.message}',
    );

    _onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _isCheckoutOpen = false;

    debugPrint('[Razorpay] External wallet: ${response.walletName}');

    _onExternalWallet?.call(response);
  }

  void openCheckout({
    required String keyId,
    required String orderId,
    required double amount,
    required String name,
    required String description,
    String currency = 'INR',
    String? email,
    String? contact,
  }) {
    _validateState();

    final cleanKeyId = keyId.trim();
    final cleanOrderId = orderId.trim();
    final cleanCurrency = currency.trim().toUpperCase();
    final cleanName = name.trim();
    final cleanDescription = description.trim();

    if (cleanKeyId.isEmpty) {
      throw ArgumentError('Razorpay key ID is empty.');
    }

    if (cleanOrderId.isEmpty) {
      throw ArgumentError('Razorpay order ID is empty.');
    }

    if (amount <= 0 || !amount.isFinite) {
      throw ArgumentError('Invalid payment amount.');
    }

    if (cleanName.isEmpty) {
      throw ArgumentError('Payment name is empty.');
    }

    if (_isCheckoutOpen) {
      debugPrint('[Razorpay] Checkout already open.');
      return;
    }

    final amountInSmallestUnit = (amount * 100).round();

    final Map<String, dynamic> options = {
      'key': cleanKeyId,
      'amount': amountInSmallestUnit,
      'currency': cleanCurrency,
      'order_id': cleanOrderId,
      'name': cleanName,
      'description': cleanDescription,
      'retry': {'enabled': true, 'max_count': 4},
      'theme': {'color': '#3399CC'},
    };

    if (email != null && email.trim().isNotEmpty ||
        contact != null && contact.trim().isNotEmpty) {
      options['prefill'] = {
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (contact != null && contact.trim().isNotEmpty)
          'contact': contact.trim(),
      };
    }

    try {
      _isCheckoutOpen = true;
      _razorpay.open(options);
    } catch (e) {
      _isCheckoutOpen = false;
      rethrow;
    }
  }

  void _validateState() {
    if (_isDisposed) {
      throw StateError('RazorpayService has already been disposed.');
    }

    if (!_isInitialized) {
      throw StateError('RazorpayService is not initialized.');
    }
  }

  bool get isCheckoutOpen => _isCheckoutOpen;

  void dispose() {
    if (_isDisposed) {
      return;
    }

    _razorpay.clear();

    _onPaymentSuccess = null;
    _onPaymentError = null;
    _onExternalWallet = null;

    _isCheckoutOpen = false;
    _isInitialized = false;
    _isDisposed = true;
  }
}

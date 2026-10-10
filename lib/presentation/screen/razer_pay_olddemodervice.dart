// // import 'package:flutter/foundation.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';

// // class RazorpayService {
// //   final Razorpay _razorpay = Razorpay();

// //   Function(PaymentSuccessResponse)? _onPaymentSuccess;
// //   Function(PaymentFailureResponse)? _onPaymentError;
// //   Function(ExternalWalletResponse)? _onExternalWallet;

// //   void initialize({
// //     required Function(PaymentSuccessResponse) onPaymentSuccess,
// //     required Function(PaymentFailureResponse) onPaymentError,
// //     required Function(ExternalWalletResponse) onExternalWallet,
// //   }) {
// //     _onPaymentSuccess = onPaymentSuccess;
// //     _onPaymentError = onPaymentError;
// //     _onExternalWallet = onExternalWallet;

// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }

// // void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //   debugPrint('Razorpay Payment Success: ${response.paymentId}');

// //   _onPaymentSuccess?.call(response);
// // }

// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     debugPrint(
// //       'Razorpay Payment Error: '
// //       '${response.code} - ${response.message}',
// //     );

// //     _onPaymentError?.call(response);
// //   }

// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     debugPrint('Razorpay External Wallet: ${response.walletName}');

// //     _onExternalWallet?.call(response);
// //   }

// //   // tmss5JL2TqERBe9pttiz3uSX
// //   void openCheckout({
// //     required String keyId,
// //     required String orderId,
// //     required double amount,
// //     required String name,
// //     required String description,
// //     String? email,
// //     String? contact,
// //   }) {
// //     final options = {
// //       'key': keyId,
// //       'amount': amount * 100,
// //       'name': name,
// //       'description': description,

// //       'retry': {'enabled': true, 'max_count': 4},

// //       if (email != null || contact != null)
// //         'prefill': {
// //           if (email != null) 'email': email,
// //           if (contact != null) 'contact': contact,
// //         },

// //       'theme': {'color': '#3399CC'},
// //     };

// //     try {
// //       _razorpay.open(options);
// //     } catch (e) {
// //       debugPrint('Unable to open Razorpay: $e');
// //       rethrow;
// //     }
// //   }

// //   void dispose() {
// //     _razorpay.clear();

// //     _onPaymentSuccess = null;
// //     _onPaymentError = null;
// //     _onExternalWallet = null;
// //   }
// // }

// import 'package:flutter/foundation.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// /// Handles Razorpay checkout lifecycle.
// ///
// /// Responsibilities:
// /// - Initialize Razorpay listeners
// /// - Open Razorpay checkout
// /// - Receive Razorpay callbacks
// /// - Prevent duplicate checkout
// /// - Clean up listeners
// ///
// /// This class does NOT verify payments or grant course access.
// /// Payment verification must be performed by your backend.
// class RazorpayService {
//   RazorpayService();

//   final Razorpay _razorpay = Razorpay();

//   Function(PaymentSuccessResponse)? _onPaymentSuccess;
//   Function(PaymentFailureResponse)? _onPaymentError;
//   Function(ExternalWalletResponse)? _onExternalWallet;

//   bool _isInitialized = false;
//   bool _isCheckoutOpen = false;
//   bool _isDisposed = false;

//   // ============================================================
//   // INITIALIZE
//   // ============================================================

//   /// Initializes Razorpay event listeners.
//   ///
//   /// Call this once before [openCheckout].
//   void initialize({
//     required Function(PaymentSuccessResponse) onPaymentSuccess,
//     required Function(PaymentFailureResponse) onPaymentError,
//     required Function(ExternalWalletResponse) onExternalWallet,
//   }) {
//     if (_isDisposed) {
//       throw StateError('RazorpayService has already been disposed.');
//     }

//     // Already initialized.
//     //
//     // We update callbacks so the latest callbacks are used,
//     // without registering duplicate Razorpay listeners.
//     if (_isInitialized) {
//       _onPaymentSuccess = onPaymentSuccess;
//       _onPaymentError = onPaymentError;
//       _onExternalWallet = onExternalWallet;

//       _log('RazorpayService already initialized. Callbacks updated.');

//       return;
//     }

//     _onPaymentSuccess = onPaymentSuccess;
//     _onPaymentError = onPaymentError;
//     _onExternalWallet = onExternalWallet;

//     // Register Razorpay listeners only once.
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//     _isInitialized = true;

//     _log('RazorpayService initialized.');
//   }

//   // ============================================================
//   // PAYMENT SUCCESS
//   // ============================================================

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     _isCheckoutOpen = false;

//     _log('Razorpay payment success.');
//     _log('Payment ID: ${response.paymentId}');
//     _log('Order ID: ${response.orderId}');

//     // Do NOT log the signature in production.
//     //
//     // The signature is sensitive payment verification data.
//     // Send it to your backend for verification.

//     try {
//       _onPaymentSuccess?.call(response);
//     } catch (e, stackTrace) {
//       _log('Payment success callback failed: $e');
//       _log('$stackTrace');
//     }
//   }

//   // ============================================================
//   // PAYMENT ERROR
//   // ============================================================

//   void _handlePaymentError(PaymentFailureResponse response) {
//     _isCheckoutOpen = false;

//     _log('Razorpay payment failed.');
//     _log('Code: ${response.code}');
//     _log('Message: ${response.message}');

//     try {
//       _onPaymentError?.call(response);
//     } catch (e, stackTrace) {
//       _log('Payment error callback failed: $e');
//       _log('$stackTrace');
//     }
//   }

//   // ============================================================
//   // EXTERNAL WALLET
//   // ============================================================

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     _isCheckoutOpen = false;

//     _log('Razorpay external wallet: ${response.walletName}');

//     try {
//       _onExternalWallet?.call(response);
//     } catch (e, stackTrace) {
//       _log('External wallet callback failed: $e');
//       _log('$stackTrace');
//     }
//   }

//   // ============================================================
//   // OPEN CHECKOUT
//   // ============================================================

//   /// Opens Razorpay checkout.
//   ///
//   /// [amount] must be provided in INR.
//   ///
//   /// Example:
//   ///
//   ///     amount: 500
//   ///
//   /// will internally become:
//   ///
//   ///     50000 paise
//   ///
//   /// [orderId] must be the Razorpay order ID generated
//   /// by your backend.
//   void openCheckout({
//     required String keyId,
//     required String orderId,
//     required double amount,
//     required String name,
//     required String description,
//     String currency = 'INR',
//     String? email,
//     String? contact,
//   }) {
//     _validateServiceState();

//     final cleanKeyId = keyId.trim();
//     final cleanOrderId = orderId.trim();
//     final cleanCurrency = currency.trim().toUpperCase();
//     final cleanName = name.trim();
//     final cleanDescription = description.trim();

//     // ----------------------------------------------------------
//     // VALIDATION
//     // ----------------------------------------------------------

//     if (cleanKeyId.isEmpty) {
//       throw ArgumentError('Razorpay key ID cannot be empty.');
//     }

//     if (cleanOrderId.isEmpty) {
//       throw ArgumentError('Razorpay order ID cannot be empty.');
//     }

//     if (amount <= 0) {
//       throw ArgumentError('Payment amount must be greater than zero.');
//     }

//     if (!amount.isFinite) {
//       throw ArgumentError('Payment amount must be a valid number.');
//     }

//     if (cleanCurrency.isEmpty) {
//       throw ArgumentError('Currency cannot be empty.');
//     }

//     if (cleanName.isEmpty) {
//       throw ArgumentError('Payment name cannot be empty.');
//     }

//     // ----------------------------------------------------------
//     // PREVENT DOUBLE CHECKOUT
//     // ----------------------------------------------------------

//     if (_isCheckoutOpen) {
//       _log(
//         'Razorpay checkout is already open. '
//         'Ignoring duplicate request.',
//       );

//       return;
//     }

//     // ----------------------------------------------------------
//     // AMOUNT → SMALLEST CURRENCY UNIT
//     // ----------------------------------------------------------

//     final int amountInSmallestUnit = (amount * 100).round();

//     if (amountInSmallestUnit <= 0) {
//       throw ArgumentError('Calculated payment amount is invalid.');
//     }

//     // ----------------------------------------------------------
//     // CHECKOUT OPTIONS
//     // ----------------------------------------------------------

//     final Map<String, dynamic> options = {
//       'key': cleanKeyId,
//       'amount': amountInSmallestUnit,
//       'currency': cleanCurrency,

//       // IMPORTANT:
//       // This must be the order ID generated by your backend.
//       'order_id': cleanOrderId,

//       'name': cleanName,
//       'description': cleanDescription,

//       'retry': {'enabled': true, 'max_count': 4},

//       'theme': {'color': '#3399CC'},
//     };

//     // ----------------------------------------------------------
//     // PREFILL
//     // ----------------------------------------------------------

//     final cleanEmail = email?.trim();
//     final cleanContact = contact?.trim();

//     final bool hasEmail = cleanEmail != null && cleanEmail.isNotEmpty;

//     final bool hasContact = cleanContact != null && cleanContact.isNotEmpty;

//     if (hasEmail || hasContact) {
//       options['prefill'] = {
//         if (hasEmail) 'email': cleanEmail,
//         if (hasContact) 'contact': cleanContact,
//       };
//     }

//     // ----------------------------------------------------------
//     // DEBUG LOGGING
//     // ----------------------------------------------------------

//     _log('Opening Razorpay checkout.');
//     _log('Order ID: $cleanOrderId');
//     _log('Amount INR: $amount');
//     _log('Amount smallest unit: $amountInSmallestUnit');
//     _log('Currency: $cleanCurrency');

//     // ----------------------------------------------------------
//     // OPEN CHECKOUT
//     // ----------------------------------------------------------

//     try {
//       _isCheckoutOpen = true;

//       _razorpay.open(options);

//       _log('Razorpay checkout requested successfully.');
//     } catch (e, stackTrace) {
//       _isCheckoutOpen = false;

//       _log('Failed to open Razorpay checkout.');
//       _log('Error: $e');

//       if (kDebugMode) {
//         debugPrintStack(stackTrace: stackTrace);
//       }

//       rethrow;
//     }
//   }

//   // ============================================================
//   // SERVICE STATE VALIDATION
//   // ============================================================

//   void _validateServiceState() {
//     if (_isDisposed) {
//       throw StateError('RazorpayService has already been disposed.');
//     }

//     if (!_isInitialized) {
//       throw StateError(
//         'RazorpayService is not initialized. '
//         'Call initialize() before openCheckout().',
//       );
//     }
//   }

//   // ============================================================
//   // STATUS
//   // ============================================================

//   bool get isInitialized => _isInitialized;

//   bool get isCheckoutOpen => _isCheckoutOpen;

//   bool get isDisposed => _isDisposed;

//   // ============================================================
//   // DEBUG LOGGER
//   // ============================================================

//   void _log(String message) {
//     if (kDebugMode) {
//       debugPrint('[RazorpayService] $message');
//     }
//   }

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   void dispose() {
//     if (_isDisposed) {
//       return;
//     }

//     _log('Disposing RazorpayService.');

//     _razorpay.clear();

//     _onPaymentSuccess = null;
//     _onPaymentError = null;
//     _onExternalWallet = null;

//     _isCheckoutOpen = false;
//     _isInitialized = false;
//     _isDisposed = true;
//   }
// }

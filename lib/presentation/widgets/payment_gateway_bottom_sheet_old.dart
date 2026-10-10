import 'package:flutter/material.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';
import 'package:lms/presentation/provider/payment_provider.dart';
import 'package:lms/presentation/screen/razorpay_service.dart';

/// ===============================================================
/// PAYMENT GATEWAY BOTTOM SHEET
///
/// FLOW:
///
/// Pay Now
///    ↓
/// Gateway Bottom Sheet
///    ↓
/// User selects gateway
///    ↓
/// Get gatewaySettingId
///    ↓
/// Create Order API
///    ↓
/// Backend returns orderId
///    ↓
/// Open Razorpay
///    ↓
/// Payment Success
///    ↓
/// Verify Payment API
///    ↓
/// Refresh course/webinar access
/// ===============================================================

void showPaymentGatewayBottomSheet({
  required BuildContext context,
  required List<PaymentGateWaysData> gateways,
  required int webinarId,
  required double amount,
  required String name,
  required String description,
  required RazorpayService razorpayService,
  required PaymentProvider paymentProvider,
  // ADD THIS
  required void Function(String paymentId) onPaymentCreated,
}) {
  if (gateways.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No payment gateway available')),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HANDLE
              // =====================================================
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // TITLE
              // =====================================================
              const Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Select a payment gateway to continue',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              // =====================================================
              // GATEWAYS
              // =====================================================
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: gateways.length,
                  itemBuilder: (context, index) {
                    final gatewaydata = gateways[index];
                    return _paymentGatewayTile(
                      context: sheetContext,
                      gateway: gatewaydata,
                      index: index,
                      webinarId: webinarId,
                      amount: amount,
                      name: name,
                      description: description,
                      razorpayService: razorpayService,
                      paymentProvider: paymentProvider,
                      // ADD
                      onPaymentCreated: onPaymentCreated,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ===============================================================
/// PAYMENT GATEWAY TILE
/// ===============================================================

Widget _paymentGatewayTile({
  required BuildContext context,
  required PaymentGateWaysData gateway,
  required int index,
  required int webinarId,
  required double amount,
  required String name,
  required String description,
  required RazorpayService razorpayService,
  required PaymentProvider paymentProvider,
  // ADD
  required void Function(String paymentId) onPaymentCreated,
}) {
  return AnimatedBuilder(
    animation: paymentProvider,
    builder: (context, child) {
      final bool isLoading =
          paymentProvider.isLoadingCreatePaymentOrder &&
          paymentProvider.selectedPaymentIndex == index;

      return InkWell(
        onTap:
            isLoading
                ? null
                : () async {
                  await _handleSelectedGateway(
                    gateway: gateway,
                    index: index,
                    webinarId: webinarId,
                    amount: amount,
                    name: name,
                    description: description,
                    razorpayService: razorpayService,
                    paymentProvider: paymentProvider,
                    pageContext: context,
                    // ADD
                    onPaymentCreated: onPaymentCreated,
                  );
                },
        borderRadius: BorderRadius.circular(14),
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // =====================================================
                // LOGO
                // =====================================================
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child:
                      gateway.logoUrl != null && gateway.logoUrl!.isNotEmpty
                          ? Image.network(
                            '${ApiEndPoint.serverUrl}${gateway.logoUrl!}',
                            fit: BoxFit.contain,
                          )
                          : const Icon(
                            Icons.payment_rounded,
                            color: Color(0xFF2563EB),
                          ),
                ),

                const SizedBox(width: 14),

                // =====================================================
                // NAME
                // =====================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gateway.displayName ?? 'Payment Gateway',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 5),

                      if (gateway.isSandbox == 'true')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'TEST MODE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        )
                      else
                        Text(
                          'Secure payment',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),

                // =====================================================
                // LOADING / ARROW
                // =====================================================
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// ===============================================================
/// HANDLE SELECTED GATEWAY
/// ===============================================================

Future<void> _handleSelectedGateway({
  required PaymentGateWaysData gateway,
  required int index,
  required int webinarId,
  required double amount,
  required String name,
  required String description,
  required RazorpayService razorpayService,
  required PaymentProvider paymentProvider,
  required BuildContext pageContext,
  // ADD
  required void Function(String paymentId) onPaymentCreated,
}) async {
  try {
    // ===========================================================
    // PAYMENT GATEWAY SELECTED
    // ===========================================================

    debugPrint('============================================');
    debugPrint('PAYMENT GATEWAY SELECTED');
    debugPrint('============================================');

    debugPrint('Gateway Name: ${gateway.displayName}');
    debugPrint('Gateway Type: ${gateway.gatewayType}');

    // ===========================================================
    // 1. GET GATEWAY SETTING ID
    // ===========================================================

    final gatewaySettingId = gateway.id;

    if (gatewaySettingId == null) {
      _showError(pageContext, 'Payment gateway ID not found.');
      return;
    }

    debugPrint('Gateway Setting ID: $gatewaySettingId');

    debugPrint('Webinar ID: $webinarId');

    // ===========================================================
    // 2. CREATE PAYMENT ORDER
    // ===========================================================

    debugPrint('============================================');
    debugPrint('CREATING PAYMENT ORDER');
    debugPrint('============================================');

    debugPrint('gatewaySettingId: $gatewaySettingId');

    debugPrint('webinarId: $webinarId');

    await paymentProvider.createPaymentOrderPro(
      gatewaySettingId,
      webinarId.toString(),
      index,
    );

    // ===========================================================
    // 3. CHECK API FAILURE
    // ===========================================================

    if (paymentProvider.failure != null) {
      _showErrorAndClose(
        pageContext,
        paymentProvider.failure?.message?.toString() ??
            'Unable to create payment order.',
      );
      return;
    }

    // ===========================================================
    // 4. GET CREATE ORDER RESPONSE
    // ===========================================================

    final createOrderModel = paymentProvider.createPaymentOrderModel;

    if (createOrderModel == null) {
      _showError(pageContext, 'Payment order response is empty.');
      return;
    }

    debugPrint(
      'Payment Order Response: '
      '${createOrderModel.toJson()}',
    );

    // ===========================================================
    // 5. CHECK API SUCCESS
    // ===========================================================

    if (createOrderModel.success != 'true') {
      _showError(
        pageContext,
        createOrderModel.message ?? 'Payment order creation failed.',
      );
      return;
    }

    // ===========================================================
    // 6. GET DATA
    // ===========================================================

    final paymentData = createOrderModel.data;

    if (paymentData == null) {
      _showError(pageContext, 'Payment data was not returned by server.');
      return;
    }

    debugPrint('Payment ID: ${paymentData.paymentId}');

    debugPrint('Gateway: ${paymentData.gateway}');
    // ===========================================================
    // IMPORTANT
    //
    // This is YOUR BACKEND payment record ID.
    //
    // Example:
    // paymentId = 71
    //
    // DO NOT confuse this with Razorpay paymentId.
    // ===========================================================

    final backendPaymentId = paymentData.paymentId;

    if (backendPaymentId == null) {
      _showError(pageContext, 'Backend payment ID was not returned.');
      return;
    }

    debugPrint('API create Order Backend Payment ID: $backendPaymentId');

    debugPrint('Backend Payment ID: $backendPaymentId');

    // PASS TO COURSE DETAIL PAGE
    onPaymentCreated(backendPaymentId);

    // ===========================================================
    // 7. GET CLIENT CONFIG
    // ===========================================================

    final clientConfig = paymentData.clientConfig;

    if (clientConfig == null) {
      _showError(
        pageContext,
        'Payment configuration was not returned by server.',
      );
      return;
    }

    // ===========================================================
    // 8. GET RAZORPAY CONFIG
    // ===========================================================

    final keyId = clientConfig.key;

    final orderId = clientConfig.orderId;

    final backendAmount = clientConfig.amount;

    final currency = clientConfig.currency;

    debugPrint('============================================');
    debugPrint('PAYMENT CLIENT CONFIG');
    debugPrint('============================================');

    debugPrint('Key ID: $keyId');
    debugPrint('Order ID: $orderId');
    debugPrint('Amount: $backendAmount');
    debugPrint('Currency: $currency');

    // ===========================================================
    // 9. VALIDATE CLIENT CONFIG
    // ===========================================================

    if (keyId == null || keyId.trim().isEmpty) {
      _showError(pageContext, 'Razorpay key was not returned by server.');
      return;
    }

    if (orderId == null || orderId.trim().isEmpty) {
      _showError(pageContext, 'Razorpay order ID was not returned by server.');
      return;
    }

    if (backendAmount == null || backendAmount.trim().isEmpty) {
      _showError(pageContext, 'Payment amount was not returned by server.');
      return;
    }

    final double? paymentAmount = double.tryParse(backendAmount);

    if (paymentAmount == null || paymentAmount <= 0) {
      _showError(pageContext, 'Invalid payment amount.');
      return;
    }

    // ===========================================================
    // 10. SELECT PAYMENT GATEWAY
    // ===========================================================

    switch (gateway.gatewayType) {
      // =========================================================
      // RAZORPAY
      // =========================================================

      case '1':
        // Close payment gateway bottom sheet
        if (pageContext.mounted) {
          Navigator.of(pageContext).pop();
        }

        // Small delay so bottom sheet finishes closing
        await Future.delayed(const Duration(milliseconds: 150));

        if (!pageContext.mounted) {
          return;
        }

        await _openRazorpay(
          gateway: gateway,
          keyId: keyId,
          orderId: orderId,
          amount: paymentAmount,
          currency: currency ?? 'INR',
          name: name,
          description: description,
          razorpayService: razorpayService,
          pageContext: pageContext,
        );
        break;

      // =========================================================
      // STRIPE
      // =========================================================

      case '2':
        _showError(pageContext, 'Stripe payment is not implemented yet.');
        break;

      // =========================================================
      // PAYPAL
      // =========================================================

      case '3':
        _showError(pageContext, 'PayPal payment is not implemented yet.');
        break;

      // =========================================================
      // PHONEPE
      // =========================================================

      case '4':
        _showError(pageContext, 'PhonePe payment is not implemented yet.');
        break;

      // =========================================================
      // CASHFREE
      // =========================================================

      case '5':
        _showError(pageContext, 'Cashfree payment is not implemented yet.');
        break;

      // =========================================================
      // UNKNOWN
      // =========================================================

      default:
        _showError(pageContext, 'Unsupported payment gateway.');
        break;
    }
  } catch (e, stackTrace) {
    debugPrint('============================================');

    debugPrint('PAYMENT GATEWAY ERROR');

    debugPrint('============================================');

    debugPrint('Error: $e');

    debugPrint('StackTrace: $stackTrace');

    _showError(pageContext, 'Unable to start payment. Please try again.');
  }
}

/// ===============================================================
/// OPEN RAZORPAY
/// ===============================================================

Future<void> _openRazorpay({
  required PaymentGateWaysData gateway,
  required String keyId,
  required String orderId,
  required double amount,
  required String currency,
  required String name,
  required String description,
  required RazorpayService razorpayService,
  required BuildContext pageContext,
}) async {
  try {
    // ===========================================================
    // RAZORPAY DETAILS
    // ===========================================================

    debugPrint('============================================');
    debugPrint('OPENING RAZORPAY');
    debugPrint('============================================');

    debugPrint('Gateway: ${gateway.displayName}');

    debugPrint('Key ID: $keyId');

    debugPrint('Order ID: $orderId');

    debugPrint('Amount: $amount');

    debugPrint('Currency: $currency');

    // ===========================================================
    // VALIDATION
    // ===========================================================

    if (keyId.trim().isEmpty) {
      _showError(pageContext, 'Razorpay key ID is missing.');
      return;
    }

    if (orderId.trim().isEmpty) {
      _showError(pageContext, 'Razorpay order ID is missing.');
      return;
    }

    if (amount <= 0) {
      _showError(pageContext, 'Invalid payment amount.');
      return;
    }

    // ===========================================================
    // OPEN RAZORPAY CHECKOUT
    // ===========================================================

    razorpayService.openCheckout(
      keyId: keyId,
      orderId: orderId,
      amount: amount,
      name: name,
      description: description,
    );

    debugPrint('Razorpay checkout opened successfully.');
  } catch (e, stackTrace) {
    debugPrint('Razorpay opening error: $e');

    debugPrint('StackTrace: $stackTrace');

    _showError(pageContext, 'Unable to open Razorpay. Please try again.');
  }
}

void _showErrorAndClose(BuildContext context, String message) {
  if (!context.mounted) {
    return;
  }

  // Close bottom sheet first
  Navigator.of(context).pop();

  // Show error after bottom sheet closes
  Future.delayed(const Duration(milliseconds: 150), () {
    if (!context.mounted) {
      return;
    }

    _showError(context, message);
  });
}

/// ===============================================================
/// SHOW ERROR
/// ===============================================================

void _showError(BuildContext context, String message) {
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 24,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        backgroundColor: const Color(0xFFDC2626),

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        elevation: 6,

        duration: const Duration(seconds: 3),

        dismissDirection: DismissDirection.horizontal,
      ),
    );
}

/// ===============================================================
/// SHOW ERROR
/// ===============================================================

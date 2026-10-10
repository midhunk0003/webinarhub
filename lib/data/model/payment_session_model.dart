class PaymentSession {
  final String backendPaymentId;
  final String razorpayOrderId;
  final String razorpayKey;
  final double amount;
  final String currency;

  const PaymentSession({
    required this.backendPaymentId,
    required this.razorpayOrderId,
    required this.razorpayKey,
    required this.amount,
    required this.currency,
  });

  @override
  String toString() {
    return 'PaymentSession('
        'backendPaymentId: $backendPaymentId, '
        'razorpayOrderId: $razorpayOrderId, '
        'amount: $amount, '
        'currency: $currency'
        ')';
  }
}

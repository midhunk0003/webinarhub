import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';
import 'package:lms/data/model/create_payment_order_model/create_payment_order_model.dart';
import 'package:lms/data/model/login_model/login_model.dart';
import 'package:lms/data/model/wbinar_permissions_model/wbinar_permissions_model.dart';

abstract class PaymentRepository {
  Future<Either<Failure, AvailablePaymentGateWaysModel>> getAvailablePayment();
  Future<Either<Failure, CreatePaymentOrderModel>> createPaymentOrder(
    String? gatewaySettingId,
    String? webinarId,
  );
  Future<Either<Failure, CreatePaymentOrderModel>> paymentVerify(
    String? paymentId,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    String? signature,
  );
}

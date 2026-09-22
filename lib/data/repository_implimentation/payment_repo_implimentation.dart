import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';
import 'package:lms/data/model/create_payment_order_model/create_payment_order_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/payment_repository.dart';

class PaymentRepoImplimentation implements PaymentRepository {
  final ApiClient apiClient;

  PaymentRepoImplimentation({required this.apiClient});
  @override
  Future<Either<Failure, AvailablePaymentGateWaysModel>>
  getAvailablePayment() async {
    try {
      final result = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.paymentGateWayAvailableEndPoint}",
      );

      log('API get available payment  Data List : $result');
      return result.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final availablePaymentGateWaysData =
              AvailablePaymentGateWaysModel.fromJson(data);

          return Right(availablePaymentGateWaysData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreatePaymentOrderModel>> createPaymentOrder(
    String? gatewaySettingId,
    String? webinarId,
  ) async {
    print('gatewaySettingId : ${gatewaySettingId}');
    print('webinarId : ${webinarId}');
    try {
      final result = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.createPaymentOrderEndPoint}",
        body: {
          "gatewaySettingId": int.parse(gatewaySettingId.toString()),
          "webinarId": int.parse(webinarId.toString()),
        },
      );

      log('API create Order: $result');
      return result.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final createPaymentOrderData = CreatePaymentOrderModel.fromJson(data);
          return Right(createPaymentOrderData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreatePaymentOrderModel>> paymentVerify(
    String? paymentId,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    String? signature,
  ) {
    // TODO: implement paymentVerify
    throw UnimplementedError();
  }
}

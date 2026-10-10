import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/available_payment_gate_ways/available_payment_gate_ways_model.dart';
import 'package:lms/data/model/create_payment_order_model/create_payment_order_model.dart';
import 'package:lms/data/model/payment_history_model/payment_history_model.dart';
import 'package:lms/data/model/payment_verify_model/payment_verify_model.dart';
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
  Future<Either<Failure, PaymentVerifyModel>> paymentVerify(
    String? paymentId,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    String? signature,
  ) async {
    print('paymentId : ${paymentId}');
    print('gatewayOrderId : ${gatewayOrderId}');
    print('gatewayPaymentId : ${gatewayPaymentId}');
    print('signature : ${signature}');
    try {
      final result = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.paymentsVerifyEndPoint}",
        body: {
          "paymentId": int.parse(paymentId.toString()),
          "gatewayOrderId": gatewayOrderId,
          "gatewayPaymentId": gatewayPaymentId,
          "signature": signature,
        },
      );

      log('API create Order: $result');
      return result.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final PaymentVerifyData = PaymentVerifyModel.fromJson(data);
          return Right(PaymentVerifyData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentHistoryModel>> getPaymentHistory({
    String? search,
    int? status,
    int? paymentMethod,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        return Left(AuthFailure('From date cannot be after To date.'));
      }
      final query = <String, String>{};
      if (search?.trim().isNotEmpty == true) query['Search'] = search!.trim();
      if (status != null) query['Status'] = '$status';
      if (paymentMethod != null) query['PaymentMethod'] = '$paymentMethod';
      if (fromDate != null) query['FromDate'] = _formatDate(fromDate);
      if (toDate != null) query['ToDate'] = _formatDate(toDate);

      final endpoint =
          '${ApiEndPoint.baseUrl}${ApiEndPoint.paymentHistoryEndPoint}';
      final uri = Uri.parse(endpoint).replace(queryParameters: query);
      log('Payment history request: $uri');
      final result = await apiClient.get(uri.toString());
      return result.fold((f) => Left(f), (data) {
        if (data is! Map)
          return Left(ServerFailure('Invalid payment history response.'));
        return Right(
          PaymentHistoryModel.fromJson(Map<String, dynamic>.from(data)),
        );
      });
    } catch (e, st) {
      log('getPaymentHistory failed', error: e, stackTrace: st);
      return Left(ServerFailure('Unable to load payment history.'));
    }
  }

  String _formatDate(DateTime date) {
    return date.toUtc().toIso8601String();
  }
}

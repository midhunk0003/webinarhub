import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

String generateZoomJwt({
  required String clientId,
  required String clientSecret,
  required String meetingNumber,
}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final jwt = JWT(
    {
      'appKey': clientId,
      'mn': meetingNumber,
      'role': 0,
      'iat': now - 30,
      'exp': now + (2 * 60 * 60),
      'tokenExp': now + (2 * 60 * 60),
    },
    header: {'alg': 'HS256', 'typ': 'JWT'},
  );

  return jwt.sign(SecretKey(clientSecret));
}

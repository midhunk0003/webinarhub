abstract class Failure {
  String? message;
  int? statusCode;

  Failure({this.message, this.statusCode});

  /// Create an "empty" failure
  factory Failure.empty() => EmptyFailure();

  bool get isEmpty => this is EmptyFailure;
}

class EmptyFailure extends Failure {
  EmptyFailure() : super(message: null, statusCode: null);
}

class ServerFailure extends Failure {
  ServerFailure(String? message) : super(message: message);
}

class LoginFailure extends Failure {
  LoginFailure(String? message) : super(message: message);
}

class ClientFailure extends Failure {
  ClientFailure(String? message) : super(message: message);
}

class OtherFailureNon200 extends Failure {
  OtherFailureNon200(String? message) : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String? message) : super(message: message);
}

class AuthFailure extends Failure {
  AuthFailure(String? message) : super(message: message);
}

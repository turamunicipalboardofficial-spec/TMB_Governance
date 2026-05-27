abstract class Failure {
  final String message;
  final int? statusCode;
  const Failure(this.message, this.statusCode);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, int? statusCode)
      : super(message, statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection', 0);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message, 401);
}
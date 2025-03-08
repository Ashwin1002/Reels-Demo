abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class ServerException extends AppException {
  ServerException(super.message);

  @override
  String toString() {
    return super.message.toString();
  }
}

class CacheException extends AppException {
  CacheException(super.message);
}

//route
class RouteException extends AppException {
  RouteException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}

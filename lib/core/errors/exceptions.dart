class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'AppException{message: $message, code: $code, statusCode: $statusCode, details: $details}';
  }
}

class NetworkException extends AppException {
  const NetworkException({
    String message = 'Network error occurred',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class AuthException extends AppException {
  const AuthException({
    String message = 'Authentication failed',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class ValidationException extends AppException {
  final Map<String, String> errors;

  const ValidationException({
    String message = 'Validation failed',
    this.errors = const {},
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Resource not found',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized access',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class ConflictException extends AppException {
  const ConflictException({
    String message = 'Conflict occurred',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class StorageException extends AppException {
  const StorageException({
    String message = 'Storage error occurred',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class DatabaseException extends AppException {
  const DatabaseException({
    String message = 'Database error occurred',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

class UnknownException extends AppException {
  const UnknownException({
    String message = 'An unknown error occurred',
    String? code,
    int? statusCode,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    details: details,
  );
}

// Helper function to map Supabase errors to AppException
exceptionFromSupabaseError(dynamic error) {
  if (error == null) return null;
  
  final message = error.toString();
  final code = error is Map && error.containsKey('code') ? error['code'] : null;
  final statusCode = error is Map && error.containsKey('statusCode') ? error['statusCode'] : null;
  
  if (message.contains('network') || message.contains('connection')) {
    return NetworkException(message: message, code: code, statusCode: statusCode, details: error);
  } else if (message.contains('auth') || message.contains('jwt') || message.contains('token')) {
    return AuthException(message: message, code: code, statusCode: statusCode, details: error);
  } else if (message.contains('not found') || message.contains('404')) {
    return NotFoundException(message: message, code: code, statusCode: statusCode, details: error);
  } else if (message.contains('unauthorized') || message.contains('401') || message.contains('403')) {
    return UnauthorizedException(message: message, code: code, statusCode: statusCode, details: error);
  } else if (message.contains('conflict') || message.contains('409')) {
    return ConflictException(message: message, code: code, statusCode: statusCode, details: error);
  } else if (message.contains('storage') || message.contains('upload')) {
    return StorageException(message: message, code: code, statusCode: statusCode, details: error);
  } else if (message.contains('database') || message.contains('postgres')) {
    return DatabaseException(message: message, code: code, statusCode: statusCode, details: error);
  } else {
    return UnknownException(message: message, code: code, statusCode: statusCode, details: error);
  }
}

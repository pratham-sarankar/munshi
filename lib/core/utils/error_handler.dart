import 'package:flutter/foundation.dart';

/// Centralized error handling utility for consistent error management
class ErrorHandler {
  ErrorHandler._();

  /// Log error to console in debug mode
  static void logError(
    String message,
    Object? error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) {
        debugPrint('Details: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Get user-friendly error message from exception
  static String getUserFriendlyMessage(Object error) {
    if (error is FormatException) {
      return 'Invalid data format. Please check your input.';
    } else if (error is ArgumentError) {
      return 'Invalid argument provided. Please try again.';
    } else if (error is StateError) {
      return 'Application state error. Please restart the app.';
    } else if (error is TypeError) {
      return 'Data type mismatch. Please contact support.';
    } else if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('database') ||
        error.toString().contains('sql')) {
      return 'Database error. Please try again or contact support.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle error with optional callback
  static String handleError(
    Object error, [
    StackTrace? stackTrace,
    String? context,
  ]) {
    final message = context ?? 'Operation failed';
    logError(message, error, stackTrace);
    return getUserFriendlyMessage(error);
  }
}

/// Categorized error types for better handling
enum ErrorCategory {
  network,
  database,
  validation,
  authentication,
  permission,
  unknown;

  static ErrorCategory fromError(Object error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return ErrorCategory.network;
    } else if (errorString.contains('database') ||
        errorString.contains('sql') ||
        errorString.contains('drift')) {
      return ErrorCategory.database;
    } else if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        error is FormatException) {
      return ErrorCategory.validation;
    } else if (errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return ErrorCategory.authentication;
    } else if (errorString.contains('permission') ||
        errorString.contains('denied')) {
      return ErrorCategory.permission;
    } else {
      return ErrorCategory.unknown;
    }
  }

  String get displayMessage {
    switch (this) {
      case ErrorCategory.network:
        return 'Network error. Please check your connection and try again.';
      case ErrorCategory.database:
        return 'Data storage error. Your data is safe, please try again.';
      case ErrorCategory.validation:
        return 'Please check your input and try again.';
      case ErrorCategory.authentication:
        return 'Authentication failed. Please log in again.';
      case ErrorCategory.permission:
        return 'Permission denied. Please check app permissions.';
      case ErrorCategory.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

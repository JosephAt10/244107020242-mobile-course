import 'package:dio/dio.dart';

String userMessageForDio(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'The request timed out. Please try again.';
  }
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown) {
    return 'You appear to be offline. Check your connection and try again.';
  }
  if (error.response?.statusCode == 401) return 'Your session expired. Please sign in again.';
  return 'The request could not be completed. Please try again.';
}

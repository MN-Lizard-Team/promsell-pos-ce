import 'package:equatable/equatable.dart';

/// Base sealed class for all application errors.
/// Use pattern matching for type-safe error handling.
sealed class AppError extends Equatable {
  const AppError();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Domain Errors
// ============================================================================

/// Business logic validation error
final class ValidationError extends AppError {
  const ValidationError(this.message, {this.field});

  final String message;
  final String? field;

  @override
  List<Object?> get props => [message, field];
}

/// Resource not found error
final class NotFoundError extends AppError {
  const NotFoundError(this.resource, {this.id});

  final String resource; // e.g., 'Product', 'Customer', 'Sale'
  final String? id;

  @override
  List<Object?> get props => [resource, id];
}

/// Business rule violation
final class BusinessRuleError extends AppError {
  const BusinessRuleError(this.rule, {this.details});

  final String rule; // e.g., 'InsufficientStock', 'DuplicateBarcode'
  final String? details;

  @override
  List<Object?> get props => [rule, details];
}

// ============================================================================
// Infrastructure Errors
// ============================================================================

/// Database operation error
final class DatabaseError extends AppError {
  const DatabaseError(this.message, {this.operation});

  final String message;
  final String? operation; // e.g., 'insert', 'update', 'delete'

  @override
  List<Object?> get props => [message, operation];
}

/// Network/API error
final class NetworkError extends AppError {
  const NetworkError({this.statusCode, this.message});

  final int? statusCode;
  final String? message;

  @override
  List<Object?> get props => [statusCode, message];
}

/// File system error
final class FileSystemError extends AppError {
  const FileSystemError(this.message, {this.path});

  final String message;
  final String? path;

  @override
  List<Object?> get props => [message, path];
}

// ============================================================================
// Permission Errors
// ============================================================================

/// Permission denied error
final class PermissionDeniedError extends AppError {
  const PermissionDeniedError(this.permission);

  final String permission; // e.g., 'camera', 'storage'

  @override
  List<Object?> get props => [permission];
}

// ============================================================================
// Unknown Errors
// ============================================================================

/// Catch-all for unexpected errors
final class UnknownError extends AppError {
  const UnknownError(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, stackTrace];
}

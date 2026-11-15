import '../error/failures.dart';

class InputSanitizer {
  static final RegExp _dangerousPattern = RegExp(
    r'<[^>]*>|javascript:|--|;\s*drop\b|;\s*insert\b|;\s*update\b|;\s*delete\b',
    caseSensitive: false,
  );

  static String sanitizeStrict(
    String input, {
    required String fieldName,
    int? position,
    int? maxLength,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ValidationFailure(
        position != null
            ? '$fieldName at position $position cannot be empty'
            : '$fieldName cannot be empty',
        field: fieldName,
        position: position,
      );
    }

    if (_dangerousPattern.hasMatch(trimmed)) {
      throw ValidationFailure(
        position != null
            ? '$fieldName at position $position contains invalid or dangerous content'
            : '$fieldName contains invalid or dangerous content',
        field: fieldName,
        position: position,
      );
    }

    if (maxLength != null && trimmed.length > maxLength) {
      throw ValidationFailure(
        position != null
            ? '$fieldName at position $position exceeds maximum length of $maxLength characters'
            : '$fieldName exceeds maximum length of $maxLength characters',
        field: fieldName,
        position: position,
      );
    }

    return trimmed;
  }

  static String? sanitizeOptional(
    String? input, {
    required String fieldName,
    int? maxLength,
  }) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    if (maxLength != null && trimmed.length > maxLength) {
      throw ValidationFailure(
        '$fieldName exceeds maximum length of $maxLength characters',
        field: fieldName,
      );
    }

    return trimmed;
  }
}

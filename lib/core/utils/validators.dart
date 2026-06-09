/// Centralized input validators for domain boundaries.
/// Each method throws [ArgumentError] with a descriptive message on violation.
class Validators {
  const Validators._();

  static String productName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Product name cannot be empty.');
    }
    if (trimmed.length > 200) {
      throw ArgumentError(
        'Product name must be 200 characters or fewer (got ${trimmed.length}).',
      );
    }
    return trimmed;
  }

  static double price(double value) {
    if (value <= 0) {
      throw ArgumentError('Price must be greater than 0 (got $value).');
    }
    final scaled = (value * 100).round();
    if ((scaled / 100) != value) {
      throw ArgumentError(
        'Price must have at most 2 decimal places (got $value).',
      );
    }
    return value;
  }

  static int stock(int value) {
    if (value < 0) {
      throw ArgumentError('Stock cannot be negative (got $value).');
    }
    return value;
  }

  static String? barcode(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      throw ArgumentError('Barcode must be alphanumeric (got "$value").');
    }
    return value;
  }

  static double discountValue(double value, {required String? type}) {
    if (value < 0) {
      throw ArgumentError('Discount value cannot be negative (got $value).');
    }
    if (type == 'PERCENT' && value > 100) {
      throw ArgumentError(
        'Percentage discount cannot exceed 100% (got $value%).',
      );
    }
    return value;
  }

  static void nonEmptyCart(List<dynamic> items) {
    if (items.isEmpty) {
      throw ArgumentError('Cart cannot be empty.');
    }
  }

  static int qty(int value) {
    if (value <= 0) {
      throw ArgumentError('Quantity must be greater than 0 (got $value).');
    }
    return value;
  }

  /// Validates a Thai PromptPay ID.
  /// Accepts:
  /// - Mobile: 10 digits starting with 06, 08, or 09.
  /// - Citizen ID: 13 digits with valid mod-11 checksum.
  /// Returns the cleaned (digits-only) ID on success.
  /// Throws [ArgumentError] with a descriptive message on violation.
  static String? promptpayId(String? value) {
    if (value == null || value.isEmpty) return null;
    final raw = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;

    // Mobile: 10 digits starting with 06, 08, 09
    if (raw.startsWith('0')) {
      if (raw.length != 10) {
        throw ArgumentError(
          'Mobile number must be 10 digits (got ${raw.length}).',
        );
      }
      final validPrefixes = RegExp(r'^0[689]');
      if (!validPrefixes.hasMatch(raw)) {
        throw ArgumentError(
          'Mobile number must start with 06, 08, or 09 (got $raw).',
        );
      }
      return raw;
    }

    // Citizen ID: 13 digits
    if (raw.length != 13) {
      throw ArgumentError(
        'ID must be 10 digits (mobile) or 13 digits (citizen ID) (got ${raw.length}).',
      );
    }

    // Thai citizen ID checksum (mod 11)
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(raw[i]) * (13 - i);
    }
    final remainder = sum % 11;
    final checksum = (11 - remainder) % 10;
    if (checksum != int.parse(raw[12])) {
      throw ArgumentError('Invalid citizen ID checksum.');
    }
    return raw;
  }
}

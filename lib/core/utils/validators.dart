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
    // Reject ASCII control characters (0x00-0x1F, 0x7F) which can break
    // text rendering, CSV export, and receipt printing.
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(trimmed)) {
      throw ArgumentError('Product name must not contain control characters.');
    }
    return trimmed;
  }

  static double price(double value) {
    if (value <= 0) {
      throw ArgumentError('Price must be greater than 0 (got $value).');
    }
    if (value > 9999999.99) {
      throw ArgumentError('Price must not exceed 9999999.99 (got $value).');
    }
    final scaled = (value * 100).round();
    if ((scaled / 100) != value) {
      throw ArgumentError(
        'Price must have at most 2 decimal places (got $value).',
      );
    }
    return value;
  }

  /// Validates a product cost. Cost may be zero but not negative.
  /// Must have at most 2 decimal places. Returns the value on success.
  static double cost(double value) {
    if (value < 0) {
      throw ArgumentError('Cost cannot be negative (got $value).');
    }
    if (value > 9999999.99) {
      throw ArgumentError('Cost must not exceed 9999999.99 (got $value).');
    }
    final scaled = (value * 100).round();
    if ((scaled / 100) != value) {
      throw ArgumentError(
        'Cost must have at most 2 decimal places (got $value).',
      );
    }
    return value;
  }

  static int stock(int value) {
    if (value < 0) {
      throw ArgumentError('Stock cannot be negative (got $value).');
    }
    if (value > 999999) {
      throw ArgumentError('Stock must not exceed 999999 (got $value).');
    }
    return value;
  }

  /// Validates an SKU string.
  ///
  /// Returns the trimmed SKU, or `null` if the input is null/empty.
  /// Throws [ArgumentError] if the SKU is too long or contains invalid
  /// characters. Allowed: A–Z, a–z, 0–9, hyphen, underscore. Max 50 chars.
  static String? sku(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > 50) {
      throw ArgumentError(
        'SKU must be 50 characters or fewer (got ${trimmed.length}).',
      );
    }
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(trimmed)) {
      throw ArgumentError(
        'SKU must be alphanumeric, hyphen, or underscore (got "$value").',
      );
    }
    return trimmed;
  }

  static String? barcode(String? value) {
    if (value == null) return null;
    // Strip common separators (spaces, hyphens) before validation so
    // human-entered barcodes like "123-456-789" are accepted.
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.isEmpty) return null;
    if (cleaned.length > 50) {
      throw ArgumentError(
        'Barcode must be 50 characters or fewer (got ${cleaned.length}).',
      );
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(cleaned)) {
      throw ArgumentError('Barcode must be alphanumeric (got "$value").');
    }
    return cleaned;
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

  /// Validates a Thai Tax ID (เลขประจำตัวผู้เสียภาษี).
  /// Accepts 13 digits with valid mod-11 checksum (same algorithm as citizen ID).
  /// Returns the cleaned (digits-only) ID on success.
  /// Returns null if value is null or empty (tax ID is optional).
  /// Throws [ArgumentError] if non-empty but invalid length or checksum.
  static String? thaiTaxId(String? value) {
    if (value == null) return null;
    final raw = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    if (raw.length != 13) {
      throw ArgumentError('Tax ID must be 13 digits (got ${raw.length}).');
    }
    // Thai tax ID checksum (mod-11, same as citizen ID).
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(raw[i]) * (13 - i);
    }
    final remainder = sum % 11;
    final checksum = (11 - remainder) % 10;
    if (checksum != int.parse(raw[12])) {
      throw ArgumentError('Invalid tax ID checksum.');
    }
    return raw;
  }
}

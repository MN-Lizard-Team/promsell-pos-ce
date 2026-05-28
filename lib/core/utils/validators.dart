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
      throw ArgumentError(
        'Barcode must be alphanumeric (got "$value").',
      );
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
}

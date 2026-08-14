import 'package:equatable/equatable.dart';

class ShopInfo extends Equatable {
  const ShopInfo({
    this.name = '',
    this.address = '',
    this.phone = '',
    this.taxId = '',
  });

  final String name;
  final String address;
  final String phone;

  /// Thai Tax ID (เลขประจำตัวผู้เสียภาษี) — 13 digits.
  /// When present, prints on the receipt. Receipts are sales receipts
  /// (not tax invoices) regardless of Tax ID (V092-A.1).
  final String taxId;

  bool get isComplete => name.isNotEmpty && phone.isNotEmpty;

  /// Whether a valid Thai tax ID is configured (13 digits, numeric).
  bool get hasValidTaxId {
    final t = taxId.trim();
    if (t.isEmpty) return false;
    return RegExp(r'^\d{13}$').hasMatch(t);
  }

  ShopInfo copyWith({
    String? name,
    String? address,
    String? phone,
    String? taxId,
  }) {
    return ShopInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      taxId: taxId ?? this.taxId,
    );
  }

  @override
  List<Object?> get props => [name, address, phone, taxId];
}

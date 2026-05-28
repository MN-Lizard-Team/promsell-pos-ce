import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

class DraftCart extends Equatable {
  const DraftCart({
    required this.id,
    required this.items,
    this.name,
    this.note,
    required this.updatedAt,
  });

  final String id;
  final List<CartItem> items;
  final String? name;
  final String? note;
  final DateTime updatedAt;

  String get displayName => name?.isNotEmpty == true ? name! : 'Draft';

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  double get total => double.parse(
    items.fold(0.0, (sum, i) => sum + i.subtotal).toStringAsFixed(2),
  );

  @override
  List<Object?> get props => [id, items, name, note, updatedAt];
}

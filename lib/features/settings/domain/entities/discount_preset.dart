import 'package:equatable/equatable.dart';

class DiscountPreset extends Equatable {
  const DiscountPreset({
    required this.id,
    required this.name,
    this.type = 'PERCENT',
    this.values = const [5.0, 10.0, 20.0, 50.0],
  });

  final String id;
  final String name;
  final String type;
  final List<double> values;

  DiscountPreset copyWith({
    String? id,
    String? name,
    String? type,
    List<double>? values,
  }) {
    return DiscountPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      values: values ?? this.values,
    );
  }

  @override
  List<Object?> get props => [id, name, type, values];
}

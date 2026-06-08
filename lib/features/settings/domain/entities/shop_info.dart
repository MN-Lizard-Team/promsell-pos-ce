import 'package:equatable/equatable.dart';

class ShopInfo extends Equatable {
  const ShopInfo({this.name = '', this.address = '', this.phone = ''});

  final String name;
  final String address;
  final String phone;

  bool get isComplete => name.isNotEmpty && phone.isNotEmpty;

  ShopInfo copyWith({String? name, String? address, String? phone}) {
    return ShopInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [name, address, phone];
}

import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

final tNow = DateTime(2025, 1, 15, 10, 30);

final tProduct = Product(
  id: 'prod-0001-0001-0001-000000000001',
  name: 'Test Product',
  price: 100.0,
  stock: 50,
  category: 'Drinks',
  imageUrl: null,
  isActive: true,
  createdAt: tNow,
  updatedAt: tNow,
);

final tProduct2 = Product(
  id: 'prod-0002-0002-0002-000000000002',
  name: 'Another Product',
  price: 250.5,
  stock: 10,
  category: 'Food',
  imageUrl: null,
  isActive: true,
  createdAt: tNow,
  updatedAt: tNow,
);

final tInactiveProduct = Product(
  id: 'prod-0003-0003-0003-000000000003',
  name: 'Inactive Product',
  price: 50.0,
  stock: 0,
  category: null,
  imageUrl: null,
  isActive: false,
  createdAt: tNow,
  updatedAt: tNow,
);

final tCartItem = CartItem(product: tProduct, qty: 2);

final tCartItem2 = CartItem(product: tProduct2, qty: 1);

const tSaleItem = SaleItem(
  id: 'si-00000001-0001-0001-000000000001',
  saleId: 'sale-0001-0001-0001-000000000001',
  productId: 'prod-0001-0001-0001-000000000001',
  productName: 'Test Product',
  price: 100.0,
  qty: 2,
  subtotal: 200.0,
);

final tSale = Sale(
  id: 'sale-0001-0001-0001-000000000001',
  totalAmount: 200.0,
  paymentMethod: 'cash',
  amountReceived: 500.0,
  changeAmount: 300.0,
  note: null,
  createdAt: tNow,
  items: const [tSaleItem],
);

const tAppSettings = AppSettings();

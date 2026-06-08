import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';

final tNow = DateTime(2025, 1, 15, 10, 30);

final tProduct = Product(
  id: 'prod-0001-0001-0001-000000000001',
  name: 'Test Product',
  price: 100.0,
  stock: 50,
  category: 'Drinks',
  imageUrl: null,
  imagePath: null,
  imageThumbnailPath: null,
  isActive: true,
  trackStock: true,
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
  imagePath: null,
  imageThumbnailPath: null,
  isActive: true,
  trackStock: true,
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
  imagePath: null,
  imageThumbnailPath: null,
  isActive: false,
  trackStock: true,
  createdAt: tNow,
  updatedAt: tNow,
);

final tServiceProduct = Product(
  id: 'prod-0004-0004-0004-000000000004',
  name: 'Service Item',
  price: 200.0,
  stock: 0,
  category: null,
  imageUrl: null,
  imagePath: null,
  imageThumbnailPath: null,
  isActive: true,
  trackStock: false,
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
  discountAmount: 0.0,
  vatAmount: 0.0,
  version: 1,
);

final tSale = Sale(
  id: 'sale-0001-0001-0001-000000000001',
  totalAmount: 200.0,
  subtotalAmount: 200.0,
  discountType: null,
  discountValue: null,
  discountAmount: 0.0,
  vatMode: 'NONE',
  vatRate: 0.0,
  vatAmount: 0.0,
  paymentMethod: 'cash',
  amountReceived: 500.0,
  changeAmount: 300.0,
  note: null,
  createdAt: tNow,
  items: const [tSaleItem],
);

const tAppSettings = AppSettings();

final tInventoryLog = InventoryLog(
  id: 'invlog-0001-0001-0001-000000000001',
  productId: 'prod-0001-0001-0001-000000000001',
  type: 'ADJUSTMENT_IN',
  qtyChange: 10,
  balanceAfter: 60,
  reason: 'Restock',
  refSaleId: null,
  createdAt: tNow,
  version: 1,
);

final tInventoryLog2 = InventoryLog(
  id: 'invlog-0002-0002-0002-000000000002',
  productId: 'prod-0001-0001-0001-000000000001',
  type: 'SALE',
  qtyChange: -2,
  balanceAfter: 58,
  reason: null,
  refSaleId: 'sale-0001-0001-0001-000000000001',
  createdAt: tNow,
  version: 1,
);

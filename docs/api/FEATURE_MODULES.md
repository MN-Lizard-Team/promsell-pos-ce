# Feature Modules API Reference

> **Scope note (v0.9.0):** This file documents a **subset** of APIs. Full feature list (13): `customer`, `daily_close`, `history`, `home`, `inventory`, `onboarding`, `product`, `promotion`, `receipt`, `report`, `restaurant_table`, `sale`, `settings` under `lib/features/`.


Public APIs for feature-level domain models, repositories, and use cases.

---

## Product Module

**Location:** `lib/features/product/`

### Product Entity

**Path:** `lib/features/product/domain/entities/product.dart`

#### Core Properties

```dart
class Product extends Equatable {
  final String id;                    // UUIDv4
  final String name;                  // Required
  final String? sku;                  // Stock Keeping Unit
  final String? barcode;              // EAN-13/8, UPC-A, Code 128
  final String? barcodeImagePath;     // Generated barcode PNG
  final String? categoryId;           // Foreign key to categories
  final Money price;                  // Selling price (required)
  final Money? cost;                  // Purchase cost (optional)
  final double stock;                 // Current inventory level
  final bool trackStock;              // Enable stock tracking
  final bool isActive;                // Soft delete flag
  final String? imagePath;            // Product image path
  final String? imageThumbnailPath;   // 200x200 thumbnail
  final String? description;          // Product description (v0.8.9+)
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Computed Properties

```dart
// Profit per unit
Money get profit => cost != null ? price - cost! : Money.zero;

// Profit margin percentage
double get profitMargin {
  if (cost == null || cost!.isZero) return 0.0;
  return (profit.value / price.value) * 100;
}

// Markup percentage
double get markup {
  if (cost == null || cost!.isZero) return 0.0;
  return (profit.value / cost!.value) * 100;
}

// ROI (Return on Investment)
double get roi => markup;  // Alias for markup

// Total stock value at cost
Money get stockValue => (cost ?? Money.zero) * stock;

// Total stock revenue at selling price
Money get stockRevenue => price * stock;

// Total stock profit
Money get stockProfit => profit * stock;
```

#### Business Logic

```dart
// Stock level checks
bool get isLowStock => trackStock && stock > 0 && stock <= 10;
bool get isOutOfStock => trackStock && stock <= 0;
bool get hasStock => !trackStock || stock > 0;

// Validation
bool get isValid => name.isNotEmpty && price > Money.zero;
```

### ProductRepository

**Path:** `lib/features/product/domain/repositories/product_repository.dart`

#### Interface

```dart
abstract class ProductRepository {
  // Queries
  Stream<List<Product>> watchAllProducts();
  Stream<Product?> watchProductById(String id);
  Future<Product?> getById(String id);
  Future<Product?> getByBarcode(String barcode);
  Future<bool> barcodeExists(String barcode, {String? excludeId});
  
  // Mutations
  Future<void> insertProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String productId, double newStock);
  Future<void> adjustStock(String productId, double delta, String reason);
}
```

#### Usage Example

```dart
// Watch products (reactive)
final products$ = repository.watchAllProducts();
await for (final products in products$) {
  print('Product count: ${products.length}');
}

// Get single product
final product = await repository.getById('abc-123');
if (product != null) {
  print('Price: ${product.price}');
}

// Check barcode uniqueness
final exists = await repository.barcodeExists(
  '2001234567890',
  excludeId: currentProductId,  // Exclude self when editing
);

// Adjust stock with audit trail
await repository.adjustStock(
  'product-id',
  -5.0,  // Decrease by 5
  'Damaged items removed',
);
```

### Use Cases

#### AddProduct

**Path:** `lib/features/product/domain/usecases/add_product.dart`

```dart
@injectable
class AddProduct {
  AddProduct(this._repository, this._imageService);
  
  final ProductRepository _repository;
  final ProductImageService _imageService;
  
  Future<void> call({
    required String name,
    required Money price,
    String? sku,
    String? barcode,
    String? categoryId,
    Money? cost,
    double stock = 0,
    bool trackStock = true,
    String? localImagePath,
    String? description,
  }) async {
    // Validate barcode uniqueness
    if (barcode != null && barcode.isNotEmpty) {
      final exists = await _repository.barcodeExists(barcode);
      if (exists) {
        throw DuplicateBarcodeException(barcode);
      }
    }
    
    // Process image if provided
    String? savedImagePath;
    String? thumbnailPath;
    if (localImagePath != null) {
      savedImagePath = await _imageService.saveProductImage(localImagePath);
      thumbnailPath = await _imageService.generateThumbnail(savedImagePath);
    }
    
    final product = Product(
      id: IdGenerator.newId(),
      name: name,
      price: price,
      sku: sku,
      barcode: barcode,
      categoryId: categoryId,
      cost: cost,
      stock: stock,
      trackStock: trackStock,
      isActive: true,
      imagePath: savedImagePath,
      imageThumbnailPath: thumbnailPath,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.insertProduct(product);
  }
}
```

#### UpdateProduct

Similar to `AddProduct` but updates existing product and checks barcode uniqueness excluding self.

#### AdjustStock

**Path:** `lib/features/inventory/domain/usecases/adjust_stock.dart`

```dart
@injectable
class AdjustStock {
  AdjustStock(this._inventoryRepository);
  
  final InventoryRepository _inventoryRepository;
  
  Future<void> call({
    required String productId,
    required double adjustmentQty,  // Positive = in, Negative = out
    required String reason,
    String? notes,
  }) async {
    await _inventoryRepository.adjustStock(
      productId: productId,
      adjustmentQty: adjustmentQty,
      type: adjustmentQty > 0 ? 'in' : 'out',
      reason: reason,
      notes: notes,
    );
  }
}
```

---

## Sale Module

**Location:** `lib/features/sale/`

### Sale Entity

**Path:** `lib/features/sale/domain/entities/sale.dart`

#### Core Properties

```dart
class Sale extends Equatable {
  final String id;
  final String saleNumber;            // Auto-generated (e.g., "S-2024-001")
  final List<SaleItem> items;         // Line items
  final Money subtotal;               // Sum of all items
  final Money discountAmount;         // Manual discount
  final Money taxAmount;              // VAT/sales tax
  final Money total;                  // Subtotal - discount + tax
  final PaymentMethod paymentMethod;  // cash, card, promptpay, etc.
  final String? customerId;           // Optional customer reference
  final String? promotionId;          // Optional promotion applied
  final Money? promotionDiscountAmount;  // Discount from promotion
  final String? orderType;            // dine-in, takeaway, delivery
  final String? orderChannel;         // walk-in, phone, online
  final String? tableId;              // Restaurant table reference
  final double? serviceChargeRate;    // Service charge % (e.g., 0.10 = 10%)
  final Money? serviceChargeAmount;   // Calculated service charge
  final DateTime createdAt;
  final DateTime? voidedAt;           // Soft delete for voided sales
}
```

#### Computed Properties

```dart
// Grand total including service charge
Money get grandTotal {
  final base = total;
  if (serviceChargeAmount != null) {
    return base + serviceChargeAmount!;
  }
  return base;
}

// Is this sale voided?
bool get isVoided => voidedAt != null;

// Total item count
int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
```

### SaleItem Entity

```dart
class SaleItem extends Equatable {
  final String id;
  final String productId;
  final String productName;           // Snapshot for history
  final int quantity;
  final Money price;                  // Price at time of sale
  final Money lineTotal;              // quantity * price + options
  final List<ProductOption>? options; // Selected modifiers (v0.8.9+)
  final String? note;                 // Special instructions (v0.8.8+)
}
```

### CartState

**Path:** `lib/features/sale/presentation/bloc/cart_bloc.dart`

#### State Properties

```dart
class CartState extends Equatable {
  final List<CartItem> items;
  final Money itemsSubtotal;          // Sum of all line totals
  final Money cartDiscountAmount;     // Manual cart-level discount
  final Money total;                  // Subtotal - discount
  final double serviceChargeRate;     // From settings (restaurant mode)
  final Money serviceChargeAmount;    // Calculated service charge
  final Money grandTotal;             // total + serviceCharge
  final String? customerId;
  final String? promotionId;
  final Money? promotionDiscountAmount;
  final String? orderType;            // dine-in, takeaway, delivery
  final String? orderChannel;         // walk-in, phone, online
  final String? tableId;
  final AppError? error;              // Typed error
  final String? stockWarning;         // Low stock warnings
}
```

#### Cart Events

```dart
// Add product to cart
CartProductAdded(String productId, {int quantity = 1})

// Remove product from cart
CartProductRemoved(String productId, {String? lineId})

// Update quantity
CartItemQtyChanged(String productId, int newQty, {String? lineId})

// Update item note
CartItemNoteChanged(String lineId, String? note)

// Apply discount
CartDiscountChanged(Money amount)

// Set customer
CartCustomerSet(String? customerId)

// Apply promotion
CartPromotionApplied(String? promotionId, Money? discountAmount)

// Set restaurant fields
CartOrderTypeChanged(String? orderType)
CartTableSelected(String? tableId)

// Clear cart
CartCleared()
```

### SaleRepository

**Path:** `lib/features/sale/domain/repositories/sale_repository.dart`

```dart
abstract class SaleRepository {
  // Queries
  Stream<List<Sale>> watchAllSales();
  Stream<Sale?> watchSaleById(String id);
  Future<Sale?> getById(String id);
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end);
  Future<String> generateSaleNumber();
  
  // Mutations
  Future<void> insertSale(Sale sale);
  Future<void> voidSale(String saleId);  // Soft delete
}
```

### Use Cases

#### CreateSale

**Path:** `lib/features/sale/domain/usecases/create_sale.dart`

```dart
@injectable
class CreateSale {
  CreateSale(this._saleRepository, this._productRepository);
  
  final SaleRepository _saleRepository;
  final ProductRepository _productRepository;
  
  Future<Sale> call({
    required List<CartItem> items,
    required Money subtotal,
    required Money discountAmount,
    required Money total,
    required PaymentMethod paymentMethod,
    String? customerId,
    String? promotionId,
    Money? promotionDiscountAmount,
    String? orderType,
    String? orderChannel,
    String? tableId,
    double? serviceChargeRate,
    Money? serviceChargeAmount,
  }) async {
    // Generate sale number
    final saleNumber = await _saleRepository.generateSaleNumber();
    
    // Convert cart items to sale items
    final saleItems = items.map((item) => SaleItem(
      id: IdGenerator.newId(),
      productId: item.product.id,
      productName: item.product.name,
      quantity: item.quantity,
      price: item.product.price,
      lineTotal: item.lineTotal,
      options: item.options,
      note: item.note,
    )).toList();
    
    final sale = Sale(
      id: IdGenerator.newId(),
      saleNumber: saleNumber,
      items: saleItems,
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxAmount: Money.zero,  // Future: calculate tax
      total: total,
      paymentMethod: paymentMethod,
      customerId: customerId,
      promotionId: promotionId,
      promotionDiscountAmount: promotionDiscountAmount,
      orderType: orderType,
      orderChannel: orderChannel,
      tableId: tableId,
      serviceChargeRate: serviceChargeRate,
      serviceChargeAmount: serviceChargeAmount,
      createdAt: DateTime.now(),
    );
    
    // Insert sale (triggers inventory decrement in repository)
    await _saleRepository.insertSale(sale);
    
    return sale;
  }
}
```

#### VoidSale

```dart
@injectable
class VoidSale {
  VoidSale(this._saleRepository, this._productRepository);
  
  Future<void> call(String saleId) async {
    final sale = await _saleRepository.getById(saleId);
    if (sale == null) {
      throw NotFoundError('Sale', id: saleId);
    }
    
    if (sale.isVoided) {
      throw BusinessRuleError('SaleAlreadyVoided');
    }
    
    // Void sale (triggers inventory reversal in repository)
    await _saleRepository.voidSale(saleId);
  }
}
```

---

## Customer Module (v0.8.9+)

**Location:** `lib/features/customer/`

### Customer Entity

```dart
class Customer extends Equatable {
  final String id;
  final String name;                  // Required
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;                // For VAT invoices
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### CustomerRepository

```dart
abstract class CustomerRepository {
  Stream<List<Customer>> watchAllCustomers();
  Stream<Customer?> watchCustomerById(String id);
  Future<Customer?> getById(String id);
  Future<void> insertCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
```

---

## Promotion Module (v0.8.9+)

**Location:** `lib/features/promotion/`

### Promotion Entity

```dart
enum PromotionType { percent, fixed }

class Promotion extends Equatable {
  final String id;
  final String name;                  // Display name
  final String? description;
  final PromotionType type;           // percent or fixed
  final double value;                 // % (0-100) or fixed amount
  final DateTime? startDate;          // Activation date
  final DateTime? endDate;            // Expiry date
  final bool isActive;                // Manual enable/disable
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Computed Properties

```dart
// Is promotion currently valid?
bool get isValid {
  if (!isActive) return false;
  
  final now = DateTime.now();
  if (startDate != null && now.isBefore(startDate!)) return false;
  if (endDate != null && now.isAfter(endDate!)) return false;
  
  return true;
}

// Calculate discount amount
Money calculateDiscount(Money subtotal) {
  if (type == PromotionType.percent) {
    return subtotal * (value / 100);
  } else {
    return Money.fromDouble(value);
  }
}
```

### PromotionRepository

```dart
abstract class PromotionRepository {
  Stream<List<Promotion>> watchAllPromotions();
  Stream<List<Promotion>> watchActivePromotions();
  Future<Promotion?> getById(String id);
  Future<void> insertPromotion(Promotion promotion);
  Future<void> updatePromotion(Promotion promotion);
  Future<void> deletePromotion(String id);
}
```

---

## Settings Module

**Location:** `lib/features/settings/`

### Settings Aggregate

**Path:** `lib/features/settings/domain/entities/settings.dart`

Settings is split into 15 typed group entities (as of v0.8.9):

```dart
class Settings extends Equatable {
  final GeneralSettings general;
  final ShopInfoSettings shopInfo;
  final ReceiptSettings receipt;
  final DiscountPolicySettings discountPolicy;
  final PromptPaySettings promptPay;
  final ImageSettings image;
  final BarcodeSettings barcode;
  final DeviceSettings device;
  final DatabaseSettings database;
  final BackupSettings backup;
  final ThemeSettings theme;
  final RestaurantSettings restaurant;  // v0.8.9+
  // ... 3 more groups
}
```

### Example: GeneralSettings

```dart
class GeneralSettings extends Equatable {
  final String locale;                // 'th' or 'en'
  final String currencyCode;          // 'THB'
  final String currencySymbol;        // '฿'
  final ThemeMode themeMode;          // light, dark, system
  final bool compactCartMode;         // Compact cart UI (v0.8.8+)
}
```

### SettingsRepository

```dart
abstract class SettingsRepository {
  Future<Settings> load();
  Future<void> save(Settings settings);
  Future<void> reset();
}
```

### SettingsCubit

**Path:** `lib/features/settings/presentation/cubit/settings_cubit.dart`

```dart
@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._service);
  
  final SettingsRepository _repository;
  final SettingsPersistenceService _service;
  
  // Load settings on app start
  Future<void> load() async { ... }
  
  // Update specific group
  Future<void> updateGeneral(GeneralSettings general) async { ... }
  Future<void> updateShopInfo(ShopInfoSettings shopInfo) async { ... }
  
  // Auto-save with debounce (500ms)
  void scheduleAutoSave(Settings settings) { ... }
}
```

---

## Repository Pattern

All feature repositories follow this structure:

```
lib/features/<feature>/
├── domain/
│   └── repositories/
│       └── <feature>_repository.dart      # Abstract interface
└── data/
    └── repositories/
        └── <feature>_repository_impl.dart # Implementation
```

### Why Abstract Interfaces?

**Domain independence:** Domain layer has zero external dependencies (no Flutter, no Drift, no packages).

**Testability:** Mock repositories in unit tests without database.

**Flexibility:** Swap datasource (SQLite → cloud) without changing domain logic.

### Dependency Injection

```dart
// Domain interface (abstract)
abstract class ProductRepository {
  Future<Product?> getById(String id);
}

// Data implementation (concrete)
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._localDatasource);
  
  final ProductLocalDatasource _localDatasource;
  
  @override
  Future<Product?> getById(String id) async {
    final data = await _localDatasource.getProductById(id);
    if (data == null) return null;
    return Product.fromData(data);  // Map database model to domain entity
  }
}
```

---

<sub>Promsell POS CE · v0.9.0 · Feature Modules API</sub>

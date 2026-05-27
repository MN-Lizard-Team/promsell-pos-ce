// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackStockMeta = const VerificationMeta(
    'trackStock',
  );
  @override
  late final GeneratedColumn<bool> trackStock = GeneratedColumn<bool>(
    'track_stock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_stock" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sku,
    barcode,
    price,
    cost,
    stock,
    categoryId,
    imageUrl,
    trackStock,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('track_stock')) {
      context.handle(
        _trackStockMeta,
        trackStock.isAcceptableOrUnknown(data['track_stock']!, _trackStockMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      trackStock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_stock'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductData extends DataClass implements Insertable<ProductData> {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double? cost;
  final int stock;
  final String? categoryId;
  final String? imageUrl;
  final bool trackStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? deviceId;
  const ProductData({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.cost,
    required this.stock,
    this.categoryId,
    this.imageUrl,
    required this.trackStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    map['stock'] = Variable<int>(stock);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['track_stock'] = Variable<bool>(trackStock);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      price: Value(price),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      stock: Value(stock),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      trackStock: Value(trackStock),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory ProductData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      price: serializer.fromJson<double>(json['price']),
      cost: serializer.fromJson<double?>(json['cost']),
      stock: serializer.fromJson<int>(json['stock']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      trackStock: serializer.fromJson<bool>(json['trackStock']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'price': serializer.toJson<double>(price),
      'cost': serializer.toJson<double?>(cost),
      'stock': serializer.toJson<int>(stock),
      'categoryId': serializer.toJson<String?>(categoryId),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'trackStock': serializer.toJson<bool>(trackStock),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  ProductData copyWith({
    String? id,
    String? name,
    Value<String?> sku = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    double? price,
    Value<double?> cost = const Value.absent(),
    int? stock,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    bool? trackStock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<String?> deviceId = const Value.absent(),
  }) => ProductData(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    price: price ?? this.price,
    cost: cost.present ? cost.value : this.cost,
    stock: stock ?? this.stock,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    trackStock: trackStock ?? this.trackStock,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  ProductData copyWithCompanion(ProductsCompanion data) {
    return ProductData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      price: data.price.present ? data.price.value : this.price,
      cost: data.cost.present ? data.cost.value : this.cost,
      stock: data.stock.present ? data.stock.value : this.stock,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      trackStock: data.trackStock.present
          ? data.trackStock.value
          : this.trackStock,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('stock: $stock, ')
          ..write('categoryId: $categoryId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackStock: $trackStock, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sku,
    barcode,
    price,
    cost,
    stock,
    categoryId,
    imageUrl,
    trackStock,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.price == this.price &&
          other.cost == this.cost &&
          other.stock == this.stock &&
          other.categoryId == this.categoryId &&
          other.imageUrl == this.imageUrl &&
          other.trackStock == this.trackStock &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId);
}

class ProductsCompanion extends UpdateCompanion<ProductData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<double> price;
  final Value<double?> cost;
  final Value<int> stock;
  final Value<String?> categoryId;
  final Value<String?> imageUrl;
  final Value<bool> trackStock;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.stock = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    required double price,
    this.cost = const Value.absent(),
    this.stock = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price);
  static Insertable<ProductData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<double>? price,
    Expression<double>? cost,
    Expression<int>? stock,
    Expression<String>? categoryId,
    Expression<String>? imageUrl,
    Expression<bool>? trackStock,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (price != null) 'price': price,
      if (cost != null) 'cost': cost,
      if (stock != null) 'stock': stock,
      if (categoryId != null) 'category_id': categoryId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (trackStock != null) 'track_stock': trackStock,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? sku,
    Value<String?>? barcode,
    Value<double>? price,
    Value<double?>? cost,
    Value<int>? stock,
    Value<String?>? categoryId,
    Value<String?>? imageUrl,
    Value<bool>? trackStock,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      trackStock: trackStock ?? this.trackStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (trackStock.present) {
      map['track_stock'] = Variable<bool>(trackStock.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('stock: $stock, ')
          ..write('categoryId: $categoryId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackStock: $trackStock, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta(
    'receiptNumber',
  );
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
    'receipt_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COMPLETED'),
  );
  static const VerificationMeta _subtotalAmountMeta = const VerificationMeta(
    'subtotalAmount',
  );
  @override
  late final GeneratedColumn<double> subtotalAmount = GeneratedColumn<double>(
    'subtotal_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
    'discount_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vatModeMeta = const VerificationMeta(
    'vatMode',
  );
  @override
  late final GeneratedColumn<String> vatMode = GeneratedColumn<String>(
    'vat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NONE'),
  );
  static const VerificationMeta _vatRateMeta = const VerificationMeta(
    'vatRate',
  );
  @override
  late final GeneratedColumn<double> vatRate = GeneratedColumn<double>(
    'vat_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vatAmountMeta = const VerificationMeta(
    'vatAmount',
  );
  @override
  late final GeneratedColumn<double> vatAmount = GeneratedColumn<double>(
    'vat_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountReceivedMeta = const VerificationMeta(
    'amountReceived',
  );
  @override
  late final GeneratedColumn<double> amountReceived = GeneratedColumn<double>(
    'amount_received',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<double> changeAmount = GeneratedColumn<double>(
    'change_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptNumber,
    status,
    subtotalAmount,
    discountType,
    discountValue,
    discountAmount,
    totalAmount,
    vatMode,
    vatRate,
    vatAmount,
    paymentMethod,
    amountReceived,
    changeAmount,
    note,
    voidedAt,
    voidReason,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(
          data['receipt_number']!,
          _receiptNumberMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('subtotal_amount')) {
      context.handle(
        _subtotalAmountMeta,
        subtotalAmount.isAcceptableOrUnknown(
          data['subtotal_amount']!,
          _subtotalAmountMeta,
        ),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('vat_mode')) {
      context.handle(
        _vatModeMeta,
        vatMode.isAcceptableOrUnknown(data['vat_mode']!, _vatModeMeta),
      );
    }
    if (data.containsKey('vat_rate')) {
      context.handle(
        _vatRateMeta,
        vatRate.isAcceptableOrUnknown(data['vat_rate']!, _vatRateMeta),
      );
    }
    if (data.containsKey('vat_amount')) {
      context.handle(
        _vatAmountMeta,
        vatAmount.isAcceptableOrUnknown(data['vat_amount']!, _vatAmountMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('amount_received')) {
      context.handle(
        _amountReceivedMeta,
        amountReceived.isAcceptableOrUnknown(
          data['amount_received']!,
          _amountReceivedMeta,
        ),
      );
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      receiptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_number'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      subtotalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal_amount'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      ),
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_value'],
      ),
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      vatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vat_mode'],
      )!,
      vatRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vat_rate'],
      )!,
      vatAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vat_amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      amountReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_received'],
      ),
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_amount'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleData extends DataClass implements Insertable<SaleData> {
  final String id;
  final String? receiptNumber;
  final String status;
  final double subtotalAmount;
  final String? discountType;
  final double? discountValue;
  final double discountAmount;
  final double totalAmount;
  final String vatMode;
  final double vatRate;
  final double vatAmount;
  final String paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  final DateTime? voidedAt;
  final String? voidReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? deviceId;
  const SaleData({
    required this.id,
    this.receiptNumber,
    required this.status,
    required this.subtotalAmount,
    this.discountType,
    this.discountValue,
    required this.discountAmount,
    required this.totalAmount,
    required this.vatMode,
    required this.vatRate,
    required this.vatAmount,
    required this.paymentMethod,
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.voidedAt,
    this.voidReason,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || receiptNumber != null) {
      map['receipt_number'] = Variable<String>(receiptNumber);
    }
    map['status'] = Variable<String>(status);
    map['subtotal_amount'] = Variable<double>(subtotalAmount);
    if (!nullToAbsent || discountType != null) {
      map['discount_type'] = Variable<String>(discountType);
    }
    if (!nullToAbsent || discountValue != null) {
      map['discount_value'] = Variable<double>(discountValue);
    }
    map['discount_amount'] = Variable<double>(discountAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['vat_mode'] = Variable<String>(vatMode);
    map['vat_rate'] = Variable<double>(vatRate);
    map['vat_amount'] = Variable<double>(vatAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || amountReceived != null) {
      map['amount_received'] = Variable<double>(amountReceived);
    }
    if (!nullToAbsent || changeAmount != null) {
      map['change_amount'] = Variable<double>(changeAmount);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      receiptNumber: receiptNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptNumber),
      status: Value(status),
      subtotalAmount: Value(subtotalAmount),
      discountType: discountType == null && nullToAbsent
          ? const Value.absent()
          : Value(discountType),
      discountValue: discountValue == null && nullToAbsent
          ? const Value.absent()
          : Value(discountValue),
      discountAmount: Value(discountAmount),
      totalAmount: Value(totalAmount),
      vatMode: Value(vatMode),
      vatRate: Value(vatRate),
      vatAmount: Value(vatAmount),
      paymentMethod: Value(paymentMethod),
      amountReceived: amountReceived == null && nullToAbsent
          ? const Value.absent()
          : Value(amountReceived),
      changeAmount: changeAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(changeAmount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory SaleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleData(
      id: serializer.fromJson<String>(json['id']),
      receiptNumber: serializer.fromJson<String?>(json['receiptNumber']),
      status: serializer.fromJson<String>(json['status']),
      subtotalAmount: serializer.fromJson<double>(json['subtotalAmount']),
      discountType: serializer.fromJson<String?>(json['discountType']),
      discountValue: serializer.fromJson<double?>(json['discountValue']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      vatMode: serializer.fromJson<String>(json['vatMode']),
      vatRate: serializer.fromJson<double>(json['vatRate']),
      vatAmount: serializer.fromJson<double>(json['vatAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      amountReceived: serializer.fromJson<double?>(json['amountReceived']),
      changeAmount: serializer.fromJson<double?>(json['changeAmount']),
      note: serializer.fromJson<String?>(json['note']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'receiptNumber': serializer.toJson<String?>(receiptNumber),
      'status': serializer.toJson<String>(status),
      'subtotalAmount': serializer.toJson<double>(subtotalAmount),
      'discountType': serializer.toJson<String?>(discountType),
      'discountValue': serializer.toJson<double?>(discountValue),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'vatMode': serializer.toJson<String>(vatMode),
      'vatRate': serializer.toJson<double>(vatRate),
      'vatAmount': serializer.toJson<double>(vatAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'amountReceived': serializer.toJson<double?>(amountReceived),
      'changeAmount': serializer.toJson<double?>(changeAmount),
      'note': serializer.toJson<String?>(note),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  SaleData copyWith({
    String? id,
    Value<String?> receiptNumber = const Value.absent(),
    String? status,
    double? subtotalAmount,
    Value<String?> discountType = const Value.absent(),
    Value<double?> discountValue = const Value.absent(),
    double? discountAmount,
    double? totalAmount,
    String? vatMode,
    double? vatRate,
    double? vatAmount,
    String? paymentMethod,
    Value<double?> amountReceived = const Value.absent(),
    Value<double?> changeAmount = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<String?> deviceId = const Value.absent(),
  }) => SaleData(
    id: id ?? this.id,
    receiptNumber: receiptNumber.present
        ? receiptNumber.value
        : this.receiptNumber,
    status: status ?? this.status,
    subtotalAmount: subtotalAmount ?? this.subtotalAmount,
    discountType: discountType.present ? discountType.value : this.discountType,
    discountValue: discountValue.present
        ? discountValue.value
        : this.discountValue,
    discountAmount: discountAmount ?? this.discountAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    vatMode: vatMode ?? this.vatMode,
    vatRate: vatRate ?? this.vatRate,
    vatAmount: vatAmount ?? this.vatAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    amountReceived: amountReceived.present
        ? amountReceived.value
        : this.amountReceived,
    changeAmount: changeAmount.present ? changeAmount.value : this.changeAmount,
    note: note.present ? note.value : this.note,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  SaleData copyWithCompanion(SalesCompanion data) {
    return SaleData(
      id: data.id.present ? data.id.value : this.id,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      status: data.status.present ? data.status.value : this.status,
      subtotalAmount: data.subtotalAmount.present
          ? data.subtotalAmount.value
          : this.subtotalAmount,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      vatMode: data.vatMode.present ? data.vatMode.value : this.vatMode,
      vatRate: data.vatRate.present ? data.vatRate.value : this.vatRate,
      vatAmount: data.vatAmount.present ? data.vatAmount.value : this.vatAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      amountReceived: data.amountReceived.present
          ? data.amountReceived.value
          : this.amountReceived,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      note: data.note.present ? data.note.value : this.note,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleData(')
          ..write('id: $id, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('status: $status, ')
          ..write('subtotalAmount: $subtotalAmount, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('vatMode: $vatMode, ')
          ..write('vatRate: $vatRate, ')
          ..write('vatAmount: $vatAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('amountReceived: $amountReceived, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('note: $note, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    receiptNumber,
    status,
    subtotalAmount,
    discountType,
    discountValue,
    discountAmount,
    totalAmount,
    vatMode,
    vatRate,
    vatAmount,
    paymentMethod,
    amountReceived,
    changeAmount,
    note,
    voidedAt,
    voidReason,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleData &&
          other.id == this.id &&
          other.receiptNumber == this.receiptNumber &&
          other.status == this.status &&
          other.subtotalAmount == this.subtotalAmount &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue &&
          other.discountAmount == this.discountAmount &&
          other.totalAmount == this.totalAmount &&
          other.vatMode == this.vatMode &&
          other.vatRate == this.vatRate &&
          other.vatAmount == this.vatAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.amountReceived == this.amountReceived &&
          other.changeAmount == this.changeAmount &&
          other.note == this.note &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId);
}

class SalesCompanion extends UpdateCompanion<SaleData> {
  final Value<String> id;
  final Value<String?> receiptNumber;
  final Value<String> status;
  final Value<double> subtotalAmount;
  final Value<String?> discountType;
  final Value<double?> discountValue;
  final Value<double> discountAmount;
  final Value<double> totalAmount;
  final Value<String> vatMode;
  final Value<double> vatRate;
  final Value<double> vatAmount;
  final Value<String> paymentMethod;
  final Value<double?> amountReceived;
  final Value<double?> changeAmount;
  final Value<String?> note;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.subtotalAmount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.vatMode = const Value.absent(),
    this.vatRate = const Value.absent(),
    this.vatAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.amountReceived = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    this.receiptNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.subtotalAmount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    required double totalAmount,
    this.vatMode = const Value.absent(),
    this.vatRate = const Value.absent(),
    this.vatAmount = const Value.absent(),
    required String paymentMethod,
    this.amountReceived = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       totalAmount = Value(totalAmount),
       paymentMethod = Value(paymentMethod);
  static Insertable<SaleData> custom({
    Expression<String>? id,
    Expression<String>? receiptNumber,
    Expression<String>? status,
    Expression<double>? subtotalAmount,
    Expression<String>? discountType,
    Expression<double>? discountValue,
    Expression<double>? discountAmount,
    Expression<double>? totalAmount,
    Expression<String>? vatMode,
    Expression<double>? vatRate,
    Expression<double>? vatAmount,
    Expression<String>? paymentMethod,
    Expression<double>? amountReceived,
    Expression<double>? changeAmount,
    Expression<String>? note,
    Expression<DateTime>? voidedAt,
    Expression<String>? voidReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (status != null) 'status': status,
      if (subtotalAmount != null) 'subtotal_amount': subtotalAmount,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (vatMode != null) 'vat_mode': vatMode,
      if (vatRate != null) 'vat_rate': vatRate,
      if (vatAmount != null) 'vat_amount': vatAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (amountReceived != null) 'amount_received': amountReceived,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (note != null) 'note': note,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String?>? receiptNumber,
    Value<String>? status,
    Value<double>? subtotalAmount,
    Value<String?>? discountType,
    Value<double?>? discountValue,
    Value<double>? discountAmount,
    Value<double>? totalAmount,
    Value<String>? vatMode,
    Value<double>? vatRate,
    Value<double>? vatAmount,
    Value<String>? paymentMethod,
    Value<double?>? amountReceived,
    Value<double?>? changeAmount,
    Value<String?>? note,
    Value<DateTime?>? voidedAt,
    Value<String?>? voidReason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      status: status ?? this.status,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      vatMode: vatMode ?? this.vatMode,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      note: note ?? this.note,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subtotalAmount.present) {
      map['subtotal_amount'] = Variable<double>(subtotalAmount.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (vatMode.present) {
      map['vat_mode'] = Variable<String>(vatMode.value);
    }
    if (vatRate.present) {
      map['vat_rate'] = Variable<double>(vatRate.value);
    }
    if (vatAmount.present) {
      map['vat_amount'] = Variable<double>(vatAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (amountReceived.present) {
      map['amount_received'] = Variable<double>(amountReceived.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<double>(changeAmount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('status: $status, ')
          ..write('subtotalAmount: $subtotalAmount, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('vatMode: $vatMode, ')
          ..write('vatRate: $vatRate, ')
          ..write('vatAmount: $vatAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('amountReceived: $amountReceived, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('note: $note, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vatAmountMeta = const VerificationMeta(
    'vatAmount',
  );
  @override
  late final GeneratedColumn<double> vatAmount = GeneratedColumn<double>(
    'vat_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    productId,
    productName,
    price,
    qty,
    discountAmount,
    vatAmount,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('vat_amount')) {
      context.handle(
        _vatAmountMeta,
        vatAmount.isAcceptableOrUnknown(data['vat_amount']!, _vatAmountMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      vatAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vat_amount'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItemData extends DataClass implements Insertable<SaleItemData> {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final double price;
  final int qty;
  final double discountAmount;
  final double vatAmount;
  final double subtotal;
  const SaleItemData({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.discountAmount,
    required this.vatAmount,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['price'] = Variable<double>(price);
    map['qty'] = Variable<int>(qty);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['vat_amount'] = Variable<double>(vatAmount);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      price: Value(price),
      qty: Value(qty),
      discountAmount: Value(discountAmount),
      vatAmount: Value(vatAmount),
      subtotal: Value(subtotal),
    );
  }

  factory SaleItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemData(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      price: serializer.fromJson<double>(json['price']),
      qty: serializer.fromJson<int>(json['qty']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      vatAmount: serializer.fromJson<double>(json['vatAmount']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'price': serializer.toJson<double>(price),
      'qty': serializer.toJson<int>(qty),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'vatAmount': serializer.toJson<double>(vatAmount),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  SaleItemData copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    double? price,
    int? qty,
    double? discountAmount,
    double? vatAmount,
    double? subtotal,
  }) => SaleItemData(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    price: price ?? this.price,
    qty: qty ?? this.qty,
    discountAmount: discountAmount ?? this.discountAmount,
    vatAmount: vatAmount ?? this.vatAmount,
    subtotal: subtotal ?? this.subtotal,
  );
  SaleItemData copyWithCompanion(SaleItemsCompanion data) {
    return SaleItemData(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      vatAmount: data.vatAmount.present ? data.vatAmount.value : this.vatAmount,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemData(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('vatAmount: $vatAmount, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    productId,
    productName,
    price,
    qty,
    discountAmount,
    vatAmount,
    subtotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemData &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.price == this.price &&
          other.qty == this.qty &&
          other.discountAmount == this.discountAmount &&
          other.vatAmount == this.vatAmount &&
          other.subtotal == this.subtotal);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItemData> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> price;
  final Value<int> qty;
  final Value<double> discountAmount;
  final Value<double> vatAmount;
  final Value<double> subtotal;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.vatAmount = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required String saleId,
    required String productId,
    required String productName,
    required double price,
    required int qty,
    this.discountAmount = const Value.absent(),
    this.vatAmount = const Value.absent(),
    required double subtotal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       productId = Value(productId),
       productName = Value(productName),
       price = Value(price),
       qty = Value(qty),
       subtotal = Value(subtotal);
  static Insertable<SaleItemData> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? price,
    Expression<int>? qty,
    Expression<double>? discountAmount,
    Expression<double>? vatAmount,
    Expression<double>? subtotal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (vatAmount != null) 'vat_amount': vatAmount,
      if (subtotal != null) 'subtotal': subtotal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? productId,
    Value<String>? productName,
    Value<double>? price,
    Value<int>? qty,
    Value<double>? discountAmount,
    Value<double>? vatAmount,
    Value<double>? subtotal,
    Value<int>? rowid,
  }) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountAmount: discountAmount ?? this.discountAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      subtotal: subtotal ?? this.subtotal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (vatAmount.present) {
      map['vat_amount'] = Variable<double>(vatAmount.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('vatAmount: $vatAmount, ')
          ..write('subtotal: $subtotal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? deviceId;
  const CategoryData({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory CategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  CategoryData copyWith({
    String? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<String?> deviceId = const Value.absent(),
  }) => CategoryData(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  CategoryData copyWithCompanion(CategoriesCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId);
}

class CategoriesCompanion extends UpdateCompanion<CategoryData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CategoryData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryLogsTable extends InventoryLogs
    with TableInfo<$InventoryLogsTable, InventoryLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyChangeMeta = const VerificationMeta(
    'qtyChange',
  );
  @override
  late final GeneratedColumn<int> qtyChange = GeneratedColumn<int>(
    'qty_change',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refSaleIdMeta = const VerificationMeta(
    'refSaleId',
  );
  @override
  late final GeneratedColumn<String> refSaleId = GeneratedColumn<String>(
    'ref_sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    type,
    qtyChange,
    balanceAfter,
    reason,
    refSaleId,
    createdAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('qty_change')) {
      context.handle(
        _qtyChangeMeta,
        qtyChange.isAcceptableOrUnknown(data['qty_change']!, _qtyChangeMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyChangeMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('ref_sale_id')) {
      context.handle(
        _refSaleIdMeta,
        refSaleId.isAcceptableOrUnknown(data['ref_sale_id']!, _refSaleIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      qtyChange: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_change'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_after'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      refSaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_sale_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $InventoryLogsTable createAlias(String alias) {
    return $InventoryLogsTable(attachedDatabase, alias);
  }
}

class InventoryLogData extends DataClass
    implements Insertable<InventoryLogData> {
  final String id;
  final String productId;
  final String type;
  final int qtyChange;
  final int balanceAfter;
  final String? reason;
  final String? refSaleId;
  final DateTime createdAt;
  final String? deviceId;
  const InventoryLogData({
    required this.id,
    required this.productId,
    required this.type,
    required this.qtyChange,
    required this.balanceAfter,
    this.reason,
    this.refSaleId,
    required this.createdAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['type'] = Variable<String>(type);
    map['qty_change'] = Variable<int>(qtyChange);
    map['balance_after'] = Variable<int>(balanceAfter);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || refSaleId != null) {
      map['ref_sale_id'] = Variable<String>(refSaleId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  InventoryLogsCompanion toCompanion(bool nullToAbsent) {
    return InventoryLogsCompanion(
      id: Value(id),
      productId: Value(productId),
      type: Value(type),
      qtyChange: Value(qtyChange),
      balanceAfter: Value(balanceAfter),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      refSaleId: refSaleId == null && nullToAbsent
          ? const Value.absent()
          : Value(refSaleId),
      createdAt: Value(createdAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory InventoryLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryLogData(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      type: serializer.fromJson<String>(json['type']),
      qtyChange: serializer.fromJson<int>(json['qtyChange']),
      balanceAfter: serializer.fromJson<int>(json['balanceAfter']),
      reason: serializer.fromJson<String?>(json['reason']),
      refSaleId: serializer.fromJson<String?>(json['refSaleId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'type': serializer.toJson<String>(type),
      'qtyChange': serializer.toJson<int>(qtyChange),
      'balanceAfter': serializer.toJson<int>(balanceAfter),
      'reason': serializer.toJson<String?>(reason),
      'refSaleId': serializer.toJson<String?>(refSaleId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  InventoryLogData copyWith({
    String? id,
    String? productId,
    String? type,
    int? qtyChange,
    int? balanceAfter,
    Value<String?> reason = const Value.absent(),
    Value<String?> refSaleId = const Value.absent(),
    DateTime? createdAt,
    Value<String?> deviceId = const Value.absent(),
  }) => InventoryLogData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    type: type ?? this.type,
    qtyChange: qtyChange ?? this.qtyChange,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    reason: reason.present ? reason.value : this.reason,
    refSaleId: refSaleId.present ? refSaleId.value : this.refSaleId,
    createdAt: createdAt ?? this.createdAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  InventoryLogData copyWithCompanion(InventoryLogsCompanion data) {
    return InventoryLogData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      type: data.type.present ? data.type.value : this.type,
      qtyChange: data.qtyChange.present ? data.qtyChange.value : this.qtyChange,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      reason: data.reason.present ? data.reason.value : this.reason,
      refSaleId: data.refSaleId.present ? data.refSaleId.value : this.refSaleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryLogData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('qtyChange: $qtyChange, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('reason: $reason, ')
          ..write('refSaleId: $refSaleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    type,
    qtyChange,
    balanceAfter,
    reason,
    refSaleId,
    createdAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryLogData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.type == this.type &&
          other.qtyChange == this.qtyChange &&
          other.balanceAfter == this.balanceAfter &&
          other.reason == this.reason &&
          other.refSaleId == this.refSaleId &&
          other.createdAt == this.createdAt &&
          other.deviceId == this.deviceId);
}

class InventoryLogsCompanion extends UpdateCompanion<InventoryLogData> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> type;
  final Value<int> qtyChange;
  final Value<int> balanceAfter;
  final Value<String?> reason;
  final Value<String?> refSaleId;
  final Value<DateTime> createdAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const InventoryLogsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.type = const Value.absent(),
    this.qtyChange = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.reason = const Value.absent(),
    this.refSaleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryLogsCompanion.insert({
    required String id,
    required String productId,
    required String type,
    required int qtyChange,
    required int balanceAfter,
    this.reason = const Value.absent(),
    this.refSaleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       type = Value(type),
       qtyChange = Value(qtyChange),
       balanceAfter = Value(balanceAfter);
  static Insertable<InventoryLogData> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? type,
    Expression<int>? qtyChange,
    Expression<int>? balanceAfter,
    Expression<String>? reason,
    Expression<String>? refSaleId,
    Expression<DateTime>? createdAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (type != null) 'type': type,
      if (qtyChange != null) 'qty_change': qtyChange,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (reason != null) 'reason': reason,
      if (refSaleId != null) 'ref_sale_id': refSaleId,
      if (createdAt != null) 'created_at': createdAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? type,
    Value<int>? qtyChange,
    Value<int>? balanceAfter,
    Value<String?>? reason,
    Value<String?>? refSaleId,
    Value<DateTime>? createdAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return InventoryLogsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      qtyChange: qtyChange ?? this.qtyChange,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      reason: reason ?? this.reason,
      refSaleId: refSaleId ?? this.refSaleId,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (qtyChange.present) {
      map['qty_change'] = Variable<int>(qtyChange.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (refSaleId.present) {
      map['ref_sale_id'] = Variable<String>(refSaleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryLogsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('qtyChange: $qtyChange, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('reason: $reason, ')
          ..write('refSaleId: $refSaleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingData extends DataClass implements Insertable<AppSettingData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingData copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingData(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingData copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftCartsTable extends DraftCarts
    with TableInfo<$DraftCartsTable, DraftCartData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftCartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    note,
    createdAt,
    updatedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_carts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftCartData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftCartData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftCartData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $DraftCartsTable createAlias(String alias) {
    return $DraftCartsTable(attachedDatabase, alias);
  }
}

class DraftCartData extends DataClass implements Insertable<DraftCartData> {
  final String id;
  final String? name;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deviceId;
  const DraftCartData({
    required this.id,
    this.name,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  DraftCartsCompanion toCompanion(bool nullToAbsent) {
    return DraftCartsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory DraftCartData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftCartData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  DraftCartData copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> deviceId = const Value.absent(),
  }) => DraftCartData(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  DraftCartData copyWithCompanion(DraftCartsCompanion data) {
    return DraftCartData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftCartData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, note, createdAt, updatedAt, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftCartData &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId);
}

class DraftCartsCompanion extends UpdateCompanion<DraftCartData> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const DraftCartsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftCartsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DraftCartData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftCartsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return DraftCartsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftCartsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftCartItemsTable extends DraftCartItems
    with TableInfo<$DraftCartItemsTable, DraftCartItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftCartItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cartIdMeta = const VerificationMeta('cartId');
  @override
  late final GeneratedColumn<String> cartId = GeneratedColumn<String>(
    'cart_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES draft_carts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
    'discount_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cartId,
    productId,
    productName,
    price,
    qty,
    discountType,
    discountValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_cart_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftCartItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cart_id')) {
      context.handle(
        _cartIdMeta,
        cartId.isAcceptableOrUnknown(data['cart_id']!, _cartIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftCartItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftCartItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cartId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cart_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      ),
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_value'],
      ),
    );
  }

  @override
  $DraftCartItemsTable createAlias(String alias) {
    return $DraftCartItemsTable(attachedDatabase, alias);
  }
}

class DraftCartItemData extends DataClass
    implements Insertable<DraftCartItemData> {
  final String id;
  final String cartId;
  final String productId;
  final String productName;
  final double price;
  final int qty;
  final String? discountType;
  final double? discountValue;
  const DraftCartItemData({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    this.discountType,
    this.discountValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cart_id'] = Variable<String>(cartId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['price'] = Variable<double>(price);
    map['qty'] = Variable<int>(qty);
    if (!nullToAbsent || discountType != null) {
      map['discount_type'] = Variable<String>(discountType);
    }
    if (!nullToAbsent || discountValue != null) {
      map['discount_value'] = Variable<double>(discountValue);
    }
    return map;
  }

  DraftCartItemsCompanion toCompanion(bool nullToAbsent) {
    return DraftCartItemsCompanion(
      id: Value(id),
      cartId: Value(cartId),
      productId: Value(productId),
      productName: Value(productName),
      price: Value(price),
      qty: Value(qty),
      discountType: discountType == null && nullToAbsent
          ? const Value.absent()
          : Value(discountType),
      discountValue: discountValue == null && nullToAbsent
          ? const Value.absent()
          : Value(discountValue),
    );
  }

  factory DraftCartItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftCartItemData(
      id: serializer.fromJson<String>(json['id']),
      cartId: serializer.fromJson<String>(json['cartId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      price: serializer.fromJson<double>(json['price']),
      qty: serializer.fromJson<int>(json['qty']),
      discountType: serializer.fromJson<String?>(json['discountType']),
      discountValue: serializer.fromJson<double?>(json['discountValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cartId': serializer.toJson<String>(cartId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'price': serializer.toJson<double>(price),
      'qty': serializer.toJson<int>(qty),
      'discountType': serializer.toJson<String?>(discountType),
      'discountValue': serializer.toJson<double?>(discountValue),
    };
  }

  DraftCartItemData copyWith({
    String? id,
    String? cartId,
    String? productId,
    String? productName,
    double? price,
    int? qty,
    Value<String?> discountType = const Value.absent(),
    Value<double?> discountValue = const Value.absent(),
  }) => DraftCartItemData(
    id: id ?? this.id,
    cartId: cartId ?? this.cartId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    price: price ?? this.price,
    qty: qty ?? this.qty,
    discountType: discountType.present ? discountType.value : this.discountType,
    discountValue: discountValue.present
        ? discountValue.value
        : this.discountValue,
  );
  DraftCartItemData copyWithCompanion(DraftCartItemsCompanion data) {
    return DraftCartItemData(
      id: data.id.present ? data.id.value : this.id,
      cartId: data.cartId.present ? data.cartId.value : this.cartId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftCartItemData(')
          ..write('id: $id, ')
          ..write('cartId: $cartId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cartId,
    productId,
    productName,
    price,
    qty,
    discountType,
    discountValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftCartItemData &&
          other.id == this.id &&
          other.cartId == this.cartId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.price == this.price &&
          other.qty == this.qty &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue);
}

class DraftCartItemsCompanion extends UpdateCompanion<DraftCartItemData> {
  final Value<String> id;
  final Value<String> cartId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> price;
  final Value<int> qty;
  final Value<String?> discountType;
  final Value<double?> discountValue;
  final Value<int> rowid;
  const DraftCartItemsCompanion({
    this.id = const Value.absent(),
    this.cartId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftCartItemsCompanion.insert({
    required String id,
    required String cartId,
    required String productId,
    required String productName,
    required double price,
    required int qty,
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cartId = Value(cartId),
       productId = Value(productId),
       productName = Value(productName),
       price = Value(price),
       qty = Value(qty);
  static Insertable<DraftCartItemData> custom({
    Expression<String>? id,
    Expression<String>? cartId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? price,
    Expression<int>? qty,
    Expression<String>? discountType,
    Expression<double>? discountValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartId != null) 'cart_id': cartId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftCartItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? cartId,
    Value<String>? productId,
    Value<String>? productName,
    Value<double>? price,
    Value<int>? qty,
    Value<String?>? discountType,
    Value<double?>? discountValue,
    Value<int>? rowid,
  }) {
    return DraftCartItemsCompanion(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cartId.present) {
      map['cart_id'] = Variable<String>(cartId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftCartItemsCompanion(')
          ..write('id: $id, ')
          ..write('cartId: $cartId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyClosesTable extends DailyCloses
    with TableInfo<$DailyClosesTable, DailyCloseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyClosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closeDateMeta = const VerificationMeta(
    'closeDate',
  );
  @override
  late final GeneratedColumn<String> closeDate = GeneratedColumn<String>(
    'close_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingCashMeta = const VerificationMeta(
    'openingCash',
  );
  @override
  late final GeneratedColumn<double> openingCash = GeneratedColumn<double>(
    'opening_cash',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedCashMeta = const VerificationMeta(
    'expectedCash',
  );
  @override
  late final GeneratedColumn<double> expectedCash = GeneratedColumn<double>(
    'expected_cash',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _countedCashMeta = const VerificationMeta(
    'countedCash',
  );
  @override
  late final GeneratedColumn<double> countedCash = GeneratedColumn<double>(
    'counted_cash',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _overShortAmountMeta = const VerificationMeta(
    'overShortAmount',
  );
  @override
  late final GeneratedColumn<double> overShortAmount = GeneratedColumn<double>(
    'over_short_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalRevenueMeta = const VerificationMeta(
    'totalRevenue',
  );
  @override
  late final GeneratedColumn<double> totalRevenue = GeneratedColumn<double>(
    'total_revenue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalVoidMeta = const VerificationMeta(
    'totalVoid',
  );
  @override
  late final GeneratedColumn<double> totalVoid = GeneratedColumn<double>(
    'total_void',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _salesCountMeta = const VerificationMeta(
    'salesCount',
  );
  @override
  late final GeneratedColumn<int> salesCount = GeneratedColumn<int>(
    'sales_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _voidCountMeta = const VerificationMeta(
    'voidCount',
  );
  @override
  late final GeneratedColumn<int> voidCount = GeneratedColumn<int>(
    'void_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    closeDate,
    openingCash,
    expectedCash,
    countedCash,
    overShortAmount,
    totalRevenue,
    totalVoid,
    salesCount,
    voidCount,
    note,
    closedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_closes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyCloseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('close_date')) {
      context.handle(
        _closeDateMeta,
        closeDate.isAcceptableOrUnknown(data['close_date']!, _closeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_closeDateMeta);
    }
    if (data.containsKey('opening_cash')) {
      context.handle(
        _openingCashMeta,
        openingCash.isAcceptableOrUnknown(
          data['opening_cash']!,
          _openingCashMeta,
        ),
      );
    }
    if (data.containsKey('expected_cash')) {
      context.handle(
        _expectedCashMeta,
        expectedCash.isAcceptableOrUnknown(
          data['expected_cash']!,
          _expectedCashMeta,
        ),
      );
    }
    if (data.containsKey('counted_cash')) {
      context.handle(
        _countedCashMeta,
        countedCash.isAcceptableOrUnknown(
          data['counted_cash']!,
          _countedCashMeta,
        ),
      );
    }
    if (data.containsKey('over_short_amount')) {
      context.handle(
        _overShortAmountMeta,
        overShortAmount.isAcceptableOrUnknown(
          data['over_short_amount']!,
          _overShortAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_revenue')) {
      context.handle(
        _totalRevenueMeta,
        totalRevenue.isAcceptableOrUnknown(
          data['total_revenue']!,
          _totalRevenueMeta,
        ),
      );
    }
    if (data.containsKey('total_void')) {
      context.handle(
        _totalVoidMeta,
        totalVoid.isAcceptableOrUnknown(data['total_void']!, _totalVoidMeta),
      );
    }
    if (data.containsKey('sales_count')) {
      context.handle(
        _salesCountMeta,
        salesCount.isAcceptableOrUnknown(data['sales_count']!, _salesCountMeta),
      );
    }
    if (data.containsKey('void_count')) {
      context.handle(
        _voidCountMeta,
        voidCount.isAcceptableOrUnknown(data['void_count']!, _voidCountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyCloseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCloseData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      closeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close_date'],
      )!,
      openingCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_cash'],
      )!,
      expectedCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_cash'],
      )!,
      countedCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}counted_cash'],
      )!,
      overShortAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}over_short_amount'],
      )!,
      totalRevenue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_revenue'],
      )!,
      totalVoid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_void'],
      )!,
      salesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sales_count'],
      )!,
      voidCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}void_count'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $DailyClosesTable createAlias(String alias) {
    return $DailyClosesTable(attachedDatabase, alias);
  }
}

class DailyCloseData extends DataClass implements Insertable<DailyCloseData> {
  final String id;
  final String closeDate;
  final double openingCash;
  final double expectedCash;
  final double countedCash;
  final double overShortAmount;
  final double totalRevenue;
  final double totalVoid;
  final int salesCount;
  final int voidCount;
  final String? note;
  final DateTime closedAt;
  final String? deviceId;
  const DailyCloseData({
    required this.id,
    required this.closeDate,
    required this.openingCash,
    required this.expectedCash,
    required this.countedCash,
    required this.overShortAmount,
    required this.totalRevenue,
    required this.totalVoid,
    required this.salesCount,
    required this.voidCount,
    this.note,
    required this.closedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['close_date'] = Variable<String>(closeDate);
    map['opening_cash'] = Variable<double>(openingCash);
    map['expected_cash'] = Variable<double>(expectedCash);
    map['counted_cash'] = Variable<double>(countedCash);
    map['over_short_amount'] = Variable<double>(overShortAmount);
    map['total_revenue'] = Variable<double>(totalRevenue);
    map['total_void'] = Variable<double>(totalVoid);
    map['sales_count'] = Variable<int>(salesCount);
    map['void_count'] = Variable<int>(voidCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['closed_at'] = Variable<DateTime>(closedAt);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  DailyClosesCompanion toCompanion(bool nullToAbsent) {
    return DailyClosesCompanion(
      id: Value(id),
      closeDate: Value(closeDate),
      openingCash: Value(openingCash),
      expectedCash: Value(expectedCash),
      countedCash: Value(countedCash),
      overShortAmount: Value(overShortAmount),
      totalRevenue: Value(totalRevenue),
      totalVoid: Value(totalVoid),
      salesCount: Value(salesCount),
      voidCount: Value(voidCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      closedAt: Value(closedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory DailyCloseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCloseData(
      id: serializer.fromJson<String>(json['id']),
      closeDate: serializer.fromJson<String>(json['closeDate']),
      openingCash: serializer.fromJson<double>(json['openingCash']),
      expectedCash: serializer.fromJson<double>(json['expectedCash']),
      countedCash: serializer.fromJson<double>(json['countedCash']),
      overShortAmount: serializer.fromJson<double>(json['overShortAmount']),
      totalRevenue: serializer.fromJson<double>(json['totalRevenue']),
      totalVoid: serializer.fromJson<double>(json['totalVoid']),
      salesCount: serializer.fromJson<int>(json['salesCount']),
      voidCount: serializer.fromJson<int>(json['voidCount']),
      note: serializer.fromJson<String?>(json['note']),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'closeDate': serializer.toJson<String>(closeDate),
      'openingCash': serializer.toJson<double>(openingCash),
      'expectedCash': serializer.toJson<double>(expectedCash),
      'countedCash': serializer.toJson<double>(countedCash),
      'overShortAmount': serializer.toJson<double>(overShortAmount),
      'totalRevenue': serializer.toJson<double>(totalRevenue),
      'totalVoid': serializer.toJson<double>(totalVoid),
      'salesCount': serializer.toJson<int>(salesCount),
      'voidCount': serializer.toJson<int>(voidCount),
      'note': serializer.toJson<String?>(note),
      'closedAt': serializer.toJson<DateTime>(closedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  DailyCloseData copyWith({
    String? id,
    String? closeDate,
    double? openingCash,
    double? expectedCash,
    double? countedCash,
    double? overShortAmount,
    double? totalRevenue,
    double? totalVoid,
    int? salesCount,
    int? voidCount,
    Value<String?> note = const Value.absent(),
    DateTime? closedAt,
    Value<String?> deviceId = const Value.absent(),
  }) => DailyCloseData(
    id: id ?? this.id,
    closeDate: closeDate ?? this.closeDate,
    openingCash: openingCash ?? this.openingCash,
    expectedCash: expectedCash ?? this.expectedCash,
    countedCash: countedCash ?? this.countedCash,
    overShortAmount: overShortAmount ?? this.overShortAmount,
    totalRevenue: totalRevenue ?? this.totalRevenue,
    totalVoid: totalVoid ?? this.totalVoid,
    salesCount: salesCount ?? this.salesCount,
    voidCount: voidCount ?? this.voidCount,
    note: note.present ? note.value : this.note,
    closedAt: closedAt ?? this.closedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  DailyCloseData copyWithCompanion(DailyClosesCompanion data) {
    return DailyCloseData(
      id: data.id.present ? data.id.value : this.id,
      closeDate: data.closeDate.present ? data.closeDate.value : this.closeDate,
      openingCash: data.openingCash.present
          ? data.openingCash.value
          : this.openingCash,
      expectedCash: data.expectedCash.present
          ? data.expectedCash.value
          : this.expectedCash,
      countedCash: data.countedCash.present
          ? data.countedCash.value
          : this.countedCash,
      overShortAmount: data.overShortAmount.present
          ? data.overShortAmount.value
          : this.overShortAmount,
      totalRevenue: data.totalRevenue.present
          ? data.totalRevenue.value
          : this.totalRevenue,
      totalVoid: data.totalVoid.present ? data.totalVoid.value : this.totalVoid,
      salesCount: data.salesCount.present
          ? data.salesCount.value
          : this.salesCount,
      voidCount: data.voidCount.present ? data.voidCount.value : this.voidCount,
      note: data.note.present ? data.note.value : this.note,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCloseData(')
          ..write('id: $id, ')
          ..write('closeDate: $closeDate, ')
          ..write('openingCash: $openingCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('countedCash: $countedCash, ')
          ..write('overShortAmount: $overShortAmount, ')
          ..write('totalRevenue: $totalRevenue, ')
          ..write('totalVoid: $totalVoid, ')
          ..write('salesCount: $salesCount, ')
          ..write('voidCount: $voidCount, ')
          ..write('note: $note, ')
          ..write('closedAt: $closedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    closeDate,
    openingCash,
    expectedCash,
    countedCash,
    overShortAmount,
    totalRevenue,
    totalVoid,
    salesCount,
    voidCount,
    note,
    closedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCloseData &&
          other.id == this.id &&
          other.closeDate == this.closeDate &&
          other.openingCash == this.openingCash &&
          other.expectedCash == this.expectedCash &&
          other.countedCash == this.countedCash &&
          other.overShortAmount == this.overShortAmount &&
          other.totalRevenue == this.totalRevenue &&
          other.totalVoid == this.totalVoid &&
          other.salesCount == this.salesCount &&
          other.voidCount == this.voidCount &&
          other.note == this.note &&
          other.closedAt == this.closedAt &&
          other.deviceId == this.deviceId);
}

class DailyClosesCompanion extends UpdateCompanion<DailyCloseData> {
  final Value<String> id;
  final Value<String> closeDate;
  final Value<double> openingCash;
  final Value<double> expectedCash;
  final Value<double> countedCash;
  final Value<double> overShortAmount;
  final Value<double> totalRevenue;
  final Value<double> totalVoid;
  final Value<int> salesCount;
  final Value<int> voidCount;
  final Value<String?> note;
  final Value<DateTime> closedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const DailyClosesCompanion({
    this.id = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.openingCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.countedCash = const Value.absent(),
    this.overShortAmount = const Value.absent(),
    this.totalRevenue = const Value.absent(),
    this.totalVoid = const Value.absent(),
    this.salesCount = const Value.absent(),
    this.voidCount = const Value.absent(),
    this.note = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyClosesCompanion.insert({
    required String id,
    required String closeDate,
    this.openingCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.countedCash = const Value.absent(),
    this.overShortAmount = const Value.absent(),
    this.totalRevenue = const Value.absent(),
    this.totalVoid = const Value.absent(),
    this.salesCount = const Value.absent(),
    this.voidCount = const Value.absent(),
    this.note = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       closeDate = Value(closeDate);
  static Insertable<DailyCloseData> custom({
    Expression<String>? id,
    Expression<String>? closeDate,
    Expression<double>? openingCash,
    Expression<double>? expectedCash,
    Expression<double>? countedCash,
    Expression<double>? overShortAmount,
    Expression<double>? totalRevenue,
    Expression<double>? totalVoid,
    Expression<int>? salesCount,
    Expression<int>? voidCount,
    Expression<String>? note,
    Expression<DateTime>? closedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (closeDate != null) 'close_date': closeDate,
      if (openingCash != null) 'opening_cash': openingCash,
      if (expectedCash != null) 'expected_cash': expectedCash,
      if (countedCash != null) 'counted_cash': countedCash,
      if (overShortAmount != null) 'over_short_amount': overShortAmount,
      if (totalRevenue != null) 'total_revenue': totalRevenue,
      if (totalVoid != null) 'total_void': totalVoid,
      if (salesCount != null) 'sales_count': salesCount,
      if (voidCount != null) 'void_count': voidCount,
      if (note != null) 'note': note,
      if (closedAt != null) 'closed_at': closedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyClosesCompanion copyWith({
    Value<String>? id,
    Value<String>? closeDate,
    Value<double>? openingCash,
    Value<double>? expectedCash,
    Value<double>? countedCash,
    Value<double>? overShortAmount,
    Value<double>? totalRevenue,
    Value<double>? totalVoid,
    Value<int>? salesCount,
    Value<int>? voidCount,
    Value<String?>? note,
    Value<DateTime>? closedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return DailyClosesCompanion(
      id: id ?? this.id,
      closeDate: closeDate ?? this.closeDate,
      openingCash: openingCash ?? this.openingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      countedCash: countedCash ?? this.countedCash,
      overShortAmount: overShortAmount ?? this.overShortAmount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalVoid: totalVoid ?? this.totalVoid,
      salesCount: salesCount ?? this.salesCount,
      voidCount: voidCount ?? this.voidCount,
      note: note ?? this.note,
      closedAt: closedAt ?? this.closedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (closeDate.present) {
      map['close_date'] = Variable<String>(closeDate.value);
    }
    if (openingCash.present) {
      map['opening_cash'] = Variable<double>(openingCash.value);
    }
    if (expectedCash.present) {
      map['expected_cash'] = Variable<double>(expectedCash.value);
    }
    if (countedCash.present) {
      map['counted_cash'] = Variable<double>(countedCash.value);
    }
    if (overShortAmount.present) {
      map['over_short_amount'] = Variable<double>(overShortAmount.value);
    }
    if (totalRevenue.present) {
      map['total_revenue'] = Variable<double>(totalRevenue.value);
    }
    if (totalVoid.present) {
      map['total_void'] = Variable<double>(totalVoid.value);
    }
    if (salesCount.present) {
      map['sales_count'] = Variable<int>(salesCount.value);
    }
    if (voidCount.present) {
      map['void_count'] = Variable<int>(voidCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosesCompanion(')
          ..write('id: $id, ')
          ..write('closeDate: $closeDate, ')
          ..write('openingCash: $openingCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('countedCash: $countedCash, ')
          ..write('overShortAmount: $overShortAmount, ')
          ..write('totalRevenue: $totalRevenue, ')
          ..write('totalVoid: $totalVoid, ')
          ..write('salesCount: $salesCount, ')
          ..write('voidCount: $voidCount, ')
          ..write('note: $note, ')
          ..write('closedAt: $closedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $InventoryLogsTable inventoryLogs = $InventoryLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DraftCartsTable draftCarts = $DraftCartsTable(this);
  late final $DraftCartItemsTable draftCartItems = $DraftCartItemsTable(this);
  late final $DailyClosesTable dailyCloses = $DailyClosesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    sales,
    saleItems,
    categories,
    inventoryLogs,
    appSettings,
    draftCarts,
    draftCartItems,
    dailyCloses,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sales',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sale_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'draft_carts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('draft_cart_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      Value<String?> sku,
      Value<String?> barcode,
      required double price,
      Value<double?> cost,
      Value<int> stock,
      Value<String?> categoryId,
      Value<String?> imageUrl,
      Value<bool> trackStock,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> sku,
      Value<String?> barcode,
      Value<double> price,
      Value<double?> cost,
      Value<int> stock,
      Value<String?> categoryId,
      Value<String?> imageUrl,
      Value<bool> trackStock,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductData,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductData,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductData>,
          ),
          ProductData,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> trackStock = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                sku: sku,
                barcode: barcode,
                price: price,
                cost: cost,
                stock: stock,
                categoryId: categoryId,
                imageUrl: imageUrl,
                trackStock: trackStock,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required double price,
                Value<double?> cost = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> trackStock = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                sku: sku,
                barcode: barcode,
                price: price,
                cost: cost,
                stock: stock,
                categoryId: categoryId,
                imageUrl: imageUrl,
                trackStock: trackStock,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductData,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductData, BaseReferences<_$AppDatabase, $ProductsTable, ProductData>),
      ProductData,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      Value<String?> receiptNumber,
      Value<String> status,
      Value<double> subtotalAmount,
      Value<String?> discountType,
      Value<double?> discountValue,
      Value<double> discountAmount,
      required double totalAmount,
      Value<String> vatMode,
      Value<double> vatRate,
      Value<double> vatAmount,
      required String paymentMethod,
      Value<double?> amountReceived,
      Value<double?> changeAmount,
      Value<String?> note,
      Value<DateTime?> voidedAt,
      Value<String?> voidReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<String?> receiptNumber,
      Value<String> status,
      Value<double> subtotalAmount,
      Value<String?> discountType,
      Value<double?> discountValue,
      Value<double> discountAmount,
      Value<double> totalAmount,
      Value<String> vatMode,
      Value<double> vatRate,
      Value<double> vatAmount,
      Value<String> paymentMethod,
      Value<double?> amountReceived,
      Value<double?> changeAmount,
      Value<String?> note,
      Value<DateTime?> voidedAt,
      Value<String?> voidReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> deviceId,
      Value<int> rowid,
    });

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, SaleData> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItemData>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: $_aliasNameGenerator(db.sales.id, db.saleItems.saleId),
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotalAmount => $composableBuilder(
    column: $table.subtotalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vatMode => $composableBuilder(
    column: $table.vatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vatRate => $composableBuilder(
    column: $table.vatRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vatAmount => $composableBuilder(
    column: $table.vatAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountReceived => $composableBuilder(
    column: $table.amountReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotalAmount => $composableBuilder(
    column: $table.subtotalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vatMode => $composableBuilder(
    column: $table.vatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vatRate => $composableBuilder(
    column: $table.vatRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vatAmount => $composableBuilder(
    column: $table.vatAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountReceived => $composableBuilder(
    column: $table.amountReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get subtotalAmount => $composableBuilder(
    column: $table.subtotalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vatMode =>
      $composableBuilder(column: $table.vatMode, builder: (column) => column);

  GeneratedColumn<double> get vatRate =>
      $composableBuilder(column: $table.vatRate, builder: (column) => column);

  GeneratedColumn<double> get vatAmount =>
      $composableBuilder(column: $table.vatAmount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountReceived => $composableBuilder(
    column: $table.amountReceived,
    builder: (column) => column,
  );

  GeneratedColumn<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleData,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleData, $$SalesTableReferences),
          SaleData,
          PrefetchHooks Function({bool saleItemsRefs})
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> receiptNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> subtotalAmount = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<double?> discountValue = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> vatMode = const Value.absent(),
                Value<double> vatRate = const Value.absent(),
                Value<double> vatAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<double?> amountReceived = const Value.absent(),
                Value<double?> changeAmount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                receiptNumber: receiptNumber,
                status: status,
                subtotalAmount: subtotalAmount,
                discountType: discountType,
                discountValue: discountValue,
                discountAmount: discountAmount,
                totalAmount: totalAmount,
                vatMode: vatMode,
                vatRate: vatRate,
                vatAmount: vatAmount,
                paymentMethod: paymentMethod,
                amountReceived: amountReceived,
                changeAmount: changeAmount,
                note: note,
                voidedAt: voidedAt,
                voidReason: voidReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> receiptNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> subtotalAmount = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<double?> discountValue = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                required double totalAmount,
                Value<String> vatMode = const Value.absent(),
                Value<double> vatRate = const Value.absent(),
                Value<double> vatAmount = const Value.absent(),
                required String paymentMethod,
                Value<double?> amountReceived = const Value.absent(),
                Value<double?> changeAmount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                receiptNumber: receiptNumber,
                status: status,
                subtotalAmount: subtotalAmount,
                discountType: discountType,
                discountValue: discountValue,
                discountAmount: discountAmount,
                totalAmount: totalAmount,
                vatMode: vatMode,
                vatRate: vatRate,
                vatAmount: vatAmount,
                paymentMethod: paymentMethod,
                amountReceived: amountReceived,
                changeAmount: changeAmount,
                note: note,
                voidedAt: voidedAt,
                voidReason: voidReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SalesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({saleItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleItemsRefs) db.saleItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleItemsRefs)
                    await $_getPrefetchedData<
                      SaleData,
                      $SalesTable,
                      SaleItemData
                    >(
                      currentTable: table,
                      referencedTable: $$SalesTableReferences
                          ._saleItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesTableReferences(db, table, p0).saleItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.saleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleData,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleData, $$SalesTableReferences),
      SaleData,
      PrefetchHooks Function({bool saleItemsRefs})
    >;
typedef $$SaleItemsTableCreateCompanionBuilder =
    SaleItemsCompanion Function({
      required String id,
      required String saleId,
      required String productId,
      required String productName,
      required double price,
      required int qty,
      Value<double> discountAmount,
      Value<double> vatAmount,
      required double subtotal,
      Value<int> rowid,
    });
typedef $$SaleItemsTableUpdateCompanionBuilder =
    SaleItemsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> productId,
      Value<String> productName,
      Value<double> price,
      Value<int> qty,
      Value<double> discountAmount,
      Value<double> vatAmount,
      Value<double> subtotal,
      Value<int> rowid,
    });

final class $$SaleItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemData> {
  $$SaleItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales.createAlias(
    $_aliasNameGenerator(db.saleItems.saleId, db.sales.id),
  );

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vatAmount => $composableBuilder(
    column: $table.vatAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vatAmount => $composableBuilder(
    column: $table.vatAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vatAmount =>
      $composableBuilder(column: $table.vatAmount, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTable,
          SaleItemData,
          $$SaleItemsTableFilterComposer,
          $$SaleItemsTableOrderingComposer,
          $$SaleItemsTableAnnotationComposer,
          $$SaleItemsTableCreateCompanionBuilder,
          $$SaleItemsTableUpdateCompanionBuilder,
          (SaleItemData, $$SaleItemsTableReferences),
          SaleItemData,
          PrefetchHooks Function({bool saleId})
        > {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> vatAmount = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion(
                id: id,
                saleId: saleId,
                productId: productId,
                productName: productName,
                price: price,
                qty: qty,
                discountAmount: discountAmount,
                vatAmount: vatAmount,
                subtotal: subtotal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String productId,
                required String productName,
                required double price,
                required int qty,
                Value<double> discountAmount = const Value.absent(),
                Value<double> vatAmount = const Value.absent(),
                required double subtotal,
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion.insert(
                id: id,
                saleId: saleId,
                productId: productId,
                productName: productName,
                price: price,
                qty: qty,
                discountAmount: discountAmount,
                vatAmount: vatAmount,
                subtotal: subtotal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SaleItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$SaleItemsTableReferences
                                    ._saleIdTable(db),
                                referencedColumn: $$SaleItemsTableReferences
                                    ._saleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTable,
      SaleItemData,
      $$SaleItemsTableFilterComposer,
      $$SaleItemsTableOrderingComposer,
      $$SaleItemsTableAnnotationComposer,
      $$SaleItemsTableCreateCompanionBuilder,
      $$SaleItemsTableUpdateCompanionBuilder,
      (SaleItemData, $$SaleItemsTableReferences),
      SaleItemData,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryData,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryData,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData>,
          ),
          CategoryData,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryData,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryData,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData>,
      ),
      CategoryData,
      PrefetchHooks Function()
    >;
typedef $$InventoryLogsTableCreateCompanionBuilder =
    InventoryLogsCompanion Function({
      required String id,
      required String productId,
      required String type,
      required int qtyChange,
      required int balanceAfter,
      Value<String?> reason,
      Value<String?> refSaleId,
      Value<DateTime> createdAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$InventoryLogsTableUpdateCompanionBuilder =
    InventoryLogsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> type,
      Value<int> qtyChange,
      Value<int> balanceAfter,
      Value<String?> reason,
      Value<String?> refSaleId,
      Value<DateTime> createdAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$InventoryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryLogsTable> {
  $$InventoryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyChange => $composableBuilder(
    column: $table.qtyChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refSaleId => $composableBuilder(
    column: $table.refSaleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryLogsTable> {
  $$InventoryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyChange => $composableBuilder(
    column: $table.qtyChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refSaleId => $composableBuilder(
    column: $table.refSaleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryLogsTable> {
  $$InventoryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get qtyChange =>
      $composableBuilder(column: $table.qtyChange, builder: (column) => column);

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get refSaleId =>
      $composableBuilder(column: $table.refSaleId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$InventoryLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryLogsTable,
          InventoryLogData,
          $$InventoryLogsTableFilterComposer,
          $$InventoryLogsTableOrderingComposer,
          $$InventoryLogsTableAnnotationComposer,
          $$InventoryLogsTableCreateCompanionBuilder,
          $$InventoryLogsTableUpdateCompanionBuilder,
          (
            InventoryLogData,
            BaseReferences<
              _$AppDatabase,
              $InventoryLogsTable,
              InventoryLogData
            >,
          ),
          InventoryLogData,
          PrefetchHooks Function()
        > {
  $$InventoryLogsTableTableManager(_$AppDatabase db, $InventoryLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> qtyChange = const Value.absent(),
                Value<int> balanceAfter = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> refSaleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryLogsCompanion(
                id: id,
                productId: productId,
                type: type,
                qtyChange: qtyChange,
                balanceAfter: balanceAfter,
                reason: reason,
                refSaleId: refSaleId,
                createdAt: createdAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String type,
                required int qtyChange,
                required int balanceAfter,
                Value<String?> reason = const Value.absent(),
                Value<String?> refSaleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryLogsCompanion.insert(
                id: id,
                productId: productId,
                type: type,
                qtyChange: qtyChange,
                balanceAfter: balanceAfter,
                reason: reason,
                refSaleId: refSaleId,
                createdAt: createdAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryLogsTable,
      InventoryLogData,
      $$InventoryLogsTableFilterComposer,
      $$InventoryLogsTableOrderingComposer,
      $$InventoryLogsTableAnnotationComposer,
      $$InventoryLogsTableCreateCompanionBuilder,
      $$InventoryLogsTableUpdateCompanionBuilder,
      (
        InventoryLogData,
        BaseReferences<_$AppDatabase, $InventoryLogsTable, InventoryLogData>,
      ),
      InventoryLogData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingData,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingData,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingData>,
          ),
          AppSettingData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingData,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingData,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingData>,
      ),
      AppSettingData,
      PrefetchHooks Function()
    >;
typedef $$DraftCartsTableCreateCompanionBuilder =
    DraftCartsCompanion Function({
      required String id,
      Value<String?> name,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$DraftCartsTableUpdateCompanionBuilder =
    DraftCartsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

final class $$DraftCartsTableReferences
    extends BaseReferences<_$AppDatabase, $DraftCartsTable, DraftCartData> {
  $$DraftCartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DraftCartItemsTable, List<DraftCartItemData>>
  _draftCartItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.draftCartItems,
    aliasName: $_aliasNameGenerator(db.draftCarts.id, db.draftCartItems.cartId),
  );

  $$DraftCartItemsTableProcessedTableManager get draftCartItemsRefs {
    final manager = $$DraftCartItemsTableTableManager(
      $_db,
      $_db.draftCartItems,
    ).filter((f) => f.cartId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_draftCartItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DraftCartsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftCartsTable> {
  $$DraftCartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> draftCartItemsRefs(
    Expression<bool> Function($$DraftCartItemsTableFilterComposer f) f,
  ) {
    final $$DraftCartItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draftCartItems,
      getReferencedColumn: (t) => t.cartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftCartItemsTableFilterComposer(
            $db: $db,
            $table: $db.draftCartItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DraftCartsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftCartsTable> {
  $$DraftCartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftCartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftCartsTable> {
  $$DraftCartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  Expression<T> draftCartItemsRefs<T extends Object>(
    Expression<T> Function($$DraftCartItemsTableAnnotationComposer a) f,
  ) {
    final $$DraftCartItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draftCartItems,
      getReferencedColumn: (t) => t.cartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftCartItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.draftCartItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DraftCartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftCartsTable,
          DraftCartData,
          $$DraftCartsTableFilterComposer,
          $$DraftCartsTableOrderingComposer,
          $$DraftCartsTableAnnotationComposer,
          $$DraftCartsTableCreateCompanionBuilder,
          $$DraftCartsTableUpdateCompanionBuilder,
          (DraftCartData, $$DraftCartsTableReferences),
          DraftCartData,
          PrefetchHooks Function({bool draftCartItemsRefs})
        > {
  $$DraftCartsTableTableManager(_$AppDatabase db, $DraftCartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftCartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftCartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftCartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftCartsCompanion(
                id: id,
                name: name,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftCartsCompanion.insert(
                id: id,
                name: name,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DraftCartsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({draftCartItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (draftCartItemsRefs) db.draftCartItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (draftCartItemsRefs)
                    await $_getPrefetchedData<
                      DraftCartData,
                      $DraftCartsTable,
                      DraftCartItemData
                    >(
                      currentTable: table,
                      referencedTable: $$DraftCartsTableReferences
                          ._draftCartItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DraftCartsTableReferences(
                            db,
                            table,
                            p0,
                          ).draftCartItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cartId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DraftCartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftCartsTable,
      DraftCartData,
      $$DraftCartsTableFilterComposer,
      $$DraftCartsTableOrderingComposer,
      $$DraftCartsTableAnnotationComposer,
      $$DraftCartsTableCreateCompanionBuilder,
      $$DraftCartsTableUpdateCompanionBuilder,
      (DraftCartData, $$DraftCartsTableReferences),
      DraftCartData,
      PrefetchHooks Function({bool draftCartItemsRefs})
    >;
typedef $$DraftCartItemsTableCreateCompanionBuilder =
    DraftCartItemsCompanion Function({
      required String id,
      required String cartId,
      required String productId,
      required String productName,
      required double price,
      required int qty,
      Value<String?> discountType,
      Value<double?> discountValue,
      Value<int> rowid,
    });
typedef $$DraftCartItemsTableUpdateCompanionBuilder =
    DraftCartItemsCompanion Function({
      Value<String> id,
      Value<String> cartId,
      Value<String> productId,
      Value<String> productName,
      Value<double> price,
      Value<int> qty,
      Value<String?> discountType,
      Value<double?> discountValue,
      Value<int> rowid,
    });

final class $$DraftCartItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DraftCartItemsTable, DraftCartItemData> {
  $$DraftCartItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DraftCartsTable _cartIdTable(_$AppDatabase db) =>
      db.draftCarts.createAlias(
        $_aliasNameGenerator(db.draftCartItems.cartId, db.draftCarts.id),
      );

  $$DraftCartsTableProcessedTableManager get cartId {
    final $_column = $_itemColumn<String>('cart_id')!;

    final manager = $$DraftCartsTableTableManager(
      $_db,
      $_db.draftCarts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DraftCartItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftCartItemsTable> {
  $$DraftCartItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  $$DraftCartsTableFilterComposer get cartId {
    final $$DraftCartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartId,
      referencedTable: $db.draftCarts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftCartsTableFilterComposer(
            $db: $db,
            $table: $db.draftCarts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DraftCartItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftCartItemsTable> {
  $$DraftCartItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$DraftCartsTableOrderingComposer get cartId {
    final $$DraftCartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartId,
      referencedTable: $db.draftCarts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftCartsTableOrderingComposer(
            $db: $db,
            $table: $db.draftCarts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DraftCartItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftCartItemsTable> {
  $$DraftCartItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  $$DraftCartsTableAnnotationComposer get cartId {
    final $$DraftCartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartId,
      referencedTable: $db.draftCarts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftCartsTableAnnotationComposer(
            $db: $db,
            $table: $db.draftCarts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DraftCartItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftCartItemsTable,
          DraftCartItemData,
          $$DraftCartItemsTableFilterComposer,
          $$DraftCartItemsTableOrderingComposer,
          $$DraftCartItemsTableAnnotationComposer,
          $$DraftCartItemsTableCreateCompanionBuilder,
          $$DraftCartItemsTableUpdateCompanionBuilder,
          (DraftCartItemData, $$DraftCartItemsTableReferences),
          DraftCartItemData,
          PrefetchHooks Function({bool cartId})
        > {
  $$DraftCartItemsTableTableManager(
    _$AppDatabase db,
    $DraftCartItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftCartItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftCartItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftCartItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cartId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<double?> discountValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftCartItemsCompanion(
                id: id,
                cartId: cartId,
                productId: productId,
                productName: productName,
                price: price,
                qty: qty,
                discountType: discountType,
                discountValue: discountValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cartId,
                required String productId,
                required String productName,
                required double price,
                required int qty,
                Value<String?> discountType = const Value.absent(),
                Value<double?> discountValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftCartItemsCompanion.insert(
                id: id,
                cartId: cartId,
                productId: productId,
                productName: productName,
                price: price,
                qty: qty,
                discountType: discountType,
                discountValue: discountValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DraftCartItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cartId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cartId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cartId,
                                referencedTable: $$DraftCartItemsTableReferences
                                    ._cartIdTable(db),
                                referencedColumn:
                                    $$DraftCartItemsTableReferences
                                        ._cartIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DraftCartItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftCartItemsTable,
      DraftCartItemData,
      $$DraftCartItemsTableFilterComposer,
      $$DraftCartItemsTableOrderingComposer,
      $$DraftCartItemsTableAnnotationComposer,
      $$DraftCartItemsTableCreateCompanionBuilder,
      $$DraftCartItemsTableUpdateCompanionBuilder,
      (DraftCartItemData, $$DraftCartItemsTableReferences),
      DraftCartItemData,
      PrefetchHooks Function({bool cartId})
    >;
typedef $$DailyClosesTableCreateCompanionBuilder =
    DailyClosesCompanion Function({
      required String id,
      required String closeDate,
      Value<double> openingCash,
      Value<double> expectedCash,
      Value<double> countedCash,
      Value<double> overShortAmount,
      Value<double> totalRevenue,
      Value<double> totalVoid,
      Value<int> salesCount,
      Value<int> voidCount,
      Value<String?> note,
      Value<DateTime> closedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$DailyClosesTableUpdateCompanionBuilder =
    DailyClosesCompanion Function({
      Value<String> id,
      Value<String> closeDate,
      Value<double> openingCash,
      Value<double> expectedCash,
      Value<double> countedCash,
      Value<double> overShortAmount,
      Value<double> totalRevenue,
      Value<double> totalVoid,
      Value<int> salesCount,
      Value<int> voidCount,
      Value<String?> note,
      Value<DateTime> closedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$DailyClosesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyClosesTable> {
  $$DailyClosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingCash => $composableBuilder(
    column: $table.openingCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get countedCash => $composableBuilder(
    column: $table.countedCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overShortAmount => $composableBuilder(
    column: $table.overShortAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalRevenue => $composableBuilder(
    column: $table.totalRevenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalVoid => $composableBuilder(
    column: $table.totalVoid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salesCount => $composableBuilder(
    column: $table.salesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voidCount => $composableBuilder(
    column: $table.voidCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyClosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyClosesTable> {
  $$DailyClosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingCash => $composableBuilder(
    column: $table.openingCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get countedCash => $composableBuilder(
    column: $table.countedCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overShortAmount => $composableBuilder(
    column: $table.overShortAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalRevenue => $composableBuilder(
    column: $table.totalRevenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalVoid => $composableBuilder(
    column: $table.totalVoid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salesCount => $composableBuilder(
    column: $table.salesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidCount => $composableBuilder(
    column: $table.voidCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyClosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyClosesTable> {
  $$DailyClosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get closeDate =>
      $composableBuilder(column: $table.closeDate, builder: (column) => column);

  GeneratedColumn<double> get openingCash => $composableBuilder(
    column: $table.openingCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get countedCash => $composableBuilder(
    column: $table.countedCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overShortAmount => $composableBuilder(
    column: $table.overShortAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalRevenue => $composableBuilder(
    column: $table.totalRevenue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalVoid =>
      $composableBuilder(column: $table.totalVoid, builder: (column) => column);

  GeneratedColumn<int> get salesCount => $composableBuilder(
    column: $table.salesCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get voidCount =>
      $composableBuilder(column: $table.voidCount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$DailyClosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyClosesTable,
          DailyCloseData,
          $$DailyClosesTableFilterComposer,
          $$DailyClosesTableOrderingComposer,
          $$DailyClosesTableAnnotationComposer,
          $$DailyClosesTableCreateCompanionBuilder,
          $$DailyClosesTableUpdateCompanionBuilder,
          (
            DailyCloseData,
            BaseReferences<_$AppDatabase, $DailyClosesTable, DailyCloseData>,
          ),
          DailyCloseData,
          PrefetchHooks Function()
        > {
  $$DailyClosesTableTableManager(_$AppDatabase db, $DailyClosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyClosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyClosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyClosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> closeDate = const Value.absent(),
                Value<double> openingCash = const Value.absent(),
                Value<double> expectedCash = const Value.absent(),
                Value<double> countedCash = const Value.absent(),
                Value<double> overShortAmount = const Value.absent(),
                Value<double> totalRevenue = const Value.absent(),
                Value<double> totalVoid = const Value.absent(),
                Value<int> salesCount = const Value.absent(),
                Value<int> voidCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyClosesCompanion(
                id: id,
                closeDate: closeDate,
                openingCash: openingCash,
                expectedCash: expectedCash,
                countedCash: countedCash,
                overShortAmount: overShortAmount,
                totalRevenue: totalRevenue,
                totalVoid: totalVoid,
                salesCount: salesCount,
                voidCount: voidCount,
                note: note,
                closedAt: closedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String closeDate,
                Value<double> openingCash = const Value.absent(),
                Value<double> expectedCash = const Value.absent(),
                Value<double> countedCash = const Value.absent(),
                Value<double> overShortAmount = const Value.absent(),
                Value<double> totalRevenue = const Value.absent(),
                Value<double> totalVoid = const Value.absent(),
                Value<int> salesCount = const Value.absent(),
                Value<int> voidCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyClosesCompanion.insert(
                id: id,
                closeDate: closeDate,
                openingCash: openingCash,
                expectedCash: expectedCash,
                countedCash: countedCash,
                overShortAmount: overShortAmount,
                totalRevenue: totalRevenue,
                totalVoid: totalVoid,
                salesCount: salesCount,
                voidCount: voidCount,
                note: note,
                closedAt: closedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyClosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyClosesTable,
      DailyCloseData,
      $$DailyClosesTableFilterComposer,
      $$DailyClosesTableOrderingComposer,
      $$DailyClosesTableAnnotationComposer,
      $$DailyClosesTableCreateCompanionBuilder,
      $$DailyClosesTableUpdateCompanionBuilder,
      (
        DailyCloseData,
        BaseReferences<_$AppDatabase, $DailyClosesTable, DailyCloseData>,
      ),
      DailyCloseData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$InventoryLogsTableTableManager get inventoryLogs =>
      $$InventoryLogsTableTableManager(_db, _db.inventoryLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DraftCartsTableTableManager get draftCarts =>
      $$DraftCartsTableTableManager(_db, _db.draftCarts);
  $$DraftCartItemsTableTableManager get draftCartItems =>
      $$DraftCartItemsTableTableManager(_db, _db.draftCartItems);
  $$DailyClosesTableTableManager get dailyCloses =>
      $$DailyClosesTableTableManager(_db, _db.dailyCloses);
}

class CsvProductRow {
  const CsvProductRow({
    required this.sourceRow,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.cost,
    this.stock = 0,
    this.categoryName,
    this.trackStock = true,
  });

  final int sourceRow;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double? cost;
  final int stock;
  final String? categoryName;
  final bool trackStock;
}

class CsvImportRowError {
  const CsvImportRowError({required this.sourceRow, required this.message});

  final int sourceRow;
  final String message;
}

class CsvImportResult {
  const CsvImportResult({
    required this.rows,
    this.rowErrors = const [],
    this.error,
  });

  final List<CsvProductRow> rows;
  final List<CsvImportRowError> rowErrors;
  final String? error;

  bool get isValid => error == null && rows.isNotEmpty;
}

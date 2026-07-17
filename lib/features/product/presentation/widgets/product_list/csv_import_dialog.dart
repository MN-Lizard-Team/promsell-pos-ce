/// Compatibility shim — CSV import is a full page.
///
/// Prefer [openProductCsvImport] from `product_csv_import_page.dart`.
library;

export 'package:promsell_pos_ce/features/product/presentation/pages/product_csv_import_page.dart'
    show
        openProductCsvImport,
        showCsvImportDialog,
        kCsvImportMaxBytes,
        kCsvImportMaxDataRows,
        kCsvImportMaxMb,
        kCsvProductTemplateContent,
        ProductCsvImportPage;

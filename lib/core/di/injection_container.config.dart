// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:promsell_pos_ce/core/database/app_database.dart' as _i422;
import 'package:promsell_pos_ce/core/di/bloc_module.dart' as _i1055;
import 'package:promsell_pos_ce/core/di/database_module.dart' as _i205;
import 'package:promsell_pos_ce/core/di/image_picker_module.dart' as _i714;
import 'package:promsell_pos_ce/core/image/image_cache_service.dart' as _i710;
import 'package:promsell_pos_ce/core/services/crash_log_service.dart' as _i686;
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart'
    as _i622;
import 'package:promsell_pos_ce/features/daily_close/data/repositories/daily_close_repository_impl.dart'
    as _i725;
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart'
    as _i819;
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart'
    as _i320;
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart'
    as _i696;
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_list.dart'
    as _i351;
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/reopen_day.dart'
    as _i858;
import 'package:promsell_pos_ce/features/daily_close/presentation/cubit/daily_close_cubit.dart'
    as _i983;
import 'package:promsell_pos_ce/features/history/data/repositories/history_repository_impl.dart'
    as _i190;
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart'
    as _i26;
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart'
    as _i426;
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart'
    as _i41;
import 'package:promsell_pos_ce/features/inventory/data/repositories/inventory_log_repository_impl.dart'
    as _i400;
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart'
    as _i216;
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_log_repository.dart'
    as _i551;
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart'
    as _i935;
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart'
    as _i1073;
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_cubit.dart'
    as _i21;
import 'package:promsell_pos_ce/features/product/data/datasources/category_local_datasource.dart'
    as _i487;
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart'
    as _i409;
import 'package:promsell_pos_ce/features/product/data/repositories/category_repository_impl.dart'
    as _i721;
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart'
    as _i23;
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart'
    as _i502;
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart'
    as _i1059;
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart'
    as _i126;
import 'package:promsell_pos_ce/features/product/domain/usecases/add_category.dart'
    as _i982;
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart'
    as _i747;
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart'
    as _i475;
import 'package:promsell_pos_ce/features/product/domain/usecases/clear_orphaned_images.dart'
    as _i707;
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_category.dart'
    as _i910;
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart'
    as _i447;
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart'
    as _i10;
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart'
    as _i440;
import 'package:promsell_pos_ce/features/product/domain/usecases/reorder_categories.dart'
    as _i752;
import 'package:promsell_pos_ce/features/product/domain/usecases/update_category.dart'
    as _i661;
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart'
    as _i107;
import 'package:promsell_pos_ce/features/product/domain/usecases/watch_categories.dart'
    as _i10;
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart'
    as _i613;
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart'
    as _i372;
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart'
    as _i734;
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart'
    as _i744;
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart'
    as _i593;
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart'
    as _i925;
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart'
    as _i942;
import 'package:promsell_pos_ce/features/sale/data/repositories/draft_cart_repository_impl.dart'
    as _i1037;
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart'
    as _i679;
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart'
    as _i790;
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart'
    as _i564;
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart'
    as _i771;
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart'
    as _i648;
import 'package:promsell_pos_ce/features/sale/domain/usecases/get_sale_by_id.dart'
    as _i444;
import 'package:promsell_pos_ce/features/sale/domain/usecases/get_sales.dart'
    as _i705;
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart'
    as _i233;
import 'package:promsell_pos_ce/features/sale/domain/usecases/watch_recent_sales.dart'
    as _i192;
import 'package:promsell_pos_ce/features/sale/domain/usecases/watch_sales.dart'
    as _i594;
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart'
    as _i401;
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart'
    as _i1038;
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart'
    as _i67;
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart'
    as _i440;
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart'
    as _i173;
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart'
    as _i288;
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart'
    as _i243;
import 'package:promsell_pos_ce/features/settings/domain/usecases/get_settings.dart'
    as _i83;
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_setting_group.dart'
    as _i669;
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_settings.dart'
    as _i261;
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart'
    as _i425;
import 'package:promsell_pos_ce/features/settings/presentation/services/settings_persistence_service.dart'
    as _i307;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    final imagePickerModule = _$ImagePickerModule();
    final blocModule = _$BlocModule();
    gh.lazySingleton<_i422.AppDatabase>(() => databaseModule.appDatabase);
    gh.lazySingleton<_i183.ImagePicker>(() => imagePickerModule.imagePicker);
    gh.lazySingleton<_i710.ImageCacheService>(() => _i710.ImageCacheService());
    gh.lazySingleton<_i686.CrashLogService>(() => _i686.CrashLogService());
    gh.lazySingleton<_i734.ReceiptPdfService>(() => _i734.ReceiptPdfService());
    gh.lazySingleton<_i288.BackupEncryptionService>(
      () => _i288.BackupEncryptionService(),
    );
    gh.lazySingleton<_i409.ProductLocalDatasource>(
      () => _i409.ProductLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i440.SettingsLocalDatasource>(
      () => _i440.SettingsLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i41.InventoryLogLocalDatasource>(
      () => _i41.InventoryLogLocalDatasource(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i790.ReceiptNumberService>(
      () => _i790.ReceiptNumberService(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i487.CategoryLocalDatasource>(
      () => _i487.CategoryLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i622.DailyCloseLocalDatasource>(
      () => _i622.DailyCloseLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i819.DailyCloseRepository>(
      () =>
          _i725.DailyCloseRepositoryImpl(gh<_i622.DailyCloseLocalDatasource>()),
    );
    gh.lazySingleton<_i551.InventoryLogRepository>(
      () => _i400.InventoryLogRepositoryImpl(
        gh<_i41.InventoryLogLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i243.SettingsRepository>(
      () => _i173.SettingsRepositoryImpl(gh<_i440.SettingsLocalDatasource>()),
    );
    gh.lazySingleton<_i1059.CategoryRepository>(
      () => _i721.CategoryRepositoryImpl(gh<_i487.CategoryLocalDatasource>()),
    );
    gh.factory<_i83.GetSettings>(
      () => _i83.GetSettings(gh<_i243.SettingsRepository>()),
    );
    gh.factory<_i669.UpdateSettingGroup>(
      () => _i669.UpdateSettingGroup(gh<_i243.SettingsRepository>()),
    );
    gh.factory<_i261.UpdateSettings>(
      () => _i261.UpdateSettings(gh<_i243.SettingsRepository>()),
    );
    gh.factory<_i307.SettingsPersistenceService>(
      () => _i307.SettingsPersistenceService(gh<_i243.SettingsRepository>()),
    );
    gh.factory<_i696.GetDailyCloseByDate>(
      () => _i696.GetDailyCloseByDate(gh<_i819.DailyCloseRepository>()),
    );
    gh.factory<_i351.GetDailyCloseList>(
      () => _i351.GetDailyCloseList(gh<_i819.DailyCloseRepository>()),
    );
    gh.factory<_i858.ReopenDay>(
      () => _i858.ReopenDay(gh<_i819.DailyCloseRepository>()),
    );
    gh.factory<_i982.AddCategory>(
      () => _i982.AddCategory(gh<_i1059.CategoryRepository>()),
    );
    gh.factory<_i661.UpdateCategory>(
      () => _i661.UpdateCategory(gh<_i1059.CategoryRepository>()),
    );
    gh.factory<_i10.WatchCategories>(
      () => _i10.WatchCategories(gh<_i1059.CategoryRepository>()),
    );
    gh.factory<_i1073.WatchInventoryLogs>(
      () => _i1073.WatchInventoryLogs(gh<_i551.InventoryLogRepository>()),
    );
    gh.lazySingleton<_i502.ProductImageService>(
      () => _i502.ProductImageServiceImpl(
        gh<_i243.SettingsRepository>(),
        picker: gh<_i183.ImagePicker>(),
        cacheService: gh<_i710.ImageCacheService>(),
      ),
    );
    gh.lazySingleton<_i126.ProductRepository>(
      () => _i23.ProductRepositoryImpl(
        gh<_i409.ProductLocalDatasource>(),
        gh<_i502.ProductImageService>(),
      ),
    );
    gh.lazySingleton<_i925.DraftCartLocalDatasource>(
      () => _i925.DraftCartLocalDatasourceImpl(
        gh<_i422.AppDatabase>(),
        settingsRepo: gh<_i243.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i564.DraftCartRepository>(
      () =>
          _i1037.DraftCartRepositoryImpl(gh<_i925.DraftCartLocalDatasource>()),
    );
    gh.lazySingleton<_i216.InventoryLogService>(
      () => _i216.InventoryLogService(
        gh<_i422.AppDatabase>(),
        settingsRepo: gh<_i243.SettingsRepository>(),
      ),
    );
    gh.factory<_i752.ReorderCategories>(
      () => _i752.ReorderCategories(gh<_i1059.CategoryRepository>()),
    );
    gh.lazySingleton<_i67.DraftBloc>(
      () => _i67.DraftBloc(
        draftRepo: gh<_i564.DraftCartRepository>(),
        settingsRepo: gh<_i243.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i425.SettingsCubit>(
      () => _i425.SettingsCubit(
        gh<_i243.SettingsRepository>(),
        gh<_i307.SettingsPersistenceService>(),
      ),
    );
    gh.factory<_i910.DeleteCategory>(
      () => _i910.DeleteCategory(
        gh<_i1059.CategoryRepository>(),
        gh<_i126.ProductRepository>(),
      ),
    );
    gh.factory<_i747.AddProduct>(
      () => _i747.AddProduct(gh<_i126.ProductRepository>()),
    );
    gh.factory<_i447.DeleteProduct>(
      () => _i447.DeleteProduct(gh<_i126.ProductRepository>()),
    );
    gh.factory<_i440.GetProducts>(
      () => _i440.GetProducts(gh<_i126.ProductRepository>()),
    );
    gh.factory<_i107.UpdateProduct>(
      () => _i107.UpdateProduct(gh<_i126.ProductRepository>()),
    );
    gh.lazySingleton<_i401.CartBloc>(
      () => _i401.CartBloc(
        productRepo: gh<_i126.ProductRepository>(),
        settingsRepo: gh<_i243.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i942.SaleLocalDatasource>(
      () => _i942.SaleLocalDatasourceImpl(
        gh<_i422.AppDatabase>(),
        receiptNumberService: gh<_i790.ReceiptNumberService>(),
        inventoryLogService: gh<_i216.InventoryLogService>(),
        settingsRepo: gh<_i243.SettingsRepository>(),
      ),
    );
    gh.factory<_i10.GenerateBarcode>(
      () => _i10.GenerateBarcode(
        gh<_i126.ProductRepository>(),
        gh<_i243.SettingsRepository>(),
      ),
    );
    gh.factory<_i707.ClearOrphanedImages>(
      () => _i707.ClearOrphanedImages(
        gh<_i126.ProductRepository>(),
        gh<_i502.ProductImageService>(),
      ),
    );
    gh.factory<_i475.BatchGenerateBarcodes>(
      () => _i475.BatchGenerateBarcodes(
        gh<_i126.ProductRepository>(),
        gh<_i243.SettingsRepository>(),
      ),
    );
    gh.factory<_i21.InventoryLogCubit>(
      () => _i21.InventoryLogCubit(
        watchInventoryLogs: gh<_i1073.WatchInventoryLogs>(),
      ),
    );
    gh.factory<_i935.AdjustStock>(
      () => _i935.AdjustStock(
        gh<_i422.AppDatabase>(),
        gh<_i216.InventoryLogService>(),
      ),
    );
    gh.lazySingleton<_i372.ProductBloc>(
      () => blocModule.productBloc(
        gh<_i440.GetProducts>(),
        gh<_i747.AddProduct>(),
        gh<_i107.UpdateProduct>(),
        gh<_i447.DeleteProduct>(),
        gh<_i475.BatchGenerateBarcodes>(),
      ),
    );
    gh.lazySingleton<_i26.HistoryRepository>(
      () => _i190.HistoryRepositoryImpl(gh<_i942.SaleLocalDatasource>()),
    );
    gh.factory<_i320.CloseDay>(
      () => _i320.CloseDay(
        gh<_i819.DailyCloseRepository>(),
        gh<_i942.SaleLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i613.CategoryBloc>(
      () => _i613.CategoryBloc(
        watchCategories: gh<_i10.WatchCategories>(),
        addCategory: gh<_i982.AddCategory>(),
        updateCategory: gh<_i661.UpdateCategory>(),
        deleteCategory: gh<_i910.DeleteCategory>(),
        reorderCategories: gh<_i752.ReorderCategories>(),
      ),
    );
    gh.lazySingleton<_i771.SaleRepository>(
      () => _i679.SaleRepositoryImpl(gh<_i942.SaleLocalDatasource>()),
    );
    gh.factory<_i983.DailyCloseCubit>(
      () => _i983.DailyCloseCubit(
        gh<_i320.CloseDay>(),
        gh<_i858.ReopenDay>(),
        gh<_i696.GetDailyCloseByDate>(),
        gh<_i243.SettingsRepository>(),
      ),
    );
    gh.factory<_i744.WatchReport>(
      () => _i744.WatchReport(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i648.CreateSale>(
      () => _i648.CreateSale(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i444.GetSaleById>(
      () => _i444.GetSaleById(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i705.GetSales>(
      () => _i705.GetSales(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i233.VoidSale>(
      () => _i233.VoidSale(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i192.WatchRecentSales>(
      () => _i192.WatchRecentSales(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i594.WatchSales>(
      () => _i594.WatchSales(gh<_i771.SaleRepository>()),
    );
    gh.lazySingleton<_i593.ReportCubit>(
      () => _i593.ReportCubit(watchReport: gh<_i744.WatchReport>()),
    );
    gh.factory<_i426.WatchSaleHistory>(
      () => _i426.WatchSaleHistory(gh<_i26.HistoryRepository>()),
    );
    gh.lazySingleton<_i1038.CheckoutBloc>(
      () => _i1038.CheckoutBloc(
        createSale: gh<_i648.CreateSale>(),
        cartBloc: gh<_i401.CartBloc>(),
        draftBloc: gh<_i67.DraftBloc>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i205.DatabaseModule {}

class _$ImagePickerModule extends _i714.ImagePickerModule {}

class _$BlocModule extends _i1055.BlocModule {}

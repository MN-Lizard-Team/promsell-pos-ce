// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:promsell_pos_ce/core/database/app_database.dart' as _i422;
import 'package:promsell_pos_ce/core/di/bloc_module.dart' as _i1055;
import 'package:promsell_pos_ce/core/di/database_module.dart' as _i205;
import 'package:promsell_pos_ce/core/services/receipt_pdf_service.dart'
    as _i808;
import 'package:promsell_pos_ce/features/history/data/repositories/history_repository_impl.dart'
    as _i190;
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart'
    as _i26;
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart'
    as _i426;
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart'
    as _i216;
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart'
    as _i935;
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart'
    as _i409;
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart'
    as _i23;
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart'
    as _i502;
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart'
    as _i126;
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart'
    as _i747;
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart'
    as _i447;
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart'
    as _i440;
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart'
    as _i107;
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart'
    as _i372;
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
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart'
    as _i233;
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart'
    as _i648;
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart'
    as _i440;
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart'
    as _i173;
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart'
    as _i243;
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart'
    as _i425;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    final blocModule = _$BlocModule();
    gh.lazySingleton<_i422.AppDatabase>(() => databaseModule.appDatabase);
    gh.lazySingleton<_i808.ReceiptPdfService>(() => _i808.ReceiptPdfService());
    gh.lazySingleton<_i502.ProductImageService>(
      () => _i502.ProductImageServiceImpl(),
    );
    gh.lazySingleton<_i409.ProductLocalDatasource>(
      () => _i409.ProductLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i925.DraftCartLocalDatasource>(
      () => _i925.DraftCartLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i440.SettingsLocalDatasource>(
      () => _i440.SettingsLocalDatasourceImpl(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i216.InventoryLogService>(
      () => _i216.InventoryLogService(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i790.ReceiptNumberService>(
      () => _i790.ReceiptNumberService(gh<_i422.AppDatabase>()),
    );
    gh.lazySingleton<_i126.ProductRepository>(
      () => _i23.ProductRepositoryImpl(gh<_i409.ProductLocalDatasource>()),
    );
    gh.lazySingleton<_i942.SaleLocalDatasource>(
      () => _i942.SaleLocalDatasourceImpl(
        gh<_i422.AppDatabase>(),
        receiptNumberService: gh<_i790.ReceiptNumberService>(),
        inventoryLogService: gh<_i216.InventoryLogService>(),
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
    gh.lazySingleton<_i372.ProductBloc>(
      () => blocModule.productBloc(
        gh<_i440.GetProducts>(),
        gh<_i747.AddProduct>(),
        gh<_i107.UpdateProduct>(),
        gh<_i447.DeleteProduct>(),
      ),
    );
    gh.factory<_i935.AdjustStock>(
      () => _i935.AdjustStock(
        gh<_i422.AppDatabase>(),
        gh<_i216.InventoryLogService>(),
      ),
    );
    gh.lazySingleton<_i564.DraftCartRepository>(
      () =>
          _i1037.DraftCartRepositoryImpl(gh<_i925.DraftCartLocalDatasource>()),
    );
    gh.lazySingleton<_i243.SettingsRepository>(
      () => _i173.SettingsRepositoryImpl(gh<_i440.SettingsLocalDatasource>()),
    );
    gh.lazySingleton<_i26.HistoryRepository>(
      () => _i190.HistoryRepositoryImpl(gh<_i942.SaleLocalDatasource>()),
    );
    gh.lazySingleton<_i771.SaleRepository>(
      () => _i679.SaleRepositoryImpl(gh<_i942.SaleLocalDatasource>()),
    );
    gh.lazySingleton<_i425.SettingsCubit>(
      () => _i425.SettingsCubit(gh<_i243.SettingsRepository>()),
    );
    gh.factory<_i744.WatchReport>(
      () => _i744.WatchReport(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i648.CreateSale>(
      () => _i648.CreateSale(gh<_i771.SaleRepository>()),
    );
    gh.factory<_i233.VoidSale>(
      () => _i233.VoidSale(gh<_i771.SaleRepository>()),
    );
    gh.lazySingleton<_i593.ReportCubit>(
      () => _i593.ReportCubit(watchReport: gh<_i744.WatchReport>()),
    );
    gh.factory<_i426.WatchSaleHistory>(
      () => _i426.WatchSaleHistory(gh<_i26.HistoryRepository>()),
    );
    gh.factory<_i648.SaleBloc>(
      () => _i648.SaleBloc(
        createSale: gh<_i648.CreateSale>(),
        draftRepo: gh<_i564.DraftCartRepository>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i205.DatabaseModule {}

class _$BlocModule extends _i1055.BlocModule {}

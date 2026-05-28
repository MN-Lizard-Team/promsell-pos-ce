import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/history/data/repositories/history_repository_impl.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/core/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database — skip if already registered (e.g. in tests with in-memory DB).
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerSingleton<AppDatabase>(AppDatabase());
  }

  // Datasource's
  sl.registerLazySingleton<ProductLocalDatasource>(
    () => ProductLocalDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<ReceiptNumberService>(
    () => ReceiptNumberService(sl()),
  );
  sl.registerLazySingleton<InventoryLogService>(
    () => InventoryLogService(sl()),
  );
  sl.registerLazySingleton<SaleLocalDatasource>(
    () => SaleLocalDatasourceImpl(
      sl(),
      receiptNumberService: sl(),
      inventoryLogService: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsLocalDatasource>(
    () => SettingsLocalDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SaleRepository>(() => SaleRepositoryImpl(sl()));
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );

  // Use Cases — Product
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // Use Cases — Sale
  sl.registerLazySingleton(() => CreateSale(sl()));
  sl.registerLazySingleton(() => VoidSale(sl()));

  // Use Cases — Inventory
  sl.registerLazySingleton(() => AdjustStock(sl(), sl()));

  // Use Cases — History
  sl.registerLazySingleton(() => WatchSaleHistory(sl()));

  // Use Cases — Report
  sl.registerLazySingleton(() => WatchReport(sl()));

  // Services
  sl.registerLazySingleton<ReceiptPdfService>(() => ReceiptPdfService());

  // Cubits — Report (factory: each tab navigation creates a fresh cubit)
  sl.registerFactory<ReportCubit>(() => ReportCubit(watchReport: sl()));

  // BLoCs — ProductBloc is a singleton intentionally: shared across Sale and
  // Product pages via IndexedStack so all tabs see the same product list.
  sl.registerLazySingleton<ProductBloc>(
    () => ProductBloc(
      getProducts: sl(),
      addProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
    )..add(const ProductsSubscribed()),
  );

  // Settings
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl()));
}

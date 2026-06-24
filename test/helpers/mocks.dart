import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/get_sale_history.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/get_report.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_log_repository.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_cubit.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';

// ── Repositories ──
class MockSaleRepository extends Mock implements SaleRepository {}

class MockDraftCartRepository extends Mock implements DraftCartRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// ── Datasources ──
class MockSaleLocalDatasource extends Mock implements SaleLocalDatasource {}

class MockProductLocalDatasource extends Mock
    implements ProductLocalDatasource {}

class MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

// ── Use Cases ──
class MockCreateSale extends Mock implements CreateSale {}

class MockVoidSale extends Mock implements VoidSale {}

class MockAddProduct extends Mock implements AddProduct {}

class MockUpdateProduct extends Mock implements UpdateProduct {}

class MockDeleteProduct extends Mock implements DeleteProduct {}

class MockBatchGenerateBarcodes extends Mock implements BatchGenerateBarcodes {}

class MockGetProducts extends Mock implements GetProducts {}

class MockGetSaleHistory extends Mock implements GetSaleHistory {}

class MockWatchSaleHistory extends Mock implements WatchSaleHistory {}

class MockGetReport extends Mock implements GetReport {}

class MockWatchReport extends Mock implements WatchReport {}

// ── BLoCs / Cubits (for widget tests) ──
class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class MockCheckoutBloc extends MockBloc<CheckoutEvent, CheckoutState>
    implements CheckoutBloc {}

class MockDraftBloc extends MockBloc<DraftEvent, DraftState>
    implements DraftBloc {}

class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockHistoryBloc extends MockBloc<HistoryEvent, HistoryState>
    implements HistoryBloc {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockReportCubit extends MockCubit<ReportState> implements ReportCubit {}

// ── Inventory ──
class MockInventoryLogRepository extends Mock
    implements InventoryLogRepository {}

class MockWatchInventoryLogs extends Mock implements WatchInventoryLogs {}

class MockInventoryLogCubit extends MockCubit<InventoryLogState>
    implements InventoryLogCubit {}

class MockSearchHistoryCubit extends MockCubit<SearchHistoryState>
    implements SearchHistoryCubit {}

// ── Services ──
class MockProductImageService extends Mock implements ProductImageService {}

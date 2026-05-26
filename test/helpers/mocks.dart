import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/get_sale_history.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/get_report.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

// ── Repositories ──
class MockSaleRepository extends Mock implements SaleRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// ── Datasources ──
class MockSaleLocalDatasource extends Mock implements SaleLocalDatasource {}

class MockProductLocalDatasource extends Mock
    implements ProductLocalDatasource {}

// ── Use Cases ──
class MockCreateSale extends Mock implements CreateSale {}

class MockAddProduct extends Mock implements AddProduct {}

class MockUpdateProduct extends Mock implements UpdateProduct {}

class MockDeleteProduct extends Mock implements DeleteProduct {}

class MockGetProducts extends Mock implements GetProducts {}

class MockGetSaleHistory extends Mock implements GetSaleHistory {}

class MockWatchSaleHistory extends Mock implements WatchSaleHistory {}

class MockGetReport extends Mock implements GetReport {}

class MockWatchReport extends Mock implements WatchReport {}

// ── BLoCs / Cubits (for widget tests) ──
class MockSaleBloc extends MockBloc<SaleEvent, SaleState> implements SaleBloc {}

class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockHistoryBloc extends MockBloc<HistoryEvent, HistoryState>
    implements HistoryBloc {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockReportCubit extends MockCubit<ReportState> implements ReportCubit {}

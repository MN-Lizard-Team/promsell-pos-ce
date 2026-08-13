import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/restore_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/import_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';

@module
abstract class BlocModule {
  @lazySingleton
  ProductBloc productBloc(
    GetProducts getProducts,
    GetProductCount getProductCount,
    AddProduct addProduct,
    UpdateProduct updateProduct,
    DeleteProduct deleteProduct,
    RestoreProduct restoreProduct,
    BatchGenerateBarcodes batchGenerateBarcodes,
    ImportProducts importProducts,
  ) => ProductBloc(
    getProducts: getProducts,
    getProductCount: getProductCount,
    addProduct: addProduct,
    updateProduct: updateProduct,
    deleteProduct: deleteProduct,
    restoreProduct: restoreProduct,
    batchGenerateBarcodes: batchGenerateBarcodes,
    importProducts: importProducts,
  )..add(const ProductsSubscribed());
}

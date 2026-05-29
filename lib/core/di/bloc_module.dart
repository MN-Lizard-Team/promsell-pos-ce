import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';

@module
abstract class BlocModule {
  @lazySingleton
  ProductBloc productBloc(
    GetProducts getProducts,
    AddProduct addProduct,
    UpdateProduct updateProduct,
    DeleteProduct deleteProduct,
  ) => ProductBloc(
    getProducts: getProducts,
    addProduct: addProduct,
    updateProduct: updateProduct,
    deleteProduct: deleteProduct,
  )..add(const ProductsSubscribed());
}

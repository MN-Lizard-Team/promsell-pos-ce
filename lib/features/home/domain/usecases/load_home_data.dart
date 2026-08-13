import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/home/domain/entities/home_data.dart';
import 'package:promsell_pos_ce/features/home/domain/repositories/home_repository.dart';

@injectable
class LoadHomeData {
  const LoadHomeData(this._repository);
  final HomeRepository _repository;

  Future<HomeData> call() => _repository.loadHomeData();
}

import 'package:promsell_pos_ce/features/home/domain/entities/home_data.dart';

abstract class HomeRepository {
  Future<HomeData> loadHomeData();
}

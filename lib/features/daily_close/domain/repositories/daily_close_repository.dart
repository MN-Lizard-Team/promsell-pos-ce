import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';

abstract class DailyCloseRepository {
  Future<DailyClose?> getByDate(String date);
  Future<List<DailyClose>> getAll();
  Future<DailyClose> save(DailyClose close);
  Future<void> delete(String id);
}

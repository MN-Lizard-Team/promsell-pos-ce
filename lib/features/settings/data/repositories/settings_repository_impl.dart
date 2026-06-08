import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._datasource);

  final SettingsLocalDatasource _datasource;
  final SettingsMapper _mapper = SettingsMapper();

  @override
  Future<Settings> load() async {
    final map = await _datasource.getAll();
    return _mapper.fromMap(map);
  }

  @override
  Future<void> save(Settings settings) async {
    final map = _mapper.toMap(settings);
    for (final entry in map.entries) {
      await _datasource.setString(entry.key, entry.value);
    }
  }
}

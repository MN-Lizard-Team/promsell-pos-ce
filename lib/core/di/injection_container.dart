import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/di/injection_container.config.dart';

final sl = GetIt.instance;

@module
abstract class CoreModule {
  @Named('settingsLoadTimeout')
  Duration get settingsLoadTimeout => const Duration(seconds: 12);
}

@InjectableInit()
void configureDependencies([String? env]) {
  sl.init(environment: env);
}

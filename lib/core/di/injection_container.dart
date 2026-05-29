import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/di/injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit()
void configureDependencies([String? env]) {
  sl.init(environment: env);
}

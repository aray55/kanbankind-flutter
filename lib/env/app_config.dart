import 'package:envied/envied.dart';
import 'package:kanbankit/core/enums/app_flavor.dart';
part  'app_config.g.dart';
@Envied(path: '.env.dev')
abstract class DevConfig {
  @EnviedField(varName: 'DEBUG')
  static bool debug = _DevConfig.debug;
  @EnviedField(varName: 'APP_VERSION')
  static String appVersion = _DevConfig.appVersion;
  @EnviedField(varName: 'APP_NAME')
  static String appName = _DevConfig.appName;
  @EnviedField(varName: 'APP_DESCRIPTION')
  static String appDescription = _DevConfig.appDescription;
}
class AppConfig {
  static AppFlavor _flavor = AppFlavor.dev;

  static void setFlavor(AppFlavor flavor) {
    _flavor = flavor;
  }

  static AppFlavor getFlavor() {
    return _flavor;
  }
static String get flavorName {
  switch (_flavor) {
    case AppFlavor.dev:
      return 'dev';
    case AppFlavor.staging:
      return 'staging';
    case AppFlavor.prod:
      return 'prod';
  }
  
}
  static bool get debug{
    switch (_flavor) {
      case AppFlavor.dev:
        return false;
      case AppFlavor.staging:
        return false;
      case AppFlavor.prod:
        return false;
    }
    
  }
  static bool get isProduction => _flavor == AppFlavor.prod;
  static bool get isDevelopment => _flavor == AppFlavor.dev;
  static bool get isStaging => _flavor == AppFlavor.staging;

}
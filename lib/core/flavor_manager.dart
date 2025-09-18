import 'package:kanbankit/core/enums/app_flavor.dart';

import '../env/app_config.dart';

class FlavorManager {
  static void initializeFlavor() {
    // Get flavor from dart-define or default to dev
    const String? flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    
    AppFlavor flavor;
    switch (flavorString.toLowerCase()) {
      case 'staging':
        flavor = AppFlavor.staging;
        break;
      case 'prod':
      case 'production':
        flavor = AppFlavor.prod;
        break;
      case 'dev':
      case 'development':
      default:
        flavor = AppFlavor.dev;
        break;
    }
    
    AppConfig.setFlavor(flavor);
  }
}
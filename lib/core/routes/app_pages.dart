import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../bindings/board_binding.dart' show BoardBinding;
import '../../views/board/board_page.dart' show BoardPage;
import '../../views/task_details/task_details_page.dart' show TaskDetailsPage;
import '../../views/onboarding/onboarding_screen.dart' show OnboardingScreen;
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: AppRoutes.board,
      page: () => const BoardPage(),
      binding: BoardBinding(),
    ),
    GetPage(name: AppRoutes.taskDetails, page: () => const TaskDetailsPage()),
  ];
}

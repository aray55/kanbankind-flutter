import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:kanbankit/views/boards/boards_screen.dart';

import '../../bindings/board_binding.dart';
import '../../bindings/task_binding.dart';
import '../../views/board/task_page.dart';
import '../../views/task_details/task_details_page.dart' show TaskDetailsPage;
import '../../views/onboarding/onboarding_screen.dart' show OnboardingScreen;
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: AppRoutes.boards,
      page: () => const BoardsScreen(),
      binding: BoardBinding(),
    ),
    GetPage(
      name: AppRoutes.task,
      page: () => const TaskPage(),
      binding: TaskBinding(),
    ),
    GetPage(name: AppRoutes.taskDetails, page: () => const TaskDetailsPage()),
  ];
}

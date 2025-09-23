import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:kanbankit/views/boards/boards_screen.dart';
import 'package:kanbankit/views/lists/board_lists_route_screen.dart';

import '../../bindings/board_binding.dart';
import '../../bindings/list_binding.dart';
import '../../bindings/card_binding.dart'; // Add this import
// import '../../views/task_details/task_details_page.dart' show TaskDetailsPage;
import '../../views/onboarding/onboarding_screen.dart' show OnboardingScreen;
import '../../views/widgets/cards/card_list_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: AppRoutes.boards,
      page: () => const BoardsScreen(),
      binding: BoardBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.task,
    //   page: () => const TaskPage(),
    //   binding: TaskBinding(),
    // ),
    // GetPage(name: AppRoutes.taskDetails, page: () => const TaskDetailsPage()),
    GetPage(
      name: AppRoutes.listScreen,
      page: () => const BoardListsRouteScreen(),
      binding: ListBinding(),
    ),
    GetPage(
      name: AppRoutes.cardDemo, // Add this page
      page: () => const CardListView(cards: []),
      binding: CardBinding(), // Use CardBinding instead of ListBinding
    ),
  ];
}

import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../bindings/board_binding.dart' show BoardBinding;
import '../../views/board/board_page.dart' show BoardPage;
import 'app_routes.dart';


class AppPages {
  static final pages=<GetPage>[
    GetPage(
      name: AppRoutes.board,
      page: () => const BoardPage(),
      binding: BoardBinding(),
    ),
  ];
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/board_controller.dart';
import 'board_lists_screen.dart';
import '../components/state_widgets.dart';

class BoardListsRouteScreen extends StatelessWidget {
  const BoardListsRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get board ID from route parameters
    final boardId = Get.parameters['boardId'];
    
    if (boardId == null) {
      return const Scaffold(
        body: ErrorView(
          message: 'Board ID is required',
        ),
      );
    }

    final boardController = Get.find<BoardController>();
    
    return Obx(() {
      // Find the board by ID
      final board = boardController.getBoardById(int.parse(boardId));
      
      if (board == null) {
        return const Scaffold(
          body: ErrorView(
            message: 'Board not found',
          ),
        );
      }

      return BoardListsScreen(board: board);
    });
  }
}

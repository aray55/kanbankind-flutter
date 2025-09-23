import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../localization/local_keys.dart';
import '../services/dialog_service.dart';
import '../../controllers/board_controller.dart';
import '../../views/widgets/boards/add_edit_board_modal.dart';

/// Helper class containing all board-related dialog methods
class BoardDialogHelper {
  /// Shows the add board modal bottom sheet
  static void showAddBoardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditBoardModal(),
    );
  }

  /// Shows the edit board modal bottom sheet
  static void showEditBoardModal(BuildContext context, dynamic board) {
    final boardController = Get.find<BoardController>();
    boardController.selectBoard(board);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditBoardModal(board: board),
    );
  }

  /// Shows the search dialog for boards
  static Future<void> showSearchDialog(
    BuildContext context,
    BoardController controller,
  ) async {
    final dialogService = Get.find<DialogService>();
    final query = await dialogService.searchDialog(
      title: LocalKeys.searchBoards.tr,
      hint: LocalKeys.enterBoardName.tr,
    );
    
    if (query != null && query.isNotEmpty) {
      controller.updateSearchQuery(query);
    } else {
      controller.clearSearch();
    }
  }

  /// Shows the archive confirmation dialog
  static Future<void> showArchiveConfirmation(BuildContext context, dynamic board) async {
    final dialogService = Get.find<DialogService>();
    final confirmed = await dialogService.confirm(
      title: LocalKeys.archiveBoard.tr,
      message: '${LocalKeys.areYouSureArchive.tr} "${board.title}"?',
      confirmText: LocalKeys.archive.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    
    if (confirmed) {
      Get.find<BoardController>().archiveBoard(board.id!);
    }
  }

  /// Shows the delete confirmation dialog
  static Future<void> showDeleteConfirmation(BuildContext context, dynamic board) async {
    final dialogService = Get.find<DialogService>();
    final confirmed = await dialogService.confirm(
      title: LocalKeys.deleteBoard.tr,
      message: '${LocalKeys.areYouSureDelete.tr} "${board.title}"? ${LocalKeys.cannotBeUndone.tr}.',
      confirmText: LocalKeys.delete.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    
    if (confirmed) {
      Get.find<BoardController>().softDeleteBoard(board.id!);
    }
  }

  /// Shows the duplicate board dialog
  static Future<void> showDuplicateBoardDialog(BuildContext context, dynamic board) async {
    final dialogService = Get.find<DialogService>();
    final newBoardName = await dialogService.promptInput(
      title: LocalKeys.duplicateBoard.tr,
      initialValue: '${board.title} (Copy)',
      label: LocalKeys.newBoardName.tr,
      confirmText: LocalKeys.duplicate.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    
    if (newBoardName != null && newBoardName.isNotEmpty) {
      Get.find<BoardController>().duplicateBoard(
        board.id!,
        newBoardName,
      );
    }
  }

  /// Shows the restore confirmation dialog
  static Future<void> showRestoreConfirmation(BuildContext context, dynamic board) async {
    final dialogService = Get.find<DialogService>();
    final confirmed = await dialogService.confirm(
      title: LocalKeys.restoreBoard.tr,
      message: '${LocalKeys.areYouSureRestore.tr} "${board.title}"?',
      confirmText: LocalKeys.restore.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    
    if (confirmed) {
      Get.find<BoardController>().unarchiveBoard(board.id!);
    }
  }

  /// Shows the permanent delete confirmation dialog
  static Future<void> showPermanentDeleteConfirmation(
    BuildContext context,
    dynamic board,
  ) async {
    final dialogService = Get.find<DialogService>();
    final confirmed = await dialogService.confirm(
      title: LocalKeys.permanentlyDeleteBoard.tr,
      message: '${LocalKeys.permanentlyDeleteWarning.tr} "${board.title}"? ${LocalKeys.cannotBeUndone.tr}.',
      confirmText: LocalKeys.permanentlyDelete.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    
    if (confirmed) {
      Get.find<BoardController>().hardDeleteBoard(board.id!);
    }
  }
}

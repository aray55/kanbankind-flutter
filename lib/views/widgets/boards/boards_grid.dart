import 'package:flutter/material.dart';
import 'package:kanbankit/controllers/board_controller.dart';
import 'package:kanbankit/core/enums/board_tile_mode.dart';
import 'board_tile_widget.dart';

class BoardsGrid extends StatelessWidget {
  final bool isArchived;
  final BoardController controller;
  final Function? onTap;
  final Function? onEdit;
  final Function? onArchive;
  final Function? onDelete;
  final Function? onDuplicate;
  final Function? onRestore;

  const BoardsGrid({
    super.key,
    required this.controller,
    this.isArchived = false,
    this.onTap,
    this.onEdit,
    this.onArchive,
    this.onDelete,
    this.onDuplicate,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final boards = isArchived
        ? controller.archivedBoards
        : controller.searchQuery.isEmpty
            ? controller.boards
            : controller.filteredBoards;

    if (boards.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      padding: const EdgeInsets.all(0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return BoardTileWidget(
          board: board,
          mode: isArchived ? BoardTileMode.archived : BoardTileMode.active,
          onTap: isArchived ? null : () => onTap?.call(board),
          onEdit: isArchived ? null : () => onEdit?.call(board),
          onArchive: isArchived ? null : () => onArchive?.call(board),
          onDelete: () =>
              isArchived ? onDelete?.call(board) : onDelete?.call(board),
          onDuplicate: isArchived ? null : () => onDuplicate?.call(board),
          onRestore: isArchived ? () => onRestore?.call(board) : null,
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}

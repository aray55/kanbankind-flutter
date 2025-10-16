import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/utils/date_utils.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/controllers/activity_log_controller.dart';
import 'package:kanbankit/controllers/comment_controller.dart';
import 'package:kanbankit/controllers/attachment_controller.dart';
import 'package:kanbankit/views/components/info_row.dart';
import 'package:kanbankit/views/widgets/checklists/checklist_section.dart';
import '../responsive_text.dart';
import 'package:kanbankit/views/components/datetime_picker.dart';
import 'card_due_date.dart';
import 'card_form.dart';
import 'card_actions.dart';
import 'card_cover_widget.dart';
import '../labels/labels_index.dart';
import '../comments/comments_list_widget.dart';
import '../attachments/attachments_list_widget.dart';
import '../activity/activity_timeline_widget.dart';

/// Card Detail Modal with Tabs
/// Enhanced version with Comments, Attachments, and Activity tabs
class CardDetailModalTabbed extends StatefulWidget {
  final CardModel card;

  const CardDetailModalTabbed({Key? key, required this.card}) : super(key: key);

  @override
  State<CardDetailModalTabbed> createState() => _CardDetailModalTabbedState();
}

class _CardDetailModalTabbedState extends State<CardDetailModalTabbed>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Listen to tab changes to reload data
    _tabController.addListener(_onTabChanged);
  }
  
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Reload data when switching to specific tabs
      switch (_tabController.index) {
        case 1: // Comments tab
          _reloadComments();
          break;
        case 2: // Attachments tab
          _reloadAttachments();
          break;
        case 3: // Activity tab
          _reloadActivityLogs();
          break;
      }
    }
  }
  
  void _reloadComments() {
    try {
      final commentController = Get.find<CommentController>();
      commentController.loadCommentsForCard(
        widget.card.id!,
        showLoading: false,
      );
    } catch (e) {
      // CommentController not registered yet
    }
  }
  
  void _reloadAttachments() {
    try {
      final attachmentController = Get.find<AttachmentController>();
      attachmentController.loadAttachmentsForCard(
        widget.card.id!,
        showLoading: false,
      );
    } catch (e) {
      // AttachmentController not registered yet
    }
  }
  
  void _reloadActivityLogs() {
    try {
      final activityLogController = Get.find<ActivityLogController>();
      activityLogController.loadCardActivityLogs(
        widget.card.id!,
        showLoading: false,
      );
    } catch (e) {
      // ActivityLogController not registered yet
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<CardController>();
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with cover and title
          _buildHeader(context, cardController),

          // TabBar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              indicatorColor: theme.colorScheme.primary,
              tabs: [
                Tab(
                  icon: const Icon(Icons.info_outline, size: 20),
                  text: LocalKeys.detailsTab.tr,
                ),
                Tab(
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  text: LocalKeys.comments.tr,
                ),
                Tab(
                  icon: const Icon(Icons.attach_file, size: 20),
                  text: LocalKeys.attachments.tr,
                ),
                Tab(
                  icon: const Icon(Icons.history, size: 20),
                  text: LocalKeys.activity.tr,
                ),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                _buildDetailsTab(context, cardController),

                // Comments Tab
                SingleChildScrollView(
                  child: CommentsListWidget(
                    cardId: widget.card.id!,
                    showAddComment: true,
                    showHeader: false,
                  ),
                ),

                // Attachments Tab
                SingleChildScrollView(
                  child: AttachmentsListWidget(
                    cardId: widget.card.id!,
                    showAddButton: true,
                    showHeader: false,
                  ),
                ),

                // Activity Tab
                SingleChildScrollView(
                  child: ActivityTimelineWidget(
                    cardId: widget.card.id!,
                    showHeader: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CardController cardController) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Cover
        CardCoverWidget(
          card: widget.card,
          height: 120,
          showFullCover: true,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),

        // Title and actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  widget.card.title,
                  variant: AppTextVariant.h2,
                ),
              ),
              // Complete checkbox
              GestureDetector(
                onTap: () {
                  if (widget.card.isCompleted) {
                    cardController.uncompleteCard(widget.card.id!);
                  } else {
                    cardController.completeCard(widget.card.id!);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.card.isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.card.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: widget.card.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context, CardController cardController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          if (widget.card.status != CardStatus.todo) ...[
            InfoRow(
              icon: Icons.flag,
              label: LocalKeys.status.tr,
              value: widget.card.status.getDisplayName(),
            ),
            const SizedBox(height: 8.0),
          ],

          // Completed At
          if (widget.card.completedAt != null) ...[
            InfoRow(
              icon: Icons.check_circle,
              label: LocalKeys.completedAt.tr,
              value: AppDateUtils.formatDateTime(widget.card.completedAt!),
            ),
            const SizedBox(height: 8.0),
          ],

          // Due Date
          _buildDueDateSection(context, cardController, widget.card),

          // Labels
          _buildLabelsSection(context, widget.card),

          // Description
          if (widget.card.description != null &&
              widget.card.description!.isNotEmpty) ...[
            AppText(LocalKeys.description.tr, variant: AppTextVariant.h2),
            const SizedBox(height: 8.0),
            AppText(
              widget.card.description!,
              variant: AppTextVariant.body,
            ),
            const SizedBox(height: 16.0),
          ],

          // Checklists
          if (widget.card.id != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ChecklistSection(cardId: widget.card.id!),
            ),
            const SizedBox(height: 16.0),
          ],

          // Actions
          CardActions(
            card: widget.card,
            onEdit: () => _openEditForm(context, widget.card),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsSection(BuildContext context, CardModel card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              LocalKeys.labels.tr,
              variant: AppTextVariant.h2,
              fontWeight: FontWeight.w600,
            ),
            IconButton(
              onPressed: () => _showLabelSelector(context, card),
              icon: const Icon(Icons.add),
              iconSize: 20,
              tooltip: LocalKeys.addLabel.tr,
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        CardLabelsDisplay(
          cardId: card.id!,
          boardId: _getBoardIdFromCard(card),
          mode: CardLabelsDisplayMode.chips,
          showAddButton: true,
          onLabelsChanged: (labels) {
            // Refresh card data if needed
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildDueDateSection(
    BuildContext context,
    CardController cardController,
    CardModel card,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          LocalKeys.dueDate.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8.0),
        if (card.dueDate != null)
          InkWell(
            onTap: () => _showDueDatePicker(context, cardController, card),
            borderRadius: BorderRadius.circular(8),
            child: CardDueDateWidget(
              dueDate: card.dueDate,
              isCompleted: card.isCompleted,
              showStatus: true,
              compact: false,
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => _showDueDatePicker(context, cardController, card),
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(LocalKeys.setDueDate.tr),
          ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  void _showDueDatePicker(
    BuildContext context,
    CardController cardController,
    CardModel card,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateTimePicker(
                initialDateTime: card.dueDate,
                onSelected: (date) async {
                  await cardController.setDueDate(card.id!, date);
                  Navigator.of(context).pop();
                },
              ),
              if (card.dueDate != null)
                TextButton(
                  onPressed: () async {
                    await cardController.setDueDate(card.id!, null);
                    Get.back();
                  },
                  child: Text(
                    LocalKeys.removeDueDate.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLabelSelector(BuildContext context, CardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LabelSelectorModal(
        cardId: card.id!,
        boardId: _getBoardIdFromCard(card),
      ),
    );
  }

  int _getBoardIdFromCard(CardModel card) {
    // TODO: Get board ID from card's list
    return 1;
  }

  void _openEditForm(BuildContext context, CardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CardForm(card: card, listId: card.listId),
    );
  }
}

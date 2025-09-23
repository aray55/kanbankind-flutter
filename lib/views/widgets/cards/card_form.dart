import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import '../checklists/checklist_section.dart';


class CardForm extends StatefulWidget {
  final CardModel? card; // null for new card, provided for editing
  final int listId; // required for new cards

  const CardForm({Key? key, this.card, required this.listId}) : super(key: key);

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late CardStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.card?.description ?? '',
    );
    _selectedStatus = widget.card?.status ?? CardStatus.todo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<CardController>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.0,
        right: 20.0,
        top: 20.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  widget.card == null
                      ? LocalKeys.addCard.tr
                      : LocalKeys.editCard.tr,
                  variant: AppTextVariant.body2,
                  fontWeight: FontWeight.bold,
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: LocalKeys.cardTitle.tr,
                border: const OutlineInputBorder(),
                hintText: LocalKeys.pleaseEnterCardTitle.tr,
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocalKeys.pleaseEnterCardTitle.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: LocalKeys.cardDescription.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),

            // Status dropdown
            DropdownButtonFormField<CardStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: LocalKeys.status.tr,
                border: const OutlineInputBorder(),
              ),
              items: CardStatus.values.map((CardStatus status) {
                return DropdownMenuItem<CardStatus>(
                  value: status,
                  child: Text(status.getDisplayName()),
                );
              }).toList(),
              onChanged: (CardStatus? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),

            // Checklists Section (only for editing existing cards)
            if (widget.card != null && widget.card!.id != null) ...[
              ChecklistSection(
                cardId: widget.card!.id!,
                isEditable: true,
                showArchivedButton: false, // Keep it simple in the form
              ),
              const SizedBox(height: 16.0),
            ],

            // Note: Checklists can be added after card creation
            // This follows Trello's UX pattern of "create first, enhance later"

            const SizedBox(height: 8.0),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveCard(cardController);
                  }
                },
                child: Text(LocalKeys.save.tr),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _saveCard(CardController controller) {
    if (widget.card == null) {
      // Create new card
      controller
          .createCard(
            listId: widget.listId,
            title: _titleController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            status: _selectedStatus,
          )
          .then((_) {
            // Refresh all cards after creation to update all list columns
            controller.loadAllCards(showLoading: false);
          });
    } else {
      // Update existing card
      final updatedCard = widget.card!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        status: _selectedStatus,
      );
      controller.updateCard(updatedCard).then((_) {
        // Refresh all cards after update
        controller.loadAllCards(showLoading: false);
      });
    }

    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import '../checklists/checklist_section.dart';
import 'package:kanbankit/views/components/datetime_picker.dart';
import 'card_due_date.dart';


class CardForm extends StatefulWidget {
  final CardModel? card;
  final int listId;

  const CardForm({Key? key, this.card, required this.listId}) : super(key: key);

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final Rx<CardStatus> _selectedStatus;
  late final Rx<DateTime?> _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.card?.description ?? '',
    );
    _selectedStatus = (widget.card?.status ?? CardStatus.todo).obs;
    _selectedDueDate = (widget.card?.dueDate).obs;
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
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: LocalKeys.cardDescription.tr,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              Obx(() => DropdownButtonFormField<CardStatus>(
                    value: _selectedStatus.value,
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
                        _selectedStatus.value = newValue;
                      }
                    },
                  )),
              const SizedBox(height: 16.0),
              _buildDueDateSection(context),
              const SizedBox(height: 16.0),
              if (widget.card != null && widget.card!.id != null) ...[
                ChecklistSection(
                  cardId: widget.card!.id!,
                  isEditable: true,
                  showArchivedButton: false,
                ),
                const SizedBox(height: 16.0),
              ],
              const SizedBox(height: 8.0),
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

  Widget _buildDueDateSection(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              LocalKeys.dueDate.tr,
              variant: AppTextVariant.body,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8.0),
            if (_selectedDueDate.value != null)
              InkWell(
                onTap: () => _showDueDatePicker(context, _selectedDueDate.value),
                borderRadius: BorderRadius.circular(8),
                child: CardDueDateWidget(
                  dueDate: _selectedDueDate.value,
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _showDueDatePicker(context, null),
                icon: const Icon(Icons.add),
                label: Text(LocalKeys.add.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ));
  }

  void _showDueDatePicker(BuildContext context, DateTime? initialDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateTimePicker(
                initialDateTime: initialDate,
                onSelected: (date) {
                  _selectedDueDate.value = date;
                  Navigator.of(context).pop();
                },
              ),
              if (initialDate != null)
                TextButton(
                  onPressed: () {
                    _selectedDueDate.value = null;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    LocalKeys.removeDueDate.tr,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _saveCard(CardController controller) async {
    if (widget.card == null) {
      await controller.createCard(
        listId: widget.listId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        status: _selectedStatus.value,
        dueDate: _selectedDueDate.value,
      );
    } else {
      final updatedCard = widget.card!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        status: _selectedStatus.value,
        dueDate: _selectedDueDate.value,
      );
      await controller.updateCard(updatedCard);
    }

    controller.loadAllCards(showLoading: false);
    Navigator.of(context).pop();
  }
}

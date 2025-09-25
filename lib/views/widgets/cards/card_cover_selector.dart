import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import '../../../models/card_model.dart';
import '../../../controllers/card_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../image_picker_bottom_sheet.dart';
import '../color_picker_widget.dart';
import 'card_cover_widget.dart';

/// Bottom sheet for selecting card cover (color or image)
class CardCoverSelector extends StatefulWidget {
  final CardModel card;
  final Function(CardModel)? onCoverChanged;

  const CardCoverSelector({
    Key? key,
    required this.card,
    this.onCoverChanged,
  }) : super(key: key);
/// Static method to show the cover selector
static Future<void> show({
  required BuildContext context,
  required CardModel card,
  Function(CardModel)? onCoverChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CardCoverSelector(
      card: card,
      onCoverChanged: onCoverChanged,
    ),
  );
}

  @override
  State<CardCoverSelector> createState() => _CardCoverSelectorState();
}

class _CardCoverSelectorState extends State<CardCoverSelector> {
  late CardController _cardController;
  late DialogService _dialogService;


  // Local copy to allow preview before saving
  late String _coverColor;
  late String _coverImage;

  @override
  void initState() {
    super.initState();
    _cardController = Get.find<CardController>();
    _dialogService = Get.find<DialogService>();
    _coverColor = widget.card.coverColor ?? '';
    _coverImage = widget.card.coverImage ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              LocalKeys.selectCoverType.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Current cover preview
          if (_coverColor.isNotEmpty || _coverImage.isNotEmpty)
            _buildCurrentCoverPreview(),

          // Cover options
          _buildCoverOptions(),

          const SizedBox(height: 16),

          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton(
              onPressed: _saveCover,
              child: Text(LocalKeys.save.tr),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildCurrentCoverPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              LocalKeys.cardCover.tr,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: CardCoverWidget(
              card: widget.card.copyWith(
                  coverColor: _coverColor, coverImage: _coverImage),
              height: 100,
              showFullCover: true,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverOptions() {
    return Column(
      children: [
        // Color cover option
        _buildOptionTile(
          context: context,
          icon: Icons.palette_outlined,
          title: LocalKeys.coverColor.tr,
          subtitle: LocalKeys.chooseCoverColor.tr,
          onTap: _showColorPicker,
        ),

        // Image cover option
        _buildOptionTile(
          context: context,
          icon: Icons.image_outlined,
          title: LocalKeys.coverImage.tr,
          subtitle: LocalKeys.chooseCoverImage.tr,
          onTap: _showImagePicker,
        ),

        // Remove cover option
        if (_coverColor.isNotEmpty || _coverImage.isNotEmpty)
          _buildOptionTile(
            context: context,
            icon: Icons.clear,
            title: LocalKeys.removeCover.tr,
            subtitle: LocalKeys.noCover.tr,
            iconColor: Colors.red,
            onTap: _removeCover,
          ),

        // Cancel option
        _buildOptionTile(
          context: context,
          icon: Icons.close,
          title: LocalKeys.cancel.tr,
          subtitle: LocalKeys.closeWithoutChanges.tr,
          onTap: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.chooseCoverColor.tr),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ColorPickerWidget(
            selectedColor: _coverColor.isNotEmpty ? _coverColor : '#3498db',
            onColorSelected: (colorHex) {
              setState(() {
                _coverColor = colorHex;
                _coverImage = ''; // clear image when choosing color
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalKeys.cancel.tr),
          ),
        ],
      ),
    );
  }

  void _showImagePicker() async {
    final String? imagePath = await ImagePickerBottomSheet.show(
      context: context,
      currentImagePath: _coverImage,
    );

    if (imagePath != null) {
      setState(() {
        _coverImage = imagePath;
        _coverColor = ''; // clear color when choosing image
      });
    }
  }

  void _removeCover() {
    setState(() {
      _coverColor = '';
      _coverImage = '';
    });
  }

  Future<void> _saveCover() async {
    try {
      // Determine what changes need to be made
      final currentCoverColor = widget.card.coverColor ?? '';
      final currentCoverImage = widget.card.coverImage ?? '';
      
      bool colorChanged = _coverColor != currentCoverColor;
      bool imageChanged = _coverImage != currentCoverImage;
      
      // Only update what actually changed
      if (colorChanged) {
        await _cardController.changeCoverColor(widget.card.id!, _coverColor);
      }
      if (imageChanged) {
        await _cardController.changeCoverImage(widget.card.id!, _coverImage);
      }
      
      // Only show success if something was actually changed
      if (colorChanged || imageChanged) {
        // The controller will handle updating the reactive cards list
        widget.onCoverChanged?.call(widget.card);
        
        _dialogService.showSnack(
          title: LocalKeys.success.tr,
          message: LocalKeys.coverUpdatedSuccessfully.tr,
        );
      }
      
      Get.back();
    } catch (e) {
      _dialogService.showSnack(
        title: LocalKeys.error.tr,
        message: e.toString(),
      );
    }
  }

  /// Static method to show the cover selector
  static Future<void> show({
    required BuildContext context,
    required CardModel card,
    Function(CardModel)? onCoverChanged,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardCoverSelector(
        card: card,
        onCoverChanged: onCoverChanged,
      ),
    );
  }
}

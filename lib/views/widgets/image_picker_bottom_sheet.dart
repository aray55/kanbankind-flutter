import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/image_picker_controller.dart';
import '../../core/localization/local_keys.dart';

/// Bottom sheet widget for image picker options
class ImagePickerBottomSheet extends StatelessWidget {
  final String? currentImagePath;
  final Function(String?)? onImageSelected;
  final bool showRemoveOption;
  
  const ImagePickerBottomSheet({
    Key? key,
    this.currentImagePath,
    this.onImageSelected,
    this.showRemoveOption = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final ImagePickerController controller = Get.put(ImagePickerController());
    
    // Set current image if provided
    if (currentImagePath != null) {
      controller.setSelectedImagePath(currentImagePath);
    }
    
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
              LocalKeys.selectImageSource.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Current image preview (if exists)
          Obx(() {
            if (controller.hasSelectedImage) {
              return _buildCurrentImagePreview(context, controller);
            }
            return const SizedBox.shrink();
          }),
          
          // Options list
          _buildOptionsList(context, controller),
          
          // Loading indicator
          Obx(() {
            if (controller.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
  
  Widget _buildCurrentImagePreview(BuildContext context, ImagePickerController controller) {
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
              LocalKeys.currentImage.tr,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Image.file(
              File(controller.selectedImagePath),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptionsList(BuildContext context, ImagePickerController controller) {
    return Column(
      children: [
        // Gallery option
        _buildOptionTile(
          context: context,
          icon: Icons.photo_library_outlined,
          title: LocalKeys.selectFromGallery.tr,
          subtitle: LocalKeys.chooseFromExistingPhotos.tr,
          onTap: () async {
            final String? imagePath = await controller.pickFromGallery();
            if (imagePath != null) {
              onImageSelected?.call(imagePath);
              Get.back();
            }
          },
        ),
        
        // Camera option
        _buildOptionTile(
          context: context,
          icon: Icons.camera_alt_outlined,
          title: LocalKeys.takePhoto.tr,
          subtitle: LocalKeys.captureNewPhoto.tr,
          onTap: () async {
            final String? imagePath = await controller.pickFromCamera();
            if (imagePath != null) {
              onImageSelected?.call(imagePath);
              Get.back();
            }
          },
        ),
        
        // Remove option (if image exists and removal is allowed)
        if (showRemoveOption && controller.hasSelectedImage)
          _buildOptionTile(
            context: context,
            icon: Icons.delete_outline,
            title: LocalKeys.removeImage.tr,
            subtitle: LocalKeys.removeCurrentImage.tr,
            iconColor: Colors.red,
            onTap: () async {
              final bool confirmed = await _showRemoveConfirmation(context);
              if (confirmed) {
                await controller.removeSelectedImage();
                onImageSelected?.call(null);
                Get.back();
              }
            },
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
  
  Future<bool> _showRemoveConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.removeImage.tr),
        content: Text(LocalKeys.confirmRemoveImage.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(LocalKeys.remove.tr),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Static method to show the bottom sheet
  static Future<String?> show({
    required BuildContext context,
    String? currentImagePath,
    bool showRemoveOption = true,
  }) async {
    String? selectedImagePath;
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerBottomSheet(
        currentImagePath: currentImagePath,
        showRemoveOption: showRemoveOption,
        onImageSelected: (imagePath) {
          selectedImagePath = imagePath;
        },
      ),
    );
    
    return selectedImagePath;
  }
}

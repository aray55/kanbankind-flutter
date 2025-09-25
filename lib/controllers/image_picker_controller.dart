import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/image_picker_service.dart';
import '../core/services/dialog_service.dart';
import '../core/localization/local_keys.dart';

/// Controller for managing image picker operations and state
class ImagePickerController extends GetxController {
  final ImagePickerService _imagePickerService = Get.find<ImagePickerService>();
  final DialogService _dialogService = Get.find<DialogService>();
  
  // Observable states
  final RxBool _isLoading = false.obs;
  final RxString _selectedImagePath = ''.obs;
  final RxString _error = ''.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  String get selectedImagePath => _selectedImagePath.value;
  String get error => _error.value;
  bool get hasSelectedImage => _selectedImagePath.value.isNotEmpty;
  
  /// Pick image from gallery
  Future<String?> pickFromGallery() async {
    try {
      _setLoading(true);
      _clearError();
      
      final String? imagePath = await _imagePickerService.pickImageFromGallery();
      
      if (imagePath != null) {
        _selectedImagePath.value = imagePath;
        _showSuccessMessage(LocalKeys.imageSelectedSuccessfully.tr);
        return imagePath;
      } else {
        _showErrorMessage(LocalKeys.noImageSelected.tr);
        return null;
      }
    } catch (e) {
      _setError('Error picking image from gallery: ${e.toString()}');
      _showErrorMessage(LocalKeys.errorPickingImage.tr);
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Pick image from camera
  Future<String?> pickFromCamera() async {
    try {
      _setLoading(true);
      _clearError();
      
      final String? imagePath = await _imagePickerService.pickImageFromCamera();
      
      if (imagePath != null) {
        _selectedImagePath.value = imagePath;
        _showSuccessMessage(LocalKeys.imageSelectedSuccessfully.tr);
        return imagePath;
      } else {
        _showErrorMessage(LocalKeys.noImageSelected.tr);
        return null;
      }
    } catch (e) {
      _setError('Error picking image from camera: ${e.toString()}');
      _showErrorMessage(LocalKeys.errorPickingImage.tr);
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Remove selected image
  Future<void> removeSelectedImage() async {
    try {
      if (_selectedImagePath.value.isNotEmpty) {
        final bool deleted = await _imagePickerService.deleteImage(_selectedImagePath.value);
        if (deleted) {
          _selectedImagePath.value = '';
          _showSuccessMessage(LocalKeys.imageRemovedSuccessfully.tr);
        } else {
          _showErrorMessage(LocalKeys.errorRemovingImage.tr);
        }
      }
    } catch (e) {
      _setError('Error removing image: ${e.toString()}');
      _showErrorMessage(LocalKeys.errorRemovingImage.tr);
    }
  }
  
  /// Clear selected image without deleting the file
  void clearSelectedImage() {
    _selectedImagePath.value = '';
    _clearError();
  }
  
  /// Set selected image path (for editing existing cards)
  void setSelectedImagePath(String? imagePath) {
    _selectedImagePath.value = imagePath ?? '';
    _clearError();
  }
  
  /// Check if image exists
  Future<bool> checkImageExists(String imagePath) async {
    try {
      return await _imagePickerService.imageExists(imagePath);
    } catch (e) {
      debugPrint('Error checking image existence: $e');
      return false;
    }
  }
  
  /// Get image size
  Future<String> getImageSizeFormatted(String imagePath) async {
    try {
      final int? size = await _imagePickerService.getImageSize(imagePath);
      if (size != null) {
        return _imagePickerService.formatFileSize(size);
      }
      return 'Unknown size';
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 'Unknown size';
    }
  }
  
  /// Show image picker options (gallery, camera, remove)
  Future<String?> showImagePickerOptions() async {
    final List<String> options = [
      LocalKeys.selectFromGallery.tr,
      LocalKeys.takePhoto.tr,
    ];
    
    // Add remove option if image is already selected
    if (hasSelectedImage) {
      options.add(LocalKeys.removeImage.tr);
    }
    
    final int? selectedIndex = await _showOptionsDialog(
      title: LocalKeys.selectImageSource.tr,
      options: options,
    );
    
    if (selectedIndex != null) {
      switch (selectedIndex) {
        case 0:
          return await pickFromGallery();
        case 1:
          return await pickFromCamera();
        case 2:
          if (hasSelectedImage) {
            final bool confirmed = await _confirmRemoveImage();
            if (confirmed) {
              await removeSelectedImage();
              return null;
            }
          }
          break;
      }
    }
    
    return null;
  }
  
  /// Show options dialog
  Future<int?> _showOptionsDialog({
    required String title,
    required List<String> options,
  }) async {
    return await Get.dialog<int>(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.asMap().entries.map((entry) {
            final int index = entry.key;
            final String option = entry.value;
            
            return ListTile(
              title: Text(option),
              onTap: () => Get.back(result: index),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalKeys.cancel.tr),
          ),
        ],
      ),
    );
  }
  
  /// Confirm remove image dialog
  Future<bool> _confirmRemoveImage() async {
    return await _dialogService.confirm(
      title: LocalKeys.removeImage.tr,
      message: LocalKeys.confirmRemoveImage.tr,
      confirmText: LocalKeys.remove.tr,
      cancelText: LocalKeys.cancel.tr,
    );
  }
  
  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }
  
  void _setError(String error) {
    _error.value = error;
    debugPrint('ImagePickerController Error: $error');
  }
  
  void _clearError() {
    _error.value = '';
  }
  
  void _showSuccessMessage(String message) {
    _dialogService.showSuccessSnackbar(
      title: LocalKeys.success.tr,
      message: message,
    );
  }
  
  void _showErrorMessage(String message) {
    _dialogService.showErrorSnackbar(
      title: LocalKeys.error.tr,
      message: message,
    );
  }
  
  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}

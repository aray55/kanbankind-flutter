import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'file_storage_service.dart';

/// Service for handling image picking and storage operations
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final FileStorageService _fileStorageService = Get.find<FileStorageService>();
  
  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _fileStorageService.saveCardCover(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }
  
  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _fileStorageService.saveCardCover(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }
  
  /// Delete image file from storage
  Future<bool> deleteImage(String imagePath) async {
    return await _fileStorageService.deleteFile(imagePath);
  }
  
  /// Check if image file exists
  Future<bool> imageExists(String imagePath) async {
    return await _fileStorageService.fileExists(imagePath);
  }
  
  /// Get image file size in bytes
  Future<int?> getImageSize(String imagePath) async {
    return await _fileStorageService.getFileSize(imagePath);
  }
  
  /// Clean up old unused images (optional maintenance method)
  Future<int> cleanupUnusedImages(List<String> usedImagePaths) async {
    final String coversDir = await _fileStorageService.getCardCoversDirectoryPath();
    return await _fileStorageService.cleanupUnusedFiles(coversDir, usedImagePaths);
  }
  
  /// Get total size of all cover images
  Future<int> getTotalImagesSize() async {
    final String coversDir = await _fileStorageService.getCardCoversDirectoryPath();
    return await _fileStorageService.getDirectorySize(coversDir);
  }
  
  /// Format file size to human readable string
  String formatFileSize(int bytes) {
    return _fileStorageService.formatFileSize(bytes);
  }
  
  /// Get storage statistics for images
  Future<Map<String, dynamic>> getImageStorageStats() async {
    final Map<String, dynamic> stats = await _fileStorageService.getStorageStats();
    return stats['covers'] ?? {};
  }
  
  /// Clean up old images (older than specified days)
  Future<int> cleanupOldImages(int daysOld) async {
    final String coversDir = await _fileStorageService.getCardCoversDirectoryPath();
    return await _fileStorageService.cleanupOldFiles(coversDir, daysOld);
  }
  
  /// Get list of all image files
  Future<List<String>> getAllImageFiles() async {
    final String coversDir = await _fileStorageService.getCardCoversDirectoryPath();
    return await _fileStorageService.listFiles(coversDir);
  }
  
  /// Get image file info
  Future<Map<String, dynamic>?> getImageInfo(String imagePath) async {
    return await _fileStorageService.getFileInfo(imagePath);
  }
}

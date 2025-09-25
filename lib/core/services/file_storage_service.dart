import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling file storage operations
class FileStorageService {
  static const String _cardCoversDir = 'card_covers';
  static const String _attachmentsDir = 'attachments';
  static const String _tempDir = 'temp';
  
  /// Get the application documents directory
  Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// Get the application cache directory
  Future<Directory> getAppCacheDirectory() async {
    return await getTemporaryDirectory();
  }
  
  /// Create a directory if it doesn't exist
  Future<Directory> createDirectory(String dirPath) async {
    final Directory directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
  
  /// Get card covers directory path
  Future<String> getCardCoversDirectoryPath() async {
    final Directory appDir = await getAppDocumentsDirectory();
    return path.join(appDir.path, _cardCoversDir);
  }
  
  /// Get attachments directory path
  Future<String> getAttachmentsDirectoryPath() async {
    final Directory appDir = await getAppDocumentsDirectory();
    return path.join(appDir.path, _attachmentsDir);
  }
  
  /// Get temp directory path
  Future<String> getTempDirectoryPath() async {
    final Directory cacheDir = await getAppCacheDirectory();
    return path.join(cacheDir.path, _tempDir);
  }
  
  /// Save file to specified directory with unique name
  Future<String?> saveFile({
    required String sourcePath,
    required String targetDirectory,
    String? fileName,
    String? prefix,
  }) async {
    try {
      // Create target directory if it doesn't exist
      await createDirectory(targetDirectory);
      
      // Generate unique filename if not provided
      final String sourceFileName = path.basename(sourcePath);
      final String extension = path.extension(sourceFileName);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      final String finalFileName = fileName ?? 
          '${prefix ?? 'file'}_$timestamp$extension';
      
      final String targetPath = path.join(targetDirectory, finalFileName);
      
      // Copy file to target location
      final File sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(targetPath);
        return targetPath;
      } else {
        debugPrint('Source file does not exist: $sourcePath');
        return null;
      }
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }
  
  /// Save file to card covers directory
  Future<String?> saveCardCover(String sourcePath, {String? fileName}) async {
    final String coversDir = await getCardCoversDirectoryPath();
    return await saveFile(
      sourcePath: sourcePath,
      targetDirectory: coversDir,
      fileName: fileName,
      prefix: 'cover',
    );
  }
  
  /// Save file to attachments directory
  Future<String?> saveAttachment(String sourcePath, {String? fileName}) async {
    final String attachmentsDir = await getAttachmentsDirectoryPath();
    return await saveFile(
      sourcePath: sourcePath,
      targetDirectory: attachmentsDir,
      fileName: fileName,
      prefix: 'attachment',
    );
  }
  
  /// Delete file
  Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }
  
  /// Get file size in bytes
  Future<int?> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return null;
    }
  }
  
  /// Get file info (size, modified date, etc.)
  Future<Map<String, dynamic>?> getFileInfo(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        final FileStat stat = await file.stat();
        return {
          'path': filePath,
          'name': path.basename(filePath),
          'size': stat.size,
          'modified': stat.modified,
          'accessed': stat.accessed,
          'type': stat.type.toString(),
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file info: $e');
      return null;
    }
  }
  
  /// List files in directory
  Future<List<String>> listFiles(String directoryPath, {String? extension}) async {
    try {
      final Directory directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> entities = await directory.list().toList();
      final List<String> filePaths = [];
      
      for (final FileSystemEntity entity in entities) {
        if (entity is File) {
          if (extension == null || entity.path.endsWith(extension)) {
            filePaths.add(entity.path);
          }
        }
      }
      
      return filePaths;
    } catch (e) {
      debugPrint('Error listing files: $e');
      return [];
    }
  }
  
  /// Get directory size
  Future<int> getDirectorySize(String directoryPath) async {
    try {
      final Directory directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();
      
      for (final FileSystemEntity entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
      return 0;
    }
  }
  
  /// Clean up files older than specified days
  Future<int> cleanupOldFiles(String directoryPath, int daysOld) async {
    try {
      final Directory directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }
      
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final List<FileSystemEntity> entities = await directory.list().toList();
      int deletedCount = 0;
      
      for (final FileSystemEntity entity in entities) {
        if (entity is File) {
          final FileStat stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
            debugPrint('Deleted old file: ${entity.path}');
          }
        }
      }
      
      return deletedCount;
    } catch (e) {
      debugPrint('Error cleaning up old files: $e');
      return 0;
    }
  }
  
  /// Clean up unused files based on a list of used file paths
  Future<int> cleanupUnusedFiles(String directoryPath, List<String> usedFilePaths) async {
    try {
      final Directory directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }
      
      final List<FileSystemEntity> entities = await directory.list().toList();
      int deletedCount = 0;
      
      for (final FileSystemEntity entity in entities) {
        if (entity is File) {
          if (!usedFilePaths.contains(entity.path)) {
            await entity.delete();
            deletedCount++;
            debugPrint('Deleted unused file: ${entity.path}');
          }
        }
      }
      
      return deletedCount;
    } catch (e) {
      debugPrint('Error cleaning up unused files: $e');
      return 0;
    }
  }
  
  /// Move file from one location to another
  Future<String?> moveFile(String sourcePath, String targetPath) async {
    try {
      final File sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        // Create target directory if it doesn't exist
        final String targetDir = path.dirname(targetPath);
        await createDirectory(targetDir);
        
        // Move file
        final File movedFile = await sourceFile.rename(targetPath);
        return movedFile.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error moving file: $e');
      return null;
    }
  }
  
  /// Copy file from one location to another
  Future<String?> copyFile(String sourcePath, String targetPath) async {
    try {
      final File sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        // Create target directory if it doesn't exist
        final String targetDir = path.dirname(targetPath);
        await createDirectory(targetDir);
        
        // Copy file
        await sourceFile.copy(targetPath);
        return targetPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error copying file: $e');
      return null;
    }
  }
  
  /// Format file size to human readable string
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final String coversDir = await getCardCoversDirectoryPath();
      final String attachmentsDir = await getAttachmentsDirectoryPath();
      final String tempDir = await getTempDirectoryPath();
      
      final int coversSize = await getDirectorySize(coversDir);
      final int attachmentsSize = await getDirectorySize(attachmentsDir);
      final int tempSize = await getDirectorySize(tempDir);
      final int totalSize = coversSize + attachmentsSize + tempSize;
      
      final List<String> coverFiles = await listFiles(coversDir);
      final List<String> attachmentFiles = await listFiles(attachmentsDir);
      final List<String> tempFiles = await listFiles(tempDir);
      
      return {
        'total_size': totalSize,
        'total_size_formatted': formatFileSize(totalSize),
        'covers': {
          'size': coversSize,
          'size_formatted': formatFileSize(coversSize),
          'count': coverFiles.length,
          'directory': coversDir,
        },
        'attachments': {
          'size': attachmentsSize,
          'size_formatted': formatFileSize(attachmentsSize),
          'count': attachmentFiles.length,
          'directory': attachmentsDir,
        },
        'temp': {
          'size': tempSize,
          'size_formatted': formatFileSize(tempSize),
          'count': tempFiles.length,
          'directory': tempDir,
        },
      };
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {};
    }
  }
}

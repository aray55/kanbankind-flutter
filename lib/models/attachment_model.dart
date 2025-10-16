import 'dart:io';

/// Attachment Model
/// Represents a file attachment on a card
class AttachmentModel {
  final int? id;
  final int cardId;
  final String fileName;
  final String filePath;
  final int? fileSize; // in bytes
  final String? fileType; // e.g., 'image', 'document', 'video', 'audio', 'other'
  final String? mimeType; // e.g., 'image/png', 'application/pdf'
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime? deletedAt;

  AttachmentModel({
    this.id,
    required this.cardId,
    required this.fileName,
    required this.filePath,
    this.fileSize,
    this.fileType,
    this.mimeType,
    this.thumbnailPath,
    DateTime? createdAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from Map (from database)
  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      id: map['id'] as int?,
      cardId: map['card_id'] as int,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileSize: map['file_size'] as int?,
      fileType: map['file_type'] as String?,
      mimeType: map['mime_type'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ),
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['deleted_at'] as int) * 1000,
            )
          : null,
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_id': cardId,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'file_type': fileType,
      'mime_type': mimeType,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      if (deletedAt != null) 'deleted_at': deletedAt!.millisecondsSinceEpoch ~/ 1000,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'file_type': fileType,
      'mime_type': mimeType,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as int?,
      cardId: json['card_id'] as int,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int?,
      fileType: json['file_type'] as String?,
      mimeType: json['mime_type'] as String?,
      thumbnailPath: json['thumbnail_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  // Copy with method for immutability
  AttachmentModel copyWith({
    int? id,
    int? cardId,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? fileType,
    String? mimeType,
    String? thumbnailPath,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    bool clearThumbnailPath = false,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      thumbnailPath: clearThumbnailPath
          ? null
          : (thumbnailPath ?? this.thumbnailPath),
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  // Helper methods
  bool get isDeleted => deletedAt != null;
  bool get fileExists => File(filePath).existsSync();
  bool get hasThumbnail => thumbnailPath != null && thumbnailPath!.isNotEmpty;
  bool get thumbnailExists => hasThumbnail && File(thumbnailPath!).existsSync();

  // Get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Check if file is an image
  bool get isImage {
    if (fileType == 'image') return true;
    if (mimeType != null && mimeType!.startsWith('image/')) return true;
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    return imageExtensions.contains(fileExtension);
  }

  // Check if file is a document
  bool get isDocument {
    if (fileType == 'document') return true;
    if (mimeType != null &&
        (mimeType!.startsWith('application/pdf') ||
            mimeType!.startsWith('application/msword') ||
            mimeType!.startsWith('application/vnd')))
      return true;
    final docExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ];
    return docExtensions.contains(fileExtension);
  }

  // Check if file is a video
  bool get isVideo {
    if (fileType == 'video') return true;
    if (mimeType != null && mimeType!.startsWith('video/')) return true;
    final videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'];
    return videoExtensions.contains(fileExtension);
  }

  // Check if file is audio
  bool get isAudio {
    if (fileType == 'audio') return true;
    if (mimeType != null && mimeType!.startsWith('audio/')) return true;
    final audioExtensions = ['mp3', 'wav', 'ogg', 'flac', 'm4a'];
    return audioExtensions.contains(fileExtension);
  }

  // Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';

    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = fileSize!.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  // Validation
  bool isValid() {
    return fileName.trim().isNotEmpty &&
        filePath.trim().isNotEmpty &&
        cardId > 0;
  }

  String? validate() {
    if (fileName.trim().isEmpty) {
      return 'File name cannot be empty';
    }
    if (filePath.trim().isEmpty) {
      return 'File path cannot be empty';
    }
    if (cardId <= 0) {
      return 'Invalid card ID';
    }
    return null;
  }

  @override
  String toString() {
    return 'AttachmentModel(id: $id, cardId: $cardId, fileName: $fileName, fileSize: $formattedFileSize, fileType: $fileType, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttachmentModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.fileName == fileName &&
        other.filePath == filePath &&
        other.fileSize == fileSize &&
        other.fileType == fileType &&
        other.mimeType == mimeType &&
        other.thumbnailPath == thumbnailPath &&
        other.createdAt == createdAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        fileName.hashCode ^
        filePath.hashCode ^
        fileSize.hashCode ^
        fileType.hashCode ^
        mimeType.hashCode ^
        thumbnailPath.hashCode ^
        createdAt.hashCode ^
        deletedAt.hashCode;
  }
}

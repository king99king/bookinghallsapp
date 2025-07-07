// core/services/storage_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

import '../constants/firebase_constants.dart';
import '../constants/app_constants.dart';
import '../utils/validators.dart';
import '../utils/id_generator.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

/// Comprehensive storage service for file management
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Service dependencies
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  // Cache for download URLs
  final Map<String, String> _urlCache = {};

  // Active upload tasks
  final Map<String, UploadTask> _activeTasks = {};

  // ========== Image Upload & Management ==========

  /// Upload profile image
  Future<UploadResult> uploadProfileImage({
    required File imageFile,
    required String userId,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      // Validate image file
      final validation = Validators.validateImageFile(imageFile);
      if (validation != null) {
        return UploadResult.failure(validation);
      }

      // Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_profile.jpg';
      final storagePath = FirebaseConstants.getUserAvatarPath(userId, fileName);

      // Optimize image before upload
      final optimizedImage = await _optimizeImage(
        imageFile,
        maxWidth: 512,
        maxHeight: 512,
        quality: 85,
      );

      // Upload to Firebase Storage
      final uploadResult = await _uploadFile(
        data: optimizedImage,
        storagePath: storagePath,
        contentType: 'image/jpeg',
        onProgress: onProgress,
      );

      if (uploadResult.isSuccess) {
        // Update user profile with new image URL
        await _authService.updateCurrentUserData({
          FirebaseConstants.profileImageUrlField: uploadResult.downloadUrl,
        });

        debugPrint('Profile image uploaded successfully: ${uploadResult.downloadUrl}');
      }

      return uploadResult;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return UploadResult.failure('Failed to upload profile image: $e');
    }
  }

  /// Upload hall images
  Future<UploadResult> uploadHallImages({
    required List<File> imageFiles,
    required String hallId,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      // Validate number of images
      if (imageFiles.isEmpty) {
        return UploadResult.failure('No images selected');
      }

      if (imageFiles.length > AppConstants.maxImagesPerHall) {
        return UploadResult.failure('Maximum ${AppConstants.maxImagesPerHall} images allowed');
      }

      // Validate each image
      for (final imageFile in imageFiles) {
        final validation = Validators.validateImageFile(imageFile);
        if (validation != null) {
          return UploadResult.failure('Image validation failed: $validation');
        }
      }

      final uploadedUrls = <String>[];
      final totalFiles = imageFiles.length;

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];

        // Generate unique filename
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg';
        final storagePath = FirebaseConstants.getHallImagePath(hallId, fileName);

        // Optimize image
        final optimizedImage = await _optimizeImage(
          imageFile,
          maxWidth: 1200,
          maxHeight: 800,
          quality: 90,
        );

        // Upload individual image
        final uploadResult = await _uploadFile(
          data: optimizedImage,
          storagePath: storagePath,
          contentType: 'image/jpeg',
          onProgress: onProgress != null
              ? (progress) => onProgress((i + progress) / totalFiles)
              : null,
        );

        if (uploadResult.isSuccess) {
          uploadedUrls.add(uploadResult.downloadUrl!);
        } else {
          // Cleanup uploaded images on failure
          await _cleanupUploadedFiles(uploadedUrls);
          return UploadResult.failure('Failed to upload image ${i + 1}: ${uploadResult.error}');
        }
      }

      // Update hall with new image URLs
      await _firebaseService.update(
        collection: FirebaseConstants.hallsCollection,
        documentId: hallId,
        data: {
          FirebaseConstants.imageUrlsField: FieldValue.arrayUnion(uploadedUrls),
        },
      );

      debugPrint('Hall images uploaded successfully: ${uploadedUrls.length} images');

      return UploadResult.success(
        message: '${uploadedUrls.length} images uploaded successfully',
        downloadUrls: uploadedUrls,
      );

    } catch (e) {
      debugPrint('Error uploading hall images: $e');
      return UploadResult.failure('Failed to upload hall images: $e');
    }
  }

  /// Upload business documents for hall owners
  Future<UploadResult> uploadBusinessDocument({
    required File documentFile,
    required String ownerId,
    required String documentType, // 'license', 'tax_certificate', 'bank_statement', etc.
    UploadProgressCallback? onProgress,
  }) async {
    try {
      // Validate document file
      final validation = Validators.validateDocumentFile(documentFile);
      if (validation != null) {
        return UploadResult.failure(validation);
      }

      // Generate unique filename with document type
      final extension = path.extension(documentFile.path).toLowerCase();
      final fileName = '${documentType}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final storagePath = FirebaseConstants.getBusinessDocumentPath(ownerId, fileName);

      // Read file data
      final fileData = await documentFile.readAsBytes();

      // Upload to Firebase Storage
      final uploadResult = await _uploadFile(
        data: fileData,
        storagePath: storagePath,
        contentType: _getContentType(extension),
        onProgress: onProgress,
      );

      if (uploadResult.isSuccess) {
        // Store document metadata
        await _storeDocumentMetadata(
          ownerId: ownerId,
          documentType: documentType,
          fileName: fileName,
          downloadUrl: uploadResult.downloadUrl!,
          fileSize: fileData.length,
        );

        debugPrint('Business document uploaded successfully: ${uploadResult.downloadUrl}');
      }

      return uploadResult;
    } catch (e) {
      debugPrint('Error uploading business document: $e');
      return UploadResult.failure('Failed to upload business document: $e');
    }
  }

  /// Upload review images
  Future<UploadResult> uploadReviewImages({
    required List<File> imageFiles,
    required String reviewId,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      if (imageFiles.isEmpty) {
        return UploadResult.success(message: 'No images to upload');
      }

      // Validate and upload images
      final uploadedUrls = <String>[];
      final totalFiles = imageFiles.length;

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];

        // Validate image
        final validation = Validators.validateImageFile(imageFile);
        if (validation != null) {
          await _cleanupUploadedFiles(uploadedUrls);
          return UploadResult.failure('Image validation failed: $validation');
        }

        // Generate filename
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg';
        final storagePath = '${FirebaseConstants.reviewImagesPath}/$reviewId/$fileName';

        // Optimize and upload
        final optimizedImage = await _optimizeImage(
          imageFile,
          maxWidth: 800,
          maxHeight: 600,
          quality: 85,
        );

        final uploadResult = await _uploadFile(
          data: optimizedImage,
          storagePath: storagePath,
          contentType: 'image/jpeg',
          onProgress: onProgress != null
              ? (progress) => onProgress((i + progress) / totalFiles)
              : null,
        );

        if (uploadResult.isSuccess) {
          uploadedUrls.add(uploadResult.downloadUrl!);
        } else {
          await _cleanupUploadedFiles(uploadedUrls);
          return UploadResult.failure('Failed to upload image ${i + 1}: ${uploadResult.error}');
        }
      }

      return UploadResult.success(
        message: '${uploadedUrls.length} review images uploaded',
        downloadUrls: uploadedUrls,
      );

    } catch (e) {
      debugPrint('Error uploading review images: $e');
      return UploadResult.failure('Failed to upload review images: $e');
    }
  }

  // ========== File Download & Management ==========

  /// Get download URL with caching
  Future<String?> getDownloadUrl(String storagePath, {bool useCache = true}) async {
    try {
      // Check cache first
      if (useCache && _urlCache.containsKey(storagePath)) {
        return _urlCache[storagePath];
      }

      // Get URL from Firebase Storage
      final ref = _storage.ref(storagePath);
      final url = await ref.getDownloadURL();

      // Cache the URL
      _urlCache[storagePath] = url;

      return url;
    } catch (e) {
      debugPrint('Error getting download URL for $storagePath: $e');
      return null;
    }
  }

  /// Download file to local storage
  Future<DownloadResult> downloadFile({
    required String storagePath,
    required String localPath,
    DownloadProgressCallback? onProgress,
  }) async {
    try {
      final ref = _storage.ref(storagePath);
      final file = File(localPath);

      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);

      // Start download
      final downloadTask = ref.writeToFile(file);

      // Listen to progress
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;

      return DownloadResult.success(
        message: 'File downloaded successfully',
        localPath: localPath,
      );

    } catch (e) {
      debugPrint('Error downloading file from $storagePath: $e');
      return DownloadResult.failure('Failed to download file: $e');
    }
  }

  /// Get file metadata
  Future<FileMetadata?> getFileMetadata(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      final metadata = await ref.getMetadata();

      return FileMetadata(
        name: metadata.name ?? '',
        fullPath: metadata.fullPath,
        bucket: metadata.bucket ?? '',
        size: metadata.size ?? 0,
        contentType: metadata.contentType,
        createdAt: metadata.timeCreated,
        updatedAt: metadata.updated,
        downloadUrl: await getDownloadUrl(storagePath),
      );
    } catch (e) {
      debugPrint('Error getting file metadata for $storagePath: $e');
      return null;
    }
  }

  // ========== File Deletion ==========

  /// Delete single file
  Future<bool> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      await ref.delete();

      // Remove from cache
      _urlCache.remove(storagePath);

      debugPrint('File deleted successfully: $storagePath');
      return true;
    } catch (e) {
      debugPrint('Error deleting file $storagePath: $e');
      return false;
    }
  }

  /// Delete multiple files
  Future<List<String>> deleteFiles(List<String> storagePaths) async {
    final failedDeletions = <String>[];

    for (final storagePath in storagePaths) {
      final success = await deleteFile(storagePath);
      if (!success) {
        failedDeletions.add(storagePath);
      }
    }

    return failedDeletions;
  }

  /// Delete hall images
  Future<bool> deleteHallImages({
    required String hallId,
    required List<String> imageUrls,
  }) async {
    try {
      final storagePaths = <String>[];

      // Extract storage paths from URLs
      for (final url in imageUrls) {
        final storagePath = _extractStoragePathFromUrl(url);
        if (storagePath != null) {
          storagePaths.add(storagePath);
        }
      }

      // Delete files from storage
      final failedDeletions = await deleteFiles(storagePaths);

      if (failedDeletions.isEmpty) {
        // Update hall document to remove image URLs
        await _firebaseService.update(
          collection: FirebaseConstants.hallsCollection,
          documentId: hallId,
          data: {
            FirebaseConstants.imageUrlsField: FieldValue.arrayRemove(imageUrls),
          },
        );

        debugPrint('Hall images deleted successfully');
        return true;
      } else {
        debugPrint('Failed to delete some hall images: $failedDeletions');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting hall images: $e');
      return false;
    }
  }

  /// Delete user folder (on account deletion)
  Future<void> deleteUserFolder(String userId) async {
    try {
      final userFolderRef = _storage.ref().child(FirebaseConstants.userAvatarsPath).child(userId);
      final listResult = await userFolderRef.listAll();

      // Delete all files in user folder
      for (final item in listResult.items) {
        await item.delete();
      }

      debugPrint('User folder deleted successfully: $userId');
    } catch (e) {
      debugPrint('Error deleting user folder $userId: $e');
    }
  }

  // ========== Storage Analytics ==========

  /// Get storage usage for user
  Future<StorageUsage> getUserStorageUsage(String userId) async {
    try {
      final userFolderRef = _storage.ref().child(FirebaseConstants.userAvatarsPath).child(userId);
      final listResult = await userFolderRef.listAll();

      int totalFiles = 0;
      int totalSize = 0;

      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalFiles++;
        totalSize += metadata.size ?? 0;
      }

      return StorageUsage(
        totalFiles: totalFiles,
        totalSizeBytes: totalSize,
        totalSizeMB: (totalSize / (1024 * 1024)).round(),
      );
    } catch (e) {
      debugPrint('Error getting user storage usage: $e');
      return StorageUsage(totalFiles: 0, totalSizeBytes: 0, totalSizeMB: 0);
    }
  }

  /// Get hall storage usage
  Future<StorageUsage> getHallStorageUsage(String hallId) async {
    try {
      final hallFolderRef = _storage.ref().child(FirebaseConstants.hallImagesPath).child(hallId);
      final listResult = await hallFolderRef.listAll();

      int totalFiles = 0;
      int totalSize = 0;

      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalFiles++;
        totalSize += metadata.size ?? 0;
      }

      return StorageUsage(
        totalFiles: totalFiles,
        totalSizeBytes: totalSize,
        totalSizeMB: (totalSize / (1024 * 1024)).round(),
      );
    } catch (e) {
      debugPrint('Error getting hall storage usage: $e');
      return StorageUsage(totalFiles: 0, totalSizeBytes: 0, totalSizeMB: 0);
    }
  }

  // ========== Upload Task Management ==========

  /// Cancel upload task
  Future<void> cancelUpload(String taskId) async {
    try {
      final task = _activeTasks[taskId];
      if (task != null) {
        await task.cancel();
        _activeTasks.remove(taskId);
        debugPrint('Upload task cancelled: $taskId');
      }
    } catch (e) {
      debugPrint('Error cancelling upload task $taskId: $e');
    }
  }

  /// Pause upload task
  Future<void> pauseUpload(String taskId) async {
    try {
      final task = _activeTasks[taskId];
      if (task != null) {
        await task.pause();
        debugPrint('Upload task paused: $taskId');
      }
    } catch (e) {
      debugPrint('Error pausing upload task $taskId: $e');
    }
  }

  /// Resume upload task
  Future<void> resumeUpload(String taskId) async {
    try {
      final task = _activeTasks[taskId];
      if (task != null) {
        await task.resume();
        debugPrint('Upload task resumed: $taskId');
      }
    } catch (e) {
      debugPrint('Error resuming upload task $taskId: $e');
    }
  }

  // ========== Private Helper Methods ==========

  /// Core file upload method
  Future<UploadResult> _uploadFile({
    required Uint8List data,
    required String storagePath,
    required String contentType,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final ref = _storage.ref(storagePath);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedBy': _authService.currentUser?.uid ?? 'unknown',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Start upload
      final uploadTask = ref.putData(data, metadata);
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      _activeTasks[taskId] = uploadTask;

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for completion
      final taskSnapshot = await uploadTask;
      _activeTasks.remove(taskId);

      // Get download URL
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Cache the URL
      _urlCache[storagePath] = downloadUrl;

      return UploadResult.success(
        message: 'File uploaded successfully',
        downloadUrl: downloadUrl,
        storagePath: storagePath,
      );

    } catch (e) {
      debugPrint('Error uploading file to $storagePath: $e');
      return UploadResult.failure('Upload failed: $e');
    }
  }

  /// Optimize image for upload
  Future<Uint8List> _optimizeImage(
      File imageFile, {
        required int maxWidth,
        required int maxHeight,
        required int quality,
      }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Could not decode image');
      }

      // Resize if necessary
      img.Image resizedImage = originalImage;
      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        resizedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? maxWidth : null,
          height: originalImage.height > originalImage.width ? maxHeight : null,
        );
      }

      // Encode as JPEG with specified quality
      final optimizedBytes = img.encodeJpg(resizedImage, quality: quality);

      debugPrint('Image optimized: ${imageBytes.length} -> ${optimizedBytes.length} bytes');

      return Uint8List.fromList(optimizedBytes);
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      // Return original if optimization fails
      return await imageFile.readAsBytes();
    }
  }

  /// Store document metadata in Firestore
  Future<void> _storeDocumentMetadata({
    required String ownerId,
    required String documentType,
    required String fileName,
    required String downloadUrl,
    required int fileSize,
  }) async {
    try {
      final docId = await IdGenerator.generateTransactionId();
      await _firebaseService.create(
        collection: 'document_metadata',
        documentId: docId,
        data: {
          'ownerId': ownerId,
          'documentType': documentType,
          'fileName': fileName,
          'downloadUrl': downloadUrl,
          'fileSize': fileSize,
          'status': 'uploaded',
        },
      );
    } catch (e) {
      debugPrint('Error storing document metadata: $e');
    }
  }

  /// Cleanup uploaded files on error
  Future<void> _cleanupUploadedFiles(List<String> downloadUrls) async {
    for (final url in downloadUrls) {
      final storagePath = _extractStoragePathFromUrl(url);
      if (storagePath != null) {
        await deleteFile(storagePath);
      }
    }
  }

  /// Extract storage path from download URL
  String? _extractStoragePathFromUrl(String downloadUrl) {
    try {
      final uri = Uri.parse(downloadUrl);
      final pathSegments = uri.pathSegments;

      // Find the path after '/o/' in Firebase Storage URLs
      final oIndex = pathSegments.indexOf('o');
      if (oIndex != -1 && oIndex + 1 < pathSegments.length) {
        final encodedPath = pathSegments[oIndex + 1];
        return Uri.decodeComponent(encodedPath);
      }

      return null;
    } catch (e) {
      debugPrint('Error extracting storage path from URL: $e');
      return null;
    }
  }

  /// Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // ========== Cache Management ==========

  /// Clear URL cache
  void clearCache() {
    _urlCache.clear();
    debugPrint('Storage URL cache cleared');
  }

  /// Get cache size
  int getCacheSize() {
    return _urlCache.length;
  }

  /// Remove specific URL from cache
  void removeCachedUrl(String storagePath) {
    _urlCache.remove(storagePath);
  }
}

// ========== Result Classes ==========

/// Upload result
class UploadResult {
  final bool success;
  final String message;
  final String? downloadUrl;
  final String? storagePath;
  final List<String>? downloadUrls;
  final String? error;

  UploadResult._({
    required this.success,
    required this.message,
    this.downloadUrl,
    this.storagePath,
    this.downloadUrls,
    this.error,
  });

  factory UploadResult.success({
    required String message,
    String? downloadUrl,
    String? storagePath,
    List<String>? downloadUrls,
  }) {
    return UploadResult._(
      success: true,
      message: message,
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      downloadUrls: downloadUrls,
    );
  }

  factory UploadResult.failure(String error) {
    return UploadResult._(
      success: false,
      message: error,
      error: error,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
}

/// Download result
class DownloadResult {
  final bool success;
  final String message;
  final String? localPath;
  final String? error;

  DownloadResult._({
    required this.success,
    required this.message,
    this.localPath,
    this.error,
  });

  factory DownloadResult.success({
    required String message,
    String? localPath,
  }) {
    return DownloadResult._(
      success: true,
      message: message,
      localPath: localPath,
    );
  }

  factory DownloadResult.failure(String error) {
    return DownloadResult._(
      success: false,
      message: error,
      error: error,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
}

/// File metadata
class FileMetadata {
  final String name;
  final String fullPath;
  final String bucket;
  final int size;
  final String? contentType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? downloadUrl;

  FileMetadata({
    required this.name,
    required this.fullPath,
    required this.bucket,
    required this.size,
    this.contentType,
    this.createdAt,
    this.updatedAt,
    this.downloadUrl,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Storage usage statistics
class StorageUsage {
  final int totalFiles;
  final int totalSizeBytes;
  final int totalSizeMB;

  StorageUsage({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.totalSizeMB,
  });

  String get formattedSize {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ========== Callback Types ==========

typedef UploadProgressCallback = void Function(double progress);
typedef DownloadProgressCallback = void Function(double progress);

/// Storage service exception
class StorageServiceException implements Exception {
  final String message;
  StorageServiceException(this.message);

  @override
  String toString() => 'StorageServiceException: $message';
}
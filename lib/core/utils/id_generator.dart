// core/utils/id_generator.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';

/// Generates structured IDs for all entities in the format: PREFIX_YYYYMMDD_XXX
/// Example: USR_20250706_001, HAL_20250706_042, BKG_20250706_156
class IdGenerator {
  static final IdGenerator _instance = IdGenerator._internal();
  factory IdGenerator() => _instance;
  IdGenerator._internal();

  // Cache for sequence numbers to improve performance
  static final Map<String, int> _sequenceCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration cacheExpiration = Duration(minutes: 5);

  // ID Prefixes for different entity types
  static const String userPrefix = 'USR';
  static const String adminPrefix = 'ADM';
  static const String ownerPrefix = 'OWN';
  static const String hallPrefix = 'HAL';
  static const String bookingPrefix = 'BKG';
  static const String paymentPrefix = 'PAY';
  static const String reviewPrefix = 'REV';
  static const String notificationPrefix = 'NOT';
  static const String categoryPrefix = 'CAT';
  static const String settingPrefix = 'SET';
  static const String transactionPrefix = 'TXN';
  static const String commissionPrefix = 'COM';
  static const String auditLogPrefix = 'LOG';
  static const String timeSlotPrefix = 'TS';
  static const String discountPrefix = 'DISC';

  // Sequence number length (3 digits = 001, 002, etc.)
  static const int sequenceLength = 3;

  /// Generate a new User ID
  static Future<String> generateUserId() async {
    return await _generateId(userPrefix, FirebaseConstants.usersCollection);
  }

  /// Generate a new Admin ID
  static Future<String> generateAdminId() async {
    return await _generateId(adminPrefix, FirebaseConstants.adminUsersCollection);
  }

  /// Generate a new Hall Owner ID
  static Future<String> generateOwnerId() async {
    return await _generateId(ownerPrefix, FirebaseConstants.hallOwnersCollection);
  }

  /// Generate a new Hall ID
  static Future<String> generateHallId() async {
    return await _generateId(hallPrefix, FirebaseConstants.hallsCollection);
  }

  /// Generate a new Booking ID
  static Future<String> generateBookingId() async {
    return await _generateId(bookingPrefix, FirebaseConstants.bookingsCollection);
  }

  /// Generate a new Payment ID
  static Future<String> generatePaymentId() async {
    return await _generateId(paymentPrefix, FirebaseConstants.paymentsCollection);
  }

  /// Generate a new Review ID
  static Future<String> generateReviewId() async {
    return await _generateId(reviewPrefix, FirebaseConstants.reviewsCollection);
  }

  /// Generate a new Notification ID
  static Future<String> generateNotificationId() async {
    return await _generateId(notificationPrefix, FirebaseConstants.notificationsCollection);
  }

  /// Generate a new Category ID
  static Future<String> generateCategoryId() async {
    return await _generateId(categoryPrefix, FirebaseConstants.categoriesCollection);
  }

  /// Generate a new Setting ID
  static Future<String> generateSettingId() async {
    return await _generateId(settingPrefix, FirebaseConstants.appSettingsCollection);
  }

  /// Generate a new Transaction ID
  static Future<String> generateTransactionId() async {
    return await _generateId(transactionPrefix, FirebaseConstants.transactionsCollection);
  }

  /// Generate a new Commission ID
  static Future<String> generateCommissionId() async {
    return await _generateId(commissionPrefix, FirebaseConstants.commissionsCollection);
  }

  /// Generate a new Audit Log ID
  static Future<String> generateAuditLogId() async {
    return await _generateId(auditLogPrefix, FirebaseConstants.auditLogsCollection);
  }

  /// Generate a new Time Slot ID (for hall time slots)
  static String generateTimeSlotId() {
    // Time slots don't need database sequences, just unique identifiers
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return '${timeSlotPrefix}_${timestamp}_${random.toString().padLeft(3, '0')}';
  }

  /// Generate a new Discount ID (for hall discounts)
  static String generateDiscountId() {
    // Discounts don't need database sequences, just unique identifiers
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return '${discountPrefix}_${timestamp}_${random.toString().padLeft(3, '0')}';
  }

  /// Core method to generate structured IDs
  static Future<String> _generateId(String prefix, String collection) async {
    try {
      final now = DateTime.now();
      final dateString = _formatDate(now);
      final cacheKey = '${prefix}_$dateString';

      // Check if we have a cached sequence number that's still valid
      if (_sequenceCache.containsKey(cacheKey) &&
          _cacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey]!;
        if (now.difference(cacheTime) < cacheExpiration) {
          final nextSequence = _sequenceCache[cacheKey]! + 1;
          _sequenceCache[cacheKey] = nextSequence;
          return _buildId(prefix, dateString, nextSequence);
        }
      }

      // Get the next sequence number from Firestore
      final sequence = await _getNextSequenceNumber(prefix, dateString, collection);

      // Update cache
      _sequenceCache[cacheKey] = sequence;
      _cacheTimestamps[cacheKey] = now;

      return _buildId(prefix, dateString, sequence);
    } catch (e) {
      // Fallback to timestamp-based ID if Firestore fails
      return _generateFallbackId(prefix);
    }
  }

  /// Get the next sequence number for a given prefix and date
  static Future<int> _getNextSequenceNumber(String prefix, String dateString, String collection) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefixPattern = '${prefix}_${dateString}_';

      // Query existing documents with the same prefix and date
      final querySnapshot = await firestore
          .collection(collection)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: prefixPattern)
          .where(FieldPath.documentId, isLessThan: '${prefixPattern}999')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 1; // First ID of the day
      }

      // Extract sequence number from the latest ID
      final latestId = querySnapshot.docs.first.id;
      final sequence = _extractSequenceNumber(latestId);
      return sequence + 1;
    } catch (e) {
      // If query fails, use a random number to avoid conflicts
      return Random().nextInt(900) + 100; // Random number between 100-999
    }
  }

  /// Build the final ID string
  static String _buildId(String prefix, String dateString, int sequence) {
    final sequenceString = sequence.toString().padLeft(sequenceLength, '0');
    return '${prefix}_${dateString}_$sequenceString';
  }

  /// Format date as YYYYMMDD
  static String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  /// Generate a fallback ID when Firestore is unavailable
  static String _generateFallbackId(String prefix) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return '${prefix}_FB_${timestamp}_${random.toString().padLeft(3, '0')}';
  }

  /// Extract sequence number from an existing ID
  static int _extractSequenceNumber(String id) {
    try {
      final parts = id.split('_');
      if (parts.length >= 3) {
        return int.parse(parts.last);
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ========== ID Validation and Parsing Methods ==========

  /// Validate if an ID has the correct format
  static bool isValidId(String id) {
    if (id.isEmpty) return false;

    final regex = RegExp(r'^[A-Z]+_(\d{8}|FB_\d+)_\d{3}$');
    return regex.hasMatch(id);
  }

  /// Validate if an ID belongs to a specific entity type
  static bool isValidEntityId(String id, String expectedPrefix) {
    if (!isValidId(id)) return false;
    return id.startsWith('${expectedPrefix}_');
  }

  /// Extract prefix from an ID
  static String? extractPrefix(String id) {
    try {
      final parts = id.split('_');
      return parts.isNotEmpty ? parts.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Extract date from an ID
  static DateTime? extractDate(String id) {
    try {
      final parts = id.split('_');
      if (parts.length >= 3 && parts[1] != 'FB') {
        final dateString = parts[1];
        if (dateString.length == 8) {
          final year = int.parse(dateString.substring(0, 4));
          final month = int.parse(dateString.substring(4, 6));
          final day = int.parse(dateString.substring(6, 8));
          return DateTime(year, month, day);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract sequence number from an ID
  static int? extractSequence(String id) {
    try {
      return _extractSequenceNumber(id);
    } catch (e) {
      return null;
    }
  }

  /// Check if an ID is a fallback ID (generated when Firestore was unavailable)
  static bool isFallbackId(String id) {
    return id.contains('_FB_');
  }

  /// Get entity type from ID prefix
  static String? getEntityType(String id) {
    final prefix = extractPrefix(id);
    if (prefix == null) return null;

    switch (prefix) {
      case userPrefix:
        return 'User';
      case adminPrefix:
        return 'Admin';
      case ownerPrefix:
        return 'Hall Owner';
      case hallPrefix:
        return 'Hall';
      case bookingPrefix:
        return 'Booking';
      case paymentPrefix:
        return 'Payment';
      case reviewPrefix:
        return 'Review';
      case notificationPrefix:
        return 'Notification';
      case categoryPrefix:
        return 'Category';
      case settingPrefix:
        return 'Setting';
      case transactionPrefix:
        return 'Transaction';
      case commissionPrefix:
        return 'Commission';
      case auditLogPrefix:
        return 'Audit Log';
      case timeSlotPrefix:
        return 'Time Slot';
      case discountPrefix:
        return 'Discount';
      default:
        return 'Unknown';
    }
  }

  // ========== Batch ID Generation ==========

  /// Generate multiple IDs at once for bulk operations
  static Future<List<String>> generateBatchIds(String prefix, String collection, int count) async {
    if (count <= 0) return [];

    final ids = <String>[];
    final now = DateTime.now();
    final dateString = _formatDate(now);

    try {
      // Get starting sequence number
      final startSequence = await _getNextSequenceNumber(prefix, dateString, collection);

      // Generate consecutive IDs
      for (int i = 0; i < count; i++) {
        final sequence = startSequence + i;
        ids.add(_buildId(prefix, dateString, sequence));
      }

      // Update cache with the last sequence number
      final cacheKey = '${prefix}_$dateString';
      _sequenceCache[cacheKey] = startSequence + count - 1;
      _cacheTimestamps[cacheKey] = now;

      return ids;
    } catch (e) {
      // Fallback to individual generation
      for (int i = 0; i < count; i++) {
        ids.add(_generateFallbackId(prefix));
      }
      return ids;
    }
  }

  // ========== Utility Methods ==========

  /// Clear the sequence cache (useful for testing or memory management)
  static void clearCache() {
    _sequenceCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _sequenceCache.length,
      'cacheEntries': _sequenceCache.keys.toList(),
      'lastUpdated': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }

  /// Generate a short ID for display purposes (last 6 characters)
  static String getShortId(String fullId) {
    if (fullId.length <= 6) return fullId;
    return fullId.substring(fullId.length - 6);
  }

  /// Generate a human-readable ID for display
  static String getDisplayId(String fullId) {
    final entityType = getEntityType(fullId);
    final shortId = getShortId(fullId);
    return '$entityType #$shortId';
  }

  // ========== ID Validation Specific Methods ==========

  /// Validate User ID
  static bool isValidUserId(String id) => isValidEntityId(id, userPrefix);

  /// Validate Admin ID
  static bool isValidAdminId(String id) => isValidEntityId(id, adminPrefix);

  /// Validate Owner ID
  static bool isValidOwnerId(String id) => isValidEntityId(id, ownerPrefix);

  /// Validate Hall ID
  static bool isValidHallId(String id) => isValidEntityId(id, hallPrefix);

  /// Validate Booking ID
  static bool isValidBookingId(String id) => isValidEntityId(id, bookingPrefix);

  /// Validate Payment ID
  static bool isValidPaymentId(String id) => isValidEntityId(id, paymentPrefix);

  /// Validate Review ID
  static bool isValidReviewId(String id) => isValidEntityId(id, reviewPrefix);

  /// Validate Notification ID
  static bool isValidNotificationId(String id) => isValidEntityId(id, notificationPrefix);

  // ========== Migration Helper Methods ==========

  /// Convert old unstructured IDs to new structured format (for migration)
  static Future<String> migrateToStructuredId(String oldId, String entityType) async {
    switch (entityType.toLowerCase()) {
      case 'user':
        return await generateUserId();
      case 'admin':
        return await generateAdminId();
      case 'owner':
        return await generateOwnerId();
      case 'hall':
        return await generateHallId();
      case 'booking':
        return await generateBookingId();
      case 'payment':
        return await generatePaymentId();
      case 'review':
        return await generateReviewId();
      case 'notification':
        return await generateNotificationId();
      default:
        throw ArgumentError('Unknown entity type: $entityType');
    }
  }

  /// Check if an ID needs migration (old format)
  static bool needsMigration(String id) {
    return !isValidId(id) && id.isNotEmpty;
  }
}
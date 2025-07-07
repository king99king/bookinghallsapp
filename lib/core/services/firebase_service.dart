// core/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';
import '../constants/app_constants.dart';
import '../utils/id_generator.dart';
import '../utils/validators.dart';

/// Comprehensive Firebase service for all database operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Enable offline persistence (call once during app initialization)
  static Future<void> initializeFirestore() async {
    try {
      if (!kIsWeb) {
        await FirebaseFirestore.instance.enablePersistence();
      }

      // Configure Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      debugPrint('Firestore initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firestore: $e');
    }
  }

  // ========== Base CRUD Operations ==========

  /// Create a new document with auto-generated ID
  Future<String> create({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      // Add timestamp fields
      final now = FieldValue.serverTimestamp();
      data[FirebaseConstants.createdAtField] = now;
      data[FirebaseConstants.updatedAtField] = now;

      DocumentReference docRef;
      if (documentId != null) {
        docRef = _firestore.collection(collection).doc(documentId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }

      debugPrint('Document created: ${docRef.id} in $collection');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating document in $collection: $e');
      throw FirebaseServiceException('Failed to create document: $e');
    }
  }

  /// Read a single document by ID
  Future<Map<String, dynamic>?> read({
    required String collection,
    required String documentId,
    bool useCache = true,
  }) async {
    try {
      final source = useCache ? Source.cache : Source.server;
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get(GetOptions(source: source));

      if (doc.exists) {
        final data = doc.data()!;
        data[FirebaseConstants.idField] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error reading document $documentId from $collection: $e');
      if (useCache) {
        // Fallback to server if cache fails
        return await read(
          collection: collection,
          documentId: documentId,
          useCache: false,
        );
      }
      throw FirebaseServiceException('Failed to read document: $e');
    }
  }

  /// Update an existing document
  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Add updated timestamp
      data[FirebaseConstants.updatedAtField] = FieldValue.serverTimestamp();

      await _firestore
          .collection(collection)
          .doc(documentId)
          .update(data);

      debugPrint('Document updated: $documentId in $collection');
    } catch (e) {
      debugPrint('Error updating document $documentId in $collection: $e');
      throw FirebaseServiceException('Failed to update document: $e');
    }
  }

  /// Delete a document
  Future<void> delete({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .delete();

      debugPrint('Document deleted: $documentId from $collection');
    } catch (e) {
      debugPrint('Error deleting document $documentId from $collection: $e');
      throw FirebaseServiceException('Failed to delete document: $e');
    }
  }

  /// Check if document exists
  Future<bool> exists({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking existence of $documentId in $collection: $e');
      return false;
    }
  }

  // ========== Query Operations ==========

  /// Get multiple documents with query
  Future<List<Map<String, dynamic>>> query({
    required String collection,
    List<QueryFilter>? filters,
    List<QuerySort>? sorts,
    int? limit,
    DocumentSnapshot? startAfter,
    bool useCache = true,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(
            filter.field,
            isEqualTo: filter.isEqualTo,
            isNotEqualTo: filter.isNotEqualTo,
            isLessThan: filter.isLessThan,
            isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
            isGreaterThan: filter.isGreaterThan,
            isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
            arrayContains: filter.arrayContains,
            arrayContainsAny: filter.arrayContainsAny,
            whereIn: filter.whereIn,
            whereNotIn: filter.whereNotIn,
            isNull: filter.isNull,
          );
        }
      }

      // Apply sorting
      if (sorts != null) {
        for (final sort in sorts) {
          query = query.orderBy(sort.field, descending: sort.descending);
        }
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      // Execute query
      final source = useCache ? Source.cache : Source.server;
      final snapshot = await query.get(GetOptions(source: source));

      // Convert to list with IDs
      final results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data[FirebaseConstants.idField] = doc.id;
        return data;
      }).toList();

      debugPrint('Query executed: ${results.length} documents from $collection');
      return results;
    } catch (e) {
      debugPrint('Error querying collection $collection: $e');
      if (useCache) {
        // Fallback to server if cache fails
        return await query(
          collection: collection,
          filters: filters,
          sorts: sorts,
          limit: limit,
          startAfter: startAfter,
          useCache: false,
        );
      }
      throw FirebaseServiceException('Failed to query documents: $e');
    }
  }

  /// Get real-time stream of documents
  Stream<List<Map<String, dynamic>>> stream({
    required String collection,
    List<QueryFilter>? filters,
    List<QuerySort>? sorts,
    int? limit,
  }) {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(
            filter.field,
            isEqualTo: filter.isEqualTo,
            isNotEqualTo: filter.isNotEqualTo,
            isLessThan: filter.isLessThan,
            isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
            isGreaterThan: filter.isGreaterThan,
            isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
            arrayContains: filter.arrayContains,
            arrayContainsAny: filter.arrayContainsAny,
            whereIn: filter.whereIn,
            whereNotIn: filter.whereNotIn,
            isNull: filter.isNull,
          );
        }
      }

      // Apply sorting
      if (sorts != null) {
        for (final sort in sorts) {
          query = query.orderBy(sort.field, descending: sort.descending);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data[FirebaseConstants.idField] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error creating stream for collection $collection: $e');
      throw FirebaseServiceException('Failed to create stream: $e');
    }
  }

  /// Count documents in collection
  Future<int> count({
    required String collection,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (filters != null) {
        for (final filter in filters) {
          query = query.where(
            filter.field,
            isEqualTo: filter.isEqualTo,
            isNotEqualTo: filter.isNotEqualTo,
            isLessThan: filter.isLessThan,
            isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
            isGreaterThan: filter.isGreaterThan,
            isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
            arrayContains: filter.arrayContains,
            arrayContainsAny: filter.arrayContainsAny,
            whereIn: filter.whereIn,
            whereNotIn: filter.whereNotIn,
            isNull: filter.isNull,
          );
        }
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error counting documents in $collection: $e');
      throw FirebaseServiceException('Failed to count documents: $e');
    }
  }

  // ========== User Management ==========

  /// Create user profile
  Future<String> createUser(Map<String, dynamic> userData) async {
    try {
      // Validate user data
      final validation = _validateUserData(userData);
      if (validation != null) {
        throw FirebaseServiceException('Invalid user data: $validation');
      }

      // Generate user ID if not provided
      final userId = userData[FirebaseConstants.userIdField] as String? ??
          await IdGenerator.generateUserId();

      userData[FirebaseConstants.userIdField] = userId;

      await create(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: userData,
      );

      return userId;
    } catch (e) {
      throw FirebaseServiceException('Failed to create user: $e');
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    return await read(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
    );
  }

  /// Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await update(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
      data: userData,
    );
  }

  /// Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    return await query(
      collection: FirebaseConstants.usersCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.userTypeField, userType),
        QueryFilter.equal(FirebaseConstants.isActiveField, true),
      ],
      sorts: [
        QuerySort(FirebaseConstants.createdAtField, descending: true),
      ],
    );
  }

  /// Search users
  Future<List<Map<String, dynamic>>> searchUsers({
    String? searchQuery,
    String? userType,
    String? governorate,
    int? limit,
  }) async {
    final filters = <QueryFilter>[];

    if (userType != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.userTypeField, userType));
    }

    if (governorate != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.governorateField, governorate));
    }

    filters.add(QueryFilter.equal(FirebaseConstants.isActiveField, true));

    return await query(
      collection: FirebaseConstants.usersCollection,
      filters: filters,
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: true)],
      limit: limit ?? AppConstants.searchResultsLimit,
    );
  }

  // ========== Hall Management ==========

  /// Create hall
  Future<String> createHall(Map<String, dynamic> hallData) async {
    try {
      // Generate hall ID
      final hallId = await IdGenerator.generateHallId();
      hallData[FirebaseConstants.hallIdField] = hallId;

      await create(
        collection: FirebaseConstants.hallsCollection,
        documentId: hallId,
        data: hallData,
      );

      return hallId;
    } catch (e) {
      throw FirebaseServiceException('Failed to create hall: $e');
    }
  }

  /// Get hall by ID
  Future<Map<String, dynamic>?> getHall(String hallId) async {
    return await read(
      collection: FirebaseConstants.hallsCollection,
      documentId: hallId,
    );
  }

  /// Get halls by owner
  Future<List<Map<String, dynamic>>> getHallsByOwner(String ownerId) async {
    return await query(
      collection: FirebaseConstants.hallsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.ownerIdField, ownerId),
      ],
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: true)],
    );
  }

  /// Search halls
  Future<List<Map<String, dynamic>>> searchHalls({
    String? searchQuery,
    List<String>? categoryIds,
    String? governorate,
    String? wilayat,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
    int? maxCapacity,
    bool? isApproved,
    bool? isAvailable,
    bool? isFeatured,
    int? limit,
  }) async {
    final filters = <QueryFilter>[];

    if (categoryIds != null && categoryIds.isNotEmpty) {
      filters.add(QueryFilter.arrayContainsAny(FirebaseConstants.categoryIdsField, categoryIds));
    }

    if (governorate != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.governorateField, governorate));
    }

    if (wilayat != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.wilayatField, wilayat));
    }

    if (minPrice != null) {
      filters.add(QueryFilter.greaterThanOrEqual(FirebaseConstants.basePriceField, minPrice));
    }

    if (maxPrice != null) {
      filters.add(QueryFilter.lessThanOrEqual(FirebaseConstants.basePriceField, maxPrice));
    }

    if (minCapacity != null) {
      filters.add(QueryFilter.greaterThanOrEqual(FirebaseConstants.capacityField, minCapacity));
    }

    if (maxCapacity != null) {
      filters.add(QueryFilter.lessThanOrEqual(FirebaseConstants.capacityField, maxCapacity));
    }

    if (isApproved != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.isApprovedField, isApproved));
    }

    if (isAvailable != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.isActiveField, isAvailable));
    }

    if (isFeatured != null) {
      filters.add(QueryFilter.equal(FirebaseConstants.isFeaturedField, isFeatured));
    }

    final sorts = <QuerySort>[];
    if (isFeatured == true) {
      sorts.add(QuerySort(FirebaseConstants.isFeaturedField, descending: true));
    }
    sorts.add(QuerySort(FirebaseConstants.createdAtField, descending: true));

    return await query(
      collection: FirebaseConstants.hallsCollection,
      filters: filters,
      sorts: sorts,
      limit: limit ?? AppConstants.searchResultsLimit,
    );
  }

  /// Get featured halls
  Future<List<Map<String, dynamic>>> getFeaturedHalls({int? limit}) async {
    return await query(
      collection: FirebaseConstants.hallsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.isFeaturedField, true),
        QueryFilter.equal(FirebaseConstants.isApprovedField, true),
        QueryFilter.equal(FirebaseConstants.isActiveField, true),
      ],
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: true)],
      limit: limit ?? 10,
    );
  }

  // ========== Booking Management ==========

  /// Create booking
  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    try {
      // Generate booking ID
      final bookingId = await IdGenerator.generateBookingId();
      bookingData[FirebaseConstants.bookingIdField] = bookingId;

      // Validate booking doesn't conflict
      await _validateBookingConflict(bookingData);

      await create(
        collection: FirebaseConstants.bookingsCollection,
        documentId: bookingId,
        data: bookingData,
      );

      return bookingId;
    } catch (e) {
      throw FirebaseServiceException('Failed to create booking: $e');
    }
  }

  /// Get booking by ID
  Future<Map<String, dynamic>?> getBooking(String bookingId) async {
    return await read(
      collection: FirebaseConstants.bookingsCollection,
      documentId: bookingId,
    );
  }

  /// Get bookings by user
  Future<List<Map<String, dynamic>>> getBookingsByUser(String userId) async {
    return await query(
      collection: FirebaseConstants.bookingsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.userIdField, userId),
      ],
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: true)],
    );
  }

  /// Get bookings by hall
  Future<List<Map<String, dynamic>>> getBookingsByHall(String hallId) async {
    return await query(
      collection: FirebaseConstants.bookingsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.hallIdField, hallId),
      ],
      sorts: [QuerySort(FirebaseConstants.eventDateField, descending: false)],
    );
  }

  /// Get bookings by date range
  Future<List<Map<String, dynamic>>> getBookingsByDateRange({
    required String hallId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? excludeStatuses,
  }) async {
    final filters = [
      QueryFilter.equal(FirebaseConstants.hallIdField, hallId),
      QueryFilter.greaterThanOrEqual(FirebaseConstants.eventDateField, startDate),
      QueryFilter.lessThanOrEqual(FirebaseConstants.eventDateField, endDate),
    ];

    if (excludeStatuses != null) {
      filters.add(QueryFilter.notIn(FirebaseConstants.statusField, excludeStatuses));
    }

    return await query(
      collection: FirebaseConstants.bookingsCollection,
      filters: filters,
      sorts: [QuerySort(FirebaseConstants.eventDateField, descending: false)],
    );
  }

  // ========== Payment Management ==========

  /// Create payment record
  Future<String> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final paymentId = await IdGenerator.generatePaymentId();
      paymentData[FirebaseConstants.paymentIdField] = paymentId;

      await create(
        collection: FirebaseConstants.paymentsCollection,
        documentId: paymentId,
        data: paymentData,
      );

      return paymentId;
    } catch (e) {
      throw FirebaseServiceException('Failed to create payment: $e');
    }
  }

  /// Get payments by booking
  Future<List<Map<String, dynamic>>> getPaymentsByBooking(String bookingId) async {
    return await query(
      collection: FirebaseConstants.paymentsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.bookingIdField, bookingId),
      ],
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: false)],
    );
  }

  /// Get payments by user
  Future<List<Map<String, dynamic>>> getPaymentsByUser(String userId) async {
    return await query(
      collection: FirebaseConstants.paymentsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.userIdField, userId),
      ],
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: true)],
    );
  }

  // ========== Review Management ==========

  /// Create review
  Future<String> createReview(Map<String, dynamic> reviewData) async {
    try {
      final reviewId = await IdGenerator.generateReviewId();
      reviewData[FirebaseConstants.reviewIdField] = reviewId;

      await create(
        collection: FirebaseConstants.reviewsCollection,
        documentId: reviewId,
        data: reviewData,
      );

      return reviewId;
    } catch (e) {
      throw FirebaseServiceException('Failed to create review: $e');
    }
  }

  /// Get reviews by hall
  Future<List<Map<String, dynamic>>> getReviewsByHall(String hallId) async {
    return await query(
      collection: FirebaseConstants.reviewsCollection,
      filters: [
        QueryFilter.equal(FirebaseConstants.hallIdField, hallId),
        QueryFilter.equal(FirebaseConstants.isApprovedField, true),
      ],
      sorts: [QuerySort(FirebaseConstants.createdAtField, descending: true)],
    );
  }

  // ========== Batch Operations ==========

  /// Perform batch write
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final docRef = _firestore.collection(operation.collection).doc(operation.documentId);

        switch (operation.type) {
          case BatchOperationType.create:
          case BatchOperationType.set:
            batch.set(docRef, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      debugPrint('Batch operation completed: ${operations.length} operations');
    } catch (e) {
      debugPrint('Error in batch operation: $e');
      throw FirebaseServiceException('Failed to perform batch operation: $e');
    }
  }

  /// Perform transaction
  Future<T> transaction<T>(Future<T> Function(Transaction) transactionHandler) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      debugPrint('Error in transaction: $e');
      throw FirebaseServiceException('Failed to perform transaction: $e');
    }
  }

  // ========== Validation Helpers ==========

  /// Validate user data
  String? _validateUserData(Map<String, dynamic> userData) {
    final email = userData[FirebaseConstants.emailField] as String?;
    if (email != null) {
      final emailValidation = Validators.validateEmail(email);
      if (emailValidation != null) return emailValidation;
    }

    final userType = userData[FirebaseConstants.userTypeField] as String?;
    if (userType != null) {
      final userTypeValidation = Validators.validateUserType(userType);
      if (userTypeValidation != null) return userTypeValidation;
    }

    return null;
  }

  /// Validate booking conflict
  Future<void> _validateBookingConflict(Map<String, dynamic> bookingData) async {
    final hallId = bookingData[FirebaseConstants.hallIdField] as String;
    final eventDate = bookingData[FirebaseConstants.eventDateField] as DateTime;
    final timeSlot = bookingData[FirebaseConstants.timeSlotField] as Map<String, dynamic>?;

    if (timeSlot == null) return;

    final startTime = timeSlot['startTime'] as String;
    final endTime = timeSlot['endTime'] as String;

    // Get existing bookings for the same hall and date
    final existingBookings = await getBookingsByDateRange(
      hallId: hallId,
      startDate: eventDate,
      endDate: eventDate,
      excludeStatuses: [FirebaseConstants.cancelledBookingStatus],
    );

    // Check for conflicts
    for (final booking in existingBookings) {
      final existingTimeSlot = booking[FirebaseConstants.timeSlotField] as Map<String, dynamic>?;
      if (existingTimeSlot != null) {
        final existingStart = existingTimeSlot['startTime'] as String;
        final existingEnd = existingTimeSlot['endTime'] as String;

        // Check if time slots overlap
        if (_timeSlotOverlap(startTime, endTime, existingStart, existingEnd)) {
          throw FirebaseServiceException('Time slot conflict detected');
        }
      }
    }
  }

  /// Check if two time slots overlap
  bool _timeSlotOverlap(String start1, String end1, String start2, String end2) {
    try {
      final start1Time = _parseTime(start1);
      final end1Time = _parseTime(end1);
      final start2Time = _parseTime(start2);
      final end2Time = _parseTime(end2);

      return start1Time.isBefore(end2Time) && start2Time.isBefore(end1Time);
    } catch (e) {
      return false;
    }
  }

  /// Parse time string to comparable DateTime
  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hour, minute);
  }

  // ========== Cache Management ==========

  /// Clear Firestore cache
  Future<void> clearCache() async {
    try {
      await _firestore.clearPersistence();
      debugPrint('Firestore cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Enable/disable network
  Future<void> enableNetwork() async {
    try {
      await _firestore.enableNetwork();
      debugPrint('Firestore network enabled');
    } catch (e) {
      debugPrint('Error enabling network: $e');
    }
  }

  Future<void> disableNetwork() async {
    try {
      await _firestore.disableNetwork();
      debugPrint('Firestore network disabled');
    } catch (e) {
      debugPrint('Error disabling network: $e');
    }
  }
}

// ========== Helper Classes ==========

/// Query filter for Firestore queries
class QueryFilter {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  final bool? isNull;

  QueryFilter({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });

  factory QueryFilter.equal(String field, dynamic value) {
    return QueryFilter(field: field, isEqualTo: value);
  }

  factory QueryFilter.notEqual(String field, dynamic value) {
    return QueryFilter(field: field, isNotEqualTo: value);
  }

  factory QueryFilter.lessThan(String field, dynamic value) {
    return QueryFilter(field: field, isLessThan: value);
  }

  factory QueryFilter.lessThanOrEqual(String field, dynamic value) {
    return QueryFilter(field: field, isLessThanOrEqualTo: value);
  }

  factory QueryFilter.greaterThan(String field, dynamic value) {
    return QueryFilter(field: field, isGreaterThan: value);
  }

  factory QueryFilter.greaterThanOrEqual(String field, dynamic value) {
    return QueryFilter(field: field, isGreaterThanOrEqualTo: value);
  }

  factory QueryFilter.arrayContains(String field, dynamic value) {
    return QueryFilter(field: field, arrayContains: value);
  }

  factory QueryFilter.arrayContainsAny(String field, List<dynamic> values) {
    return QueryFilter(field: field, arrayContainsAny: values);
  }

  factory QueryFilter.whereIn(String field, List<dynamic> values) {
    return QueryFilter(field: field, whereIn: values);
  }

  factory QueryFilter.notIn(String field, List<dynamic> values) {
    return QueryFilter(field: field, whereNotIn: values);
  }

  factory QueryFilter.isNull(String field) {
    return QueryFilter(field: field, isNull: true);
  }
}

/// Query sort for Firestore queries
class QuerySort {
  final String field;
  final bool descending;

  QuerySort(this.field, {this.descending = false});
}

/// Batch operation for batch writes
class BatchOperation {
  final BatchOperationType type;
  final String collection;
  final String documentId;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.collection,
    required this.documentId,
    this.data,
  });

  factory BatchOperation.create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return BatchOperation(
      type: BatchOperationType.create,
      collection: collection,
      documentId: documentId,
      data: data,
    );
  }

  factory BatchOperation.update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return BatchOperation(
      type: BatchOperationType.update,
      collection: collection,
      documentId: documentId,
      data: data,
    );
  }

  factory BatchOperation.delete({
    required String collection,
    required String documentId,
  }) {
    return BatchOperation(
      type: BatchOperationType.delete,
      collection: collection,
      documentId: documentId,
    );
  }
}

/// Batch operation types
enum BatchOperationType { create, set, update, delete }

/// Firebase service exception
class FirebaseServiceException implements Exception {
  final String message;
  FirebaseServiceException(this.message);

  @override
  String toString() => 'FirebaseServiceException: $message';
}
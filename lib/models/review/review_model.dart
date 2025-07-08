// models/review/review_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';

/// Comprehensive review model for hall and booking reviews
class ReviewModel {
  final String reviewId;
  final String bookingId;
  final String hallId;
  final String userId;
  final String ownerId;
  final double rating;
  final String comment;
  final String? commentArabic;
  final List<String> images;
  final List<ReviewTag> tags;
  final ReviewStatus status;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? ownerResponse;
  final String? ownerResponseArabic;
  final DateTime? ownerResponseDate;
  final bool isVerifiedBooking;
  final int helpfulCount;
  final int reportCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final List<ReviewModerationHistory> moderationHistory;

  ReviewModel({
    required this.reviewId,
    required this.bookingId,
    required this.hallId,
    required this.userId,
    required this.ownerId,
    required this.rating,
    required this.comment,
    this.commentArabic,
    this.images = const [],
    this.tags = const [],
    this.status = ReviewStatus.pending,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.ownerResponse,
    this.ownerResponseArabic,
    this.ownerResponseDate,
    this.isVerifiedBooking = true,
    this.helpfulCount = 0,
    this.reportCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
    this.moderationHistory = const [],
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ========== Factory Constructors ==========

  /// Create from Firestore document
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReviewModel(
        reviewId: Validators.validateString(json[FirebaseConstants.reviewIdField], 'Review ID'),
        bookingId: Validators.validateString(json[FirebaseConstants.bookingIdField], 'Booking ID'),
        hallId: Validators.validateString(json[FirebaseConstants.hallIdField], 'Hall ID'),
        userId: Validators.validateString(json[FirebaseConstants.userIdField], 'User ID'),
        ownerId: Validators.validateString(json[FirebaseConstants.ownerIdField], 'Owner ID'),
        rating: (json[FirebaseConstants.ratingField] as num?)?.toDouble() ?? 0.0,
        comment: Validators.validateString(json[FirebaseConstants.commentField], 'Comment'),
        commentArabic: json[FirebaseConstants.commentArabicField] as String?,
        images: List<String>.from(json[FirebaseConstants.imagesField] as List<dynamic>? ?? []),
        tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => ReviewTag.values.firstWhere(
              (tag) => tag.name == e,
          orElse: () => ReviewTag.general,
        ))
            .toList() ?? [],
        status: ReviewStatus.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.statusField],
          orElse: () => ReviewStatus.pending,
        ),
        isApproved: json[FirebaseConstants.isApprovedField] as bool? ?? false,
        approvedBy: json[FirebaseConstants.approvedByField] as String?,
        approvedAt: DateUtils.parseTimestamp(json[FirebaseConstants.approvedAtField]),
        rejectionReason: json['rejectionReason'] as String?,
        ownerResponse: json[FirebaseConstants.ownerResponseField] as String?,
        ownerResponseArabic: json['ownerResponseArabic'] as String?,
        ownerResponseDate: DateUtils.parseTimestamp(json[FirebaseConstants.ownerResponseDateField]),
        isVerifiedBooking: json['isVerifiedBooking'] as bool? ?? true,
        helpfulCount: json['helpfulCount'] as int? ?? 0,
        reportCount: json['reportCount'] as int? ?? 0,
        createdAt: DateUtils.parseTimestamp(json[FirebaseConstants.createdAtField]) ?? DateTime.now(),
        updatedAt: DateUtils.parseTimestamp(json[FirebaseConstants.updatedAtField]) ?? DateTime.now(),
        metadata: json['metadata'] as Map<String, dynamic>?,
        moderationHistory: (json['moderationHistory'] as List<dynamic>?)
            ?.map((e) => ReviewModerationHistory.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      throw ModelParseException('Failed to parse ReviewModel: $e');
    }
  }

  /// Create new review
  factory ReviewModel.create({
    required String bookingId,
    required String hallId,
    required String userId,
    required String ownerId,
    required double rating,
    required String comment,
    String? commentArabic,
    List<String>? images,
    List<ReviewTag>? tags,
    bool isVerifiedBooking = true,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();

    return ReviewModel(
      reviewId: '', // Will be generated by service
      bookingId: bookingId,
      hallId: hallId,
      userId: userId,
      ownerId: ownerId,
      rating: rating,
      comment: comment,
      commentArabic: commentArabic,
      images: images ?? [],
      tags: tags ?? [],
      status: ReviewStatus.pending,
      isVerifiedBooking: isVerifiedBooking,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
      moderationHistory: [
        ReviewModerationHistory(
          action: ModerationAction.submitted,
          timestamp: now,
          performedBy: userId,
          notes: 'Review submitted',
        ),
      ],
    );
  }

  // ========== Serialization ==========

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.reviewIdField: reviewId,
      FirebaseConstants.bookingIdField: bookingId,
      FirebaseConstants.hallIdField: hallId,
      FirebaseConstants.userIdField: userId,
      FirebaseConstants.ownerIdField: ownerId,
      FirebaseConstants.ratingField: rating,
      FirebaseConstants.commentField: comment,
      FirebaseConstants.commentArabicField: commentArabic,
      FirebaseConstants.imagesField: images,
      'tags': tags.map((t) => t.name).toList(),
      FirebaseConstants.statusField: status.name,
      FirebaseConstants.isApprovedField: isApproved,
      FirebaseConstants.approvedByField: approvedBy,
      FirebaseConstants.approvedAtField: approvedAt != null
          ? Timestamp.fromDate(approvedAt!)
          : null,
      'rejectionReason': rejectionReason,
      FirebaseConstants.ownerResponseField: ownerResponse,
      'ownerResponseArabic': ownerResponseArabic,
      FirebaseConstants.ownerResponseDateField: ownerResponseDate != null
          ? Timestamp.fromDate(ownerResponseDate!)
          : null,
      'isVerifiedBooking': isVerifiedBooking,
      'helpfulCount': helpfulCount,
      'reportCount': reportCount,
      FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
      FirebaseConstants.updatedAtField: FieldValue.serverTimestamp(),
      'metadata': metadata,
      'moderationHistory': moderationHistory.map((h) => h.toJson()).toList(),
    };
  }

  // ========== Business Logic Methods ==========

  /// Check if review is pending approval
  bool isPending() => status == ReviewStatus.pending;

  /// Check if review is approved
  bool isReviewApproved() => isApproved && status == ReviewStatus.approved;

  /// Check if review is rejected
  bool isRejected() => status == ReviewStatus.rejected;

  /// Check if review is flagged
  bool isFlagged() => status == ReviewStatus.flagged;

  /// Check if review has owner response
  bool hasOwnerResponse() => ownerResponse?.isNotEmpty == true;

  /// Check if review can be edited
  bool canBeEdited() {
    final hoursSinceCreated = DateTime.now().difference(createdAt).inHours;
    return status == ReviewStatus.pending &&
        hoursSinceCreated <= AppConstants.reviewEditTimeLimit;
  }

  /// Check if review can be deleted
  bool canBeDeleted(String requestingUserId) {
    return userId == requestingUserId &&
        (status == ReviewStatus.pending || !isApproved);
  }

  /// Check if owner can respond
  bool canOwnerRespond() {
    return isApproved && !hasOwnerResponse();
  }

  /// Check if review needs moderation
  bool needsModeration() {
    return reportCount >= AppConstants.reviewAutoModerationThreshold ||
        _containsInappropriateContent();
  }

  /// Get review age in days
  int getAgeInDays() {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get star distribution (for UI)
  List<bool> getStarDistribution() {
    return List.generate(5, (index) => index < rating.floor());
  }

  /// Get localized comment
  String getLocalizedComment(String languageCode) {
    if (languageCode == 'ar' && commentArabic?.isNotEmpty == true) {
      return commentArabic!;
    }
    return comment;
  }

  /// Get localized owner response
  String? getLocalizedOwnerResponse(String languageCode) {
    if (languageCode == 'ar' && ownerResponseArabic?.isNotEmpty == true) {
      return ownerResponseArabic;
    }
    return ownerResponse;
  }

  /// Get review summary for display
  String getReviewSummary({int maxLength = 100}) {
    final text = comment.length <= maxLength
        ? comment
        : '${comment.substring(0, maxLength)}...';
    return text;
  }

  /// Get rating display text
  String getRatingDisplayText(String languageCode) {
    final ratingTexts = {
      5.0: {'en': 'Excellent', 'ar': 'ممتاز'},
      4.0: {'en': 'Very Good', 'ar': 'جيد جداً'},
      3.0: {'en': 'Good', 'ar': 'جيد'},
      2.0: {'en': 'Fair', 'ar': 'مقبول'},
      1.0: {'en': 'Poor', 'ar': 'ضعيف'},
    };

    return ratingTexts[rating]?[languageCode] ?? '${rating.toStringAsFixed(1)} Stars';
  }

  /// Get status display text
  String getStatusDisplayText(String languageCode) {
    final statusTranslations = {
      'pending': {'en': 'Pending Review', 'ar': 'في انتظار المراجعة'},
      'approved': {'en': 'Approved', 'ar': 'موافق عليه'},
      'rejected': {'en': 'Rejected', 'ar': 'مرفوض'},
      'flagged': {'en': 'Flagged', 'ar': 'مبلغ عنه'},
      'hidden': {'en': 'Hidden', 'ar': 'مخفي'},
    };

    return statusTranslations[status.name]?[languageCode] ?? status.name;
  }

  /// Get formatted date
  String getFormattedDate(String languageCode) {
    return DateUtils.formatDate(createdAt, languageCode: languageCode);
  }

  /// Check if review is helpful
  bool isHelpful() {
    return helpfulCount > reportCount && helpfulCount >= AppConstants.minHelpfulVotes;
  }

  // ========== Update Methods ==========

  /// Approve review
  ReviewModel approve(String approvedBy) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.approved,
        timestamp: now,
        performedBy: approvedBy,
        notes: 'Review approved for publication',
      ));

    return copyWith(
      status: ReviewStatus.approved,
      isApproved: true,
      approvedBy: approvedBy,
      approvedAt: now,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Reject review
  ReviewModel reject(String rejectedBy, String reason) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.rejected,
        timestamp: now,
        performedBy: rejectedBy,
        notes: 'Review rejected: $reason',
      ));

    return copyWith(
      status: ReviewStatus.rejected,
      isApproved: false,
      rejectionReason: reason,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Flag review
  ReviewModel flag(String flaggedBy, String reason) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.flagged,
        timestamp: now,
        performedBy: flaggedBy,
        notes: 'Review flagged: $reason',
      ));

    return copyWith(
      status: ReviewStatus.flagged,
      reportCount: reportCount + 1,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Add owner response
  ReviewModel addOwnerResponse({
    required String response,
    String? responseArabic,
  }) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.ownerResponse,
        timestamp: now,
        performedBy: ownerId,
        notes: 'Owner responded to review',
      ));

    return copyWith(
      ownerResponse: response,
      ownerResponseArabic: responseArabic,
      ownerResponseDate: now,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Update owner response
  ReviewModel updateOwnerResponse({
    required String response,
    String? responseArabic,
  }) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.ownerResponseUpdated,
        timestamp: now,
        performedBy: ownerId,
        notes: 'Owner response updated',
      ));

    return copyWith(
      ownerResponse: response,
      ownerResponseArabic: responseArabic,
      ownerResponseDate: now,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Mark as helpful
  ReviewModel markAsHelpful() {
    return copyWith(
      helpfulCount: helpfulCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// Report review
  ReviewModel report(String reportedBy, String reason) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.reported,
        timestamp: now,
        performedBy: reportedBy,
        notes: 'Review reported: $reason',
      ));

    return copyWith(
      reportCount: reportCount + 1,
      status: needsModeration() ? ReviewStatus.flagged : status,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Hide review
  ReviewModel hide(String hiddenBy, String reason) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.hidden,
        timestamp: now,
        performedBy: hiddenBy,
        notes: 'Review hidden: $reason',
      ));

    return copyWith(
      status: ReviewStatus.hidden,
      isApproved: false,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  /// Update content
  ReviewModel updateContent({
    double? newRating,
    String? newComment,
    String? newCommentArabic,
    List<String>? newImages,
    List<ReviewTag>? newTags,
  }) {
    final now = DateTime.now();
    final newHistory = List<ReviewModerationHistory>.from(moderationHistory)
      ..add(ReviewModerationHistory(
        action: ModerationAction.edited,
        timestamp: now,
        performedBy: userId,
        notes: 'Review content updated',
      ));

    return copyWith(
      rating: newRating ?? rating,
      comment: newComment ?? comment,
      commentArabic: newCommentArabic ?? commentArabic,
      images: newImages ?? images,
      tags: newTags ?? tags,
      status: ReviewStatus.pending, // Reset to pending after edit
      isApproved: false,
      updatedAt: now,
      moderationHistory: newHistory,
    );
  }

  // ========== Private Helper Methods ==========

  bool _containsInappropriateContent() {
    // Basic content filtering - you can expand this
    final inappropriateWords = AppConstants.inappropriateWords;
    final textToCheck = '$comment ${commentArabic ?? ''}'.toLowerCase();

    return inappropriateWords.any((word) => textToCheck.contains(word.toLowerCase()));
  }

  // ========== Copy With ==========

  ReviewModel copyWith({
    String? reviewId,
    String? bookingId,
    String? hallId,
    String? userId,
    String? ownerId,
    double? rating,
    String? comment,
    String? commentArabic,
    List<String>? images,
    List<ReviewTag>? tags,
    ReviewStatus? status,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    String? ownerResponse,
    String? ownerResponseArabic,
    DateTime? ownerResponseDate,
    bool? isVerifiedBooking,
    int? helpfulCount,
    int? reportCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    List<ReviewModerationHistory>? moderationHistory,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      bookingId: bookingId ?? this.bookingId,
      hallId: hallId ?? this.hallId,
      userId: userId ?? this.userId,
      ownerId: ownerId ?? this.ownerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      commentArabic: commentArabic ?? this.commentArabic,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      ownerResponse: ownerResponse ?? this.ownerResponse,
      ownerResponseArabic: ownerResponseArabic ?? this.ownerResponseArabic,
      ownerResponseDate: ownerResponseDate ?? this.ownerResponseDate,
      isVerifiedBooking: isVerifiedBooking ?? this.isVerifiedBooking,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      moderationHistory: moderationHistory ?? this.moderationHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.reviewId == reviewId;
  }

  @override
  int get hashCode => reviewId.hashCode;

  @override
  String toString() => 'ReviewModel(id: $reviewId, rating: $rating, hall: $hallId)';
}

// ========== Supporting Enums ==========

/// Review status enum
enum ReviewStatus {
  pending,
  approved,
  rejected,
  flagged,
  hidden,
}

/// Review tags for categorization
enum ReviewTag {
  general,
  cleanliness,
  service,
  location,
  value,
  facilities,
  staff,
  food,
  ambiance,
  parking,
  accessibility,
}

/// Moderation action enum
enum ModerationAction {
  submitted,
  approved,
  rejected,
  flagged,
  hidden,
  reported,
  edited,
  ownerResponse,
  ownerResponseUpdated,
}

// ========== Supporting Models ==========

/// Review moderation history tracking
class ReviewModerationHistory {
  final ModerationAction action;
  final DateTime timestamp;
  final String performedBy;
  final String? notes;
  final Map<String, dynamic>? metadata;

  ReviewModerationHistory({
    required this.action,
    required this.timestamp,
    required this.performedBy,
    this.notes,
    this.metadata,
  });

  factory ReviewModerationHistory.fromJson(Map<String, dynamic> json) {
    return ReviewModerationHistory(
      action: ModerationAction.values.firstWhere(
            (e) => e.name == json['action'],
        orElse: () => ModerationAction.submitted,
      ),
      timestamp: DateUtils.parseTimestamp(json['timestamp']) ?? DateTime.now(),
      performedBy: json['performedBy'] as String,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'performedBy': performedBy,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

/// Review statistics for analytics
class ReviewStatistics {
  final String hallId;
  final double averageRating;
  final int totalReviews;
  final int approvedReviews;
  final int pendingReviews;
  final int rejectedReviews;
  final Map<int, int> ratingDistribution;
  final Map<ReviewTag, int> tagDistribution;
  final double responseRate;
  final DateTime? lastReviewDate;

  ReviewStatistics({
    required this.hallId,
    required this.averageRating,
    required this.totalReviews,
    required this.approvedReviews,
    required this.pendingReviews,
    required this.rejectedReviews,
    required this.ratingDistribution,
    required this.tagDistribution,
    required this.responseRate,
    this.lastReviewDate,
  });

  factory ReviewStatistics.fromReviews(String hallId, List<ReviewModel> reviews) {
    final approvedReviews = reviews.where((r) => r.isApproved).toList();
    final pendingReviews = reviews.where((r) => r.isPending()).toList();
    final rejectedReviews = reviews.where((r) => r.isRejected()).toList();

    // Calculate average rating
    final totalRating = approvedReviews.fold(0.0, (sum, review) => sum + review.rating);
    final averageRating = approvedReviews.isNotEmpty ? totalRating / approvedReviews.length : 0.0;

    // Rating distribution
    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = approvedReviews.where((r) => r.rating.floor() == i).length;
    }

    // Tag distribution
    final tagDistribution = <ReviewTag, int>{};
    for (final tag in ReviewTag.values) {
      tagDistribution[tag] = approvedReviews
          .where((r) => r.tags.contains(tag))
          .length;
    }

    // Response rate
    final reviewsWithResponse = approvedReviews.where((r) => r.hasOwnerResponse()).length;
    final responseRate = approvedReviews.isNotEmpty
        ? reviewsWithResponse / approvedReviews.length
        : 0.0;

    // Last review date
    DateTime? lastReviewDate;
    if (reviews.isNotEmpty) {
      lastReviewDate = reviews
          .map((r) => r.createdAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return ReviewStatistics(
      hallId: hallId,
      averageRating: averageRating,
      totalReviews: reviews.length,
      approvedReviews: approvedReviews.length,
      pendingReviews: pendingReviews.length,
      rejectedReviews: rejectedReviews.length,
      ratingDistribution: ratingDistribution,
      tagDistribution: tagDistribution,
      responseRate: responseRate,
      lastReviewDate: lastReviewDate,
    );
  }

  /// Get approval rate
  double getApprovalRate() {
    if (totalReviews == 0) return 0.0;
    return approvedReviews / totalReviews;
  }

  /// Get rating percentage for specific star
  double getRatingPercentage(int stars) {
    if (approvedReviews == 0) return 0.0;
    return (ratingDistribution[stars] ?? 0) / approvedReviews;
  }

  @override
  String toString() => 'ReviewStatistics(hall: $hallId, avg: $averageRating, total: $totalReviews)';
}

/// Custom exception for review model parsing errors
class ModelParseException implements Exception {
  final String message;
  ModelParseException(this.message);

  @override
  String toString() => 'ModelParseException: $message';
}
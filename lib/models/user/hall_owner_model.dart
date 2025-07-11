// models/user/hall_owner_model.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/price_calculator.dart';

/// Hall owner model with business data and earnings tracking
class HallOwnerModel {
  final String ownerId;
  final String userId;
  final String? businessName;
  final String? businessNameArabic;
  final String? businessLicense;
  final String? taxNumber;
  final BankDetails? bankDetails;
  final CommissionSettings commissionSettings;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final bool isActive;
  final double totalEarnings;
  final int totalBookings;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OwnerStatistics? statistics;
  final List<BusinessDocument> businessDocuments;

  HallOwnerModel({
    required this.ownerId,
    required this.userId,
    this.businessName,
    this.businessNameArabic,
    this.businessLicense,
    this.taxNumber,
    this.bankDetails,
    CommissionSettings? commissionSettings,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.isActive = true,
    this.totalEarnings = 0.0,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.statistics,
    this.businessDocuments = const [],
  }) :
        commissionSettings = commissionSettings ?? CommissionSettings.defaultSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ========== Factory Constructors ==========

  /// Create from Firestore document
  factory HallOwnerModel.fromJson(Map<String, dynamic> json) {
    try {
      return HallOwnerModel(
        ownerId: json[FirebaseConstants.ownerIdField] as String,
        userId: json[FirebaseConstants.userIdField] as String,
        businessName: json[FirebaseConstants.businessNameField] as String?,
        businessNameArabic: json[FirebaseConstants.businessNameArabicField] as String?,
        businessLicense: json[FirebaseConstants.businessLicenseField] as String?,
        taxNumber: json[FirebaseConstants.taxNumberField] as String?,
        bankDetails: json[FirebaseConstants.bankDetailsField] != null
            ? BankDetails.fromJson(json[FirebaseConstants.bankDetailsField] as Map<String, dynamic>)
            : null,
        commissionSettings: CommissionSettings.fromJson(
            json[FirebaseConstants.commissionSettingsField] as Map<String, dynamic>? ?? {}
        ),
        isApproved: json[FirebaseConstants.isApprovedField] as bool? ?? false,
        approvedBy: json[FirebaseConstants.approvedByField] as String?,
        approvedAt: DateUtils.parseISODate(json[FirebaseConstants.approvedAtField] as String?),
        isActive: json[FirebaseConstants.isActiveField] as bool? ?? true,
        totalEarnings: (json[FirebaseConstants.totalEarningsField] as num?)?.toDouble() ?? 0.0,
        totalBookings: json[FirebaseConstants.totalBookingsField] as int? ?? 0,
        rating: (json[FirebaseConstants.ratingField] as num?)?.toDouble() ?? 0.0,
        reviewCount: json[FirebaseConstants.reviewCountField] as int? ?? 0,
        createdAt: DateUtils.parseISODate(json[FirebaseConstants.createdAtField] as String?) ?? DateTime.now(),
        updatedAt: DateUtils.parseISODate(json[FirebaseConstants.updatedAtField] as String?) ?? DateTime.now(),
        statistics: json['statistics'] != null
            ? OwnerStatistics.fromJson(json['statistics'] as Map<String, dynamic>)
            : null,
        businessDocuments: (json['businessDocuments'] as List<dynamic>?)
            ?.map((doc) => BusinessDocument.fromJson(doc as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      debugPrint('Error parsing HallOwnerModel from JSON: $e');
      rethrow;
    }
  }

  /// Create new hall owner
  factory HallOwnerModel.createNew({
    required String userId,
    String? businessName,
    String? businessNameArabic,
  }) {
    return HallOwnerModel(
      ownerId: '', // Will be generated by service
      userId: userId,
      businessName: businessName,
      businessNameArabic: businessNameArabic,
      commissionSettings: CommissionSettings.defaultSettings(),
    );
  }

  // ========== JSON Conversion ==========

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.ownerIdField: ownerId,
      FirebaseConstants.userIdField: userId,
      FirebaseConstants.businessNameField: businessName,
      FirebaseConstants.businessNameArabicField: businessNameArabic,
      FirebaseConstants.businessLicenseField: businessLicense,
      FirebaseConstants.taxNumberField: taxNumber,
      FirebaseConstants.bankDetailsField: bankDetails?.toJson(),
      FirebaseConstants.commissionSettingsField: commissionSettings.toJson(),
      FirebaseConstants.isApprovedField: isApproved,
      FirebaseConstants.approvedByField: approvedBy,
      FirebaseConstants.approvedAtField: approvedAt != null ? DateUtils.toISOString(approvedAt!) : null,
      FirebaseConstants.isActiveField: isActive,
      FirebaseConstants.totalEarningsField: totalEarnings,
      FirebaseConstants.totalBookingsField: totalBookings,
      FirebaseConstants.ratingField: rating,
      FirebaseConstants.reviewCountField: reviewCount,
      FirebaseConstants.createdAtField: DateUtils.toISOString(createdAt),
      FirebaseConstants.updatedAtField: DateUtils.toISOString(updatedAt),
      'statistics': statistics?.toJson(),
      'businessDocuments': businessDocuments.map((doc) => doc.toJson()).toList(),
    };
  }

  // ========== Validation ==========

  List<String> validate() {
    final errors = <String>[];

    // Validate owner ID
    if (ownerId.isNotEmpty && !IdGenerator.isValidOwnerId(ownerId)) {
      errors.add('Invalid owner ID format');
    }

    // Validate user ID
    if (!IdGenerator.isValidUserId(userId)) {
      errors.add('Invalid user ID format');
    }

    // Validate business name
    if (businessName != null) {
      final businessNameValidation = Validators.validateName(businessName, fieldName: 'Business name');
      if (businessNameValidation != null) {
        errors.add(businessNameValidation);
      }
    }

    // Validate Arabic business name
    if (businessNameArabic != null && businessNameArabic!.isNotEmpty) {
      final arabicNameValidation = Validators.validateArabicName(businessNameArabic, fieldName: 'Arabic business name');
      if (arabicNameValidation != null) {
        errors.add(arabicNameValidation);
      }
    }

    // Validate tax number
    if (taxNumber != null) {
      final taxValidation = Validators.validateTaxNumber(taxNumber);
      if (taxValidation != null) {
        errors.add(taxValidation);
      }
    }

    // Validate bank details
    if (bankDetails != null) {
      final bankErrors = bankDetails!.validate();
      errors.addAll(bankErrors);
    }

    // Validate approved by
    if (approvedBy != null && !IdGenerator.isValidAdminId(approvedBy!)) {
      errors.add('Invalid approvedBy admin ID format');
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  // ========== Computed Properties ==========

  /// Get business display name in preferred language
  String getBusinessDisplayName(String? languageCode) {
    final isArabic = languageCode == 'ar';

    if (isArabic && businessNameArabic?.isNotEmpty == true) {
      return businessNameArabic!;
    } else if (businessName?.isNotEmpty == true) {
      return businessName!;
    }

    return isArabic ? 'مالك قاعة' : 'Hall Owner';
  }

  /// Check if business profile is completed
  bool get isBusinessProfileCompleted {
    return businessName != null &&
        businessLicense != null &&
        taxNumber != null &&
        bankDetails != null &&
        bankDetails!.isComplete;
  }

  /// Get profile completion percentage
  double get businessProfileCompletionPercentage {
    int totalFields = 5; // businessName, businessLicense, taxNumber, bankDetails, businessDocuments
    int completedFields = 0;

    if (businessName?.isNotEmpty == true) completedFields++;
    if (businessLicense?.isNotEmpty == true) completedFields++;
    if (taxNumber?.isNotEmpty == true) completedFields++;
    if (bankDetails?.isComplete == true) completedFields++;
    if (businessDocuments.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  /// Get approval status display
  String getApprovalStatusDisplay(String? languageCode) {
    final isArabic = languageCode == 'ar';

    if (isApproved) {
      return isArabic ? 'معتمد' : 'Approved';
    } else {
      return isArabic ? 'في انتظار الموافقة' : 'Pending Approval';
    }
  }

  /// Get time since approval
  String? getTimeSinceApproval(String? languageCode) {
    if (approvedAt == null) return null;
    return DateUtils.formatTimeDifference(approvedAt!, languageCode: languageCode);
  }

  /// Check if owner is recently active
  bool get isRecentlyActive {
    if (statistics?.lastHallActivity == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return statistics!.lastHallActivity!.isAfter(thirtyDaysAgo);
  }

  /// Get average earnings per booking
  double get averageEarningsPerBooking {
    if (totalBookings == 0) return 0.0;
    return totalEarnings / totalBookings;
  }

  /// Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get rating with review count
  String getRatingDisplay(String? languageCode) {
    final isArabic = languageCode == 'ar';
    if (reviewCount == 0) {
      return isArabic ? 'لا توجد تقييمات' : 'No reviews';
    }

    if (isArabic) {
      return '$formattedRating ($reviewCount تقييم)';
    } else {
      return '$formattedRating ($reviewCount review${reviewCount != 1 ? 's' : ''})';
    }
  }

  // ========== Earnings Calculations ==========

  /// Calculate earnings for a specific period
  double calculateEarningsForPeriod(DateTime startDate, DateTime endDate, List<Map<String, dynamic>> bookings) {
    double earnings = 0.0;

    for (final booking in bookings) {
      final eventDate = DateUtils.parseISODate(booking['eventDate'] as String?);
      if (eventDate != null &&
          eventDate.isAfter(startDate) &&
          eventDate.isBefore(endDate.add(const Duration(days: 1)))) {

        final pricing = booking['pricing'] as Map<String, dynamic>?;
        if (pricing != null) {
          earnings += (pricing['ownerEarnings'] as num?)?.toDouble() ?? 0.0;
        }
      }
    }

    return earnings;
  }

  /// Calculate monthly earnings
  double calculateMonthlyEarnings(DateTime month, List<Map<String, dynamic>> bookings) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return calculateEarningsForPeriod(startOfMonth, endOfMonth, bookings);
  }

  /// Calculate projected yearly earnings based on recent performance
  double calculateProjectedYearlyEarnings() {
    if (statistics == null || statistics!.lastMonthEarnings == 0) {
      return totalEarnings * 12; // Simple projection
    }

    // Use last 3 months average for better projection
    final recentAverage = (statistics!.lastMonthEarnings +
        statistics!.secondLastMonthEarnings +
        statistics!.thirdLastMonthEarnings) / 3;

    return recentAverage * 12;
  }

  /// Get earnings growth rate
  double getEarningsGrowthRate() {
    if (statistics == null || statistics!.secondLastMonthEarnings == 0) {
      return 0.0;
    }

    final currentMonth = statistics!.lastMonthEarnings;
    final previousMonth = statistics!.secondLastMonthEarnings;

    return ((currentMonth - previousMonth) / previousMonth) * 100;
  }

  // ========== Business Document Management ==========

  /// Add business document
  HallOwnerModel addBusinessDocument(BusinessDocument document) {
    final updatedDocuments = List<BusinessDocument>.from(businessDocuments)..add(document);
    return copyWith(
      businessDocuments: updatedDocuments,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove business document
  HallOwnerModel removeBusinessDocument(String documentId) {
    final updatedDocuments = businessDocuments.where((doc) => doc.id != documentId).toList();
    return copyWith(
      businessDocuments: updatedDocuments,
      updatedAt: DateTime.now(),
    );
  }

  /// Get document by type
  BusinessDocument? getDocumentByType(BusinessDocumentType type) {
    try {
      return businessDocuments.firstWhere((doc) => doc.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Check if all required documents are uploaded
  bool get hasAllRequiredDocuments {
    final requiredTypes = [
      BusinessDocumentType.businessLicense,
      BusinessDocumentType.taxCertificate,
    ];

    return requiredTypes.every((type) => getDocumentByType(type) != null);
  }

  // ========== Update Methods ==========

  /// Update business information
  HallOwnerModel updateBusinessInfo({
    String? businessName,
    String? businessNameArabic,
    String? businessLicense,
    String? taxNumber,
    BankDetails? bankDetails,
  }) {
    return copyWith(
      businessName: businessName ?? this.businessName,
      businessNameArabic: businessNameArabic ?? this.businessNameArabic,
      businessLicense: businessLicense ?? this.businessLicense,
      taxNumber: taxNumber ?? this.taxNumber,
      bankDetails: bankDetails ?? this.bankDetails,
      updatedAt: DateTime.now(),
    );
  }

  /// Update commission settings
  HallOwnerModel updateCommissionSettings(CommissionSettings newSettings) {
    return copyWith(
      commissionSettings: newSettings,
      updatedAt: DateTime.now(),
    );
  }

  /// Approve hall owner
  HallOwnerModel approve(String approvedBy) {
    return copyWith(
      isApproved: true,
      approvedBy: approvedBy,
      approvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Reject/revoke approval
  HallOwnerModel revokeApproval() {
    return copyWith(
      isApproved: false,
      approvedBy: null,
      approvedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Update earnings and booking statistics
  HallOwnerModel updateEarnings({
    required double additionalEarnings,
    required int additionalBookings,
    double? newRating,
    int? additionalReviews,
  }) {
    return copyWith(
      totalEarnings: totalEarnings + additionalEarnings,
      totalBookings: totalBookings + additionalBookings,
      rating: newRating ?? rating,
      reviewCount: reviewCount + (additionalReviews ?? 0),
      updatedAt: DateTime.now(),
    );
  }

  /// Update statistics
  HallOwnerModel updateStatistics(OwnerStatistics newStatistics) {
    return copyWith(
      statistics: newStatistics,
      updatedAt: DateTime.now(),
    );
  }

  /// Deactivate owner
  HallOwnerModel deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Reactivate owner
  HallOwnerModel reactivate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  // ========== Copy With ==========

  HallOwnerModel copyWith({
    String? ownerId,
    String? userId,
    String? businessName,
    String? businessNameArabic,
    String? businessLicense,
    String? taxNumber,
    BankDetails? bankDetails,
    CommissionSettings? commissionSettings,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
    bool? isActive,
    double? totalEarnings,
    int? totalBookings,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    OwnerStatistics? statistics,
    List<BusinessDocument>? businessDocuments,
  }) {
    return HallOwnerModel(
      ownerId: ownerId ?? this.ownerId,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessNameArabic: businessNameArabic ?? this.businessNameArabic,
      businessLicense: businessLicense ?? this.businessLicense,
      taxNumber: taxNumber ?? this.taxNumber,
      bankDetails: bankDetails ?? this.bankDetails,
      commissionSettings: commissionSettings ?? this.commissionSettings,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      isActive: isActive ?? this.isActive,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statistics: statistics ?? this.statistics,
      businessDocuments: businessDocuments ?? this.businessDocuments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HallOwnerModel && other.ownerId == ownerId;
  }

  @override
  int get hashCode => ownerId.hashCode;

  @override
  String toString() {
    return 'HallOwnerModel(ownerId: $ownerId, userId: $userId, businessName: $businessName, isApproved: $isApproved)';
  }
}

// ========== Supporting Classes ==========

/// Bank details for payments
class BankDetails {
  final String bankName;
  final String accountNumber;
  final String iban;
  final String? swiftCode;
  final String accountHolderName;

  BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.iban,
    this.swiftCode,
    required this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      iban: json['iban'] as String,
      swiftCode: json['swiftCode'] as String?,
      accountHolderName: json['accountHolderName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'iban': iban,
      'swiftCode': swiftCode,
      'accountHolderName': accountHolderName,
    };
  }

  List<String> validate() {
    final errors = <String>[];

    if (bankName.isEmpty) errors.add('Bank name is required');
    if (accountNumber.isEmpty) errors.add('Account number is required');

    final ibanValidation = Validators.validateIBAN(iban);
    if (ibanValidation != null) errors.add(ibanValidation);

    if (accountHolderName.isEmpty) errors.add('Account holder name is required');

    return errors;
  }

  bool get isComplete => validate().isEmpty;

  BankDetails copyWith({
    String? bankName,
    String? accountNumber,
    String? iban,
    String? swiftCode,
    String? accountHolderName,
  }) {
    return BankDetails(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      swiftCode: swiftCode ?? this.swiftCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
    );
  }
}

/// Commission settings for hall owner
class CommissionSettings {
  final double customerCommissionPercent;
  final double ownerCommissionPercent;

  CommissionSettings({
    required this.customerCommissionPercent,
    required this.ownerCommissionPercent,
  });

  factory CommissionSettings.defaultSettings() {
    return CommissionSettings(
      customerCommissionPercent: AppConstants.defaultCustomerCommissionPercent,
      ownerCommissionPercent: AppConstants.defaultOwnerCommissionPercent,
    );
  }

  factory CommissionSettings.fromJson(Map<String, dynamic> json) {
    return CommissionSettings(
      customerCommissionPercent: (json['customerCommissionPercent'] as num?)?.toDouble() ??
          AppConstants.defaultCustomerCommissionPercent,
      ownerCommissionPercent: (json['ownerCommissionPercent'] as num?)?.toDouble() ??
          AppConstants.defaultOwnerCommissionPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerCommissionPercent': customerCommissionPercent,
      'ownerCommissionPercent': ownerCommissionPercent,
    };
  }

  /// Calculate commission amounts for a booking
  Map<String, double> calculateCommissions(double bookingAmount) {
    return PriceCalculator.calculateCommissions(
      subtotalPrice: bookingAmount,
      customerCommissionPercent: customerCommissionPercent,
      ownerCommissionPercent: ownerCommissionPercent,
    ).toMap();
  }

  CommissionSettings copyWith({
    double? customerCommissionPercent,
    double? ownerCommissionPercent,
  }) {
    return CommissionSettings(
      customerCommissionPercent: customerCommissionPercent ?? this.customerCommissionPercent,
      ownerCommissionPercent: ownerCommissionPercent ?? this.ownerCommissionPercent,
    );
  }
}

/// Business document model
class BusinessDocument {
  final String id;
  final BusinessDocumentType type;
  final String fileName;
  final String downloadUrl;
  final int fileSize;
  final DateTime uploadedAt;
  final DocumentStatus status;

  BusinessDocument({
    required this.id,
    required this.type,
    required this.fileName,
    required this.downloadUrl,
    required this.fileSize,
    required this.uploadedAt,
    this.status = DocumentStatus.pending,
  });

  factory BusinessDocument.fromJson(Map<String, dynamic> json) {
    return BusinessDocument(
      id: json['id'] as String,
      type: BusinessDocumentType.fromString(json['type'] as String),
      fileName: json['fileName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      fileSize: json['fileSize'] as int,
      uploadedAt: DateUtils.parseISODate(json['uploadedAt'] as String) ?? DateTime.now(),
      status: DocumentStatus.fromString(json['status'] as String? ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'uploadedAt': DateUtils.toISOString(uploadedAt),
      'status': status.value,
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Business document types
enum BusinessDocumentType {
  businessLicense('business_license'),
  taxCertificate('tax_certificate'),
  bankStatement('bank_statement'),
  identityDocument('identity_document'),
  other('other');

  const BusinessDocumentType(this.value);
  final String value;

  static BusinessDocumentType fromString(String value) {
    return BusinessDocumentType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => BusinessDocumentType.other,
    );
  }

  String getDisplayName(String? languageCode) {
    final isArabic = languageCode == 'ar';
    switch (this) {
      case BusinessDocumentType.businessLicense:
        return isArabic ? 'رخصة تجارية' : 'Business License';
      case BusinessDocumentType.taxCertificate:
        return isArabic ? 'شهادة ضريبية' : 'Tax Certificate';
      case BusinessDocumentType.bankStatement:
        return isArabic ? 'كشف حساب بنكي' : 'Bank Statement';
      case BusinessDocumentType.identityDocument:
        return isArabic ? 'وثيقة هوية' : 'Identity Document';
      case BusinessDocumentType.other:
        return isArabic ? 'أخرى' : 'Other';
    }
  }
}

/// Document approval status
enum DocumentStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  expired('expired');

  const DocumentStatus(this.value);
  final String value;

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => DocumentStatus.pending,
    );
  }
}

/// Owner performance statistics
class OwnerStatistics {
  final int totalHalls;
  final int activeHalls;
  final double lastMonthEarnings;
  final double secondLastMonthEarnings;
  final double thirdLastMonthEarnings;
  final int lastMonthBookings;
  final double averageResponseTime; // hours
  final double cancellationRate; // percentage
  final DateTime? lastHallActivity;
  final double occupancyRate; // percentage

  OwnerStatistics({
    this.totalHalls = 0,
    this.activeHalls = 0,
    this.lastMonthEarnings = 0.0,
    this.secondLastMonthEarnings = 0.0,
    this.thirdLastMonthEarnings = 0.0,
    this.lastMonthBookings = 0,
    this.averageResponseTime = 0.0,
    this.cancellationRate = 0.0,
    this.lastHallActivity,
    this.occupancyRate = 0.0,
  });

  factory OwnerStatistics.fromJson(Map<String, dynamic> json) {
    return OwnerStatistics(
      totalHalls: json['totalHalls'] as int? ?? 0,
      activeHalls: json['activeHalls'] as int? ?? 0,
      lastMonthEarnings: (json['lastMonthEarnings'] as num?)?.toDouble() ?? 0.0,
      secondLastMonthEarnings: (json['secondLastMonthEarnings'] as num?)?.toDouble() ?? 0.0,
      thirdLastMonthEarnings: (json['thirdLastMonthEarnings'] as num?)?.toDouble() ?? 0.0,
      lastMonthBookings: json['lastMonthBookings'] as int? ?? 0,
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
      cancellationRate: (json['cancellationRate'] as num?)?.toDouble() ?? 0.0,
      lastHallActivity: DateUtils.parseISODate(json['lastHallActivity'] as String?),
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHalls': totalHalls,
      'activeHalls': activeHalls,
      'lastMonthEarnings': lastMonthEarnings,
      'secondLastMonthEarnings': secondLastMonthEarnings,
      'thirdLastMonthEarnings': thirdLastMonthEarnings,
      'lastMonthBookings': lastMonthBookings,
      'averageResponseTime': averageResponseTime,
      'cancellationRate': cancellationRate,
      'lastHallActivity': lastHallActivity != null ? DateUtils.toISOString(lastHallActivity!) : null,
      'occupancyRate': occupancyRate,
    };
  }

  /// Get performance rating (1-5 based on multiple factors)
  double get performanceRating {
    double score = 0.0;
    int factors = 0;

    // Occupancy rate (higher is better)
    if (occupancyRate > 0) {
      score += (occupancyRate / 100) * 5;
      factors++;
    }

    // Response time (lower is better, cap at 24 hours)
    if (averageResponseTime > 0) {
      final responseScore = (24 - averageResponseTime.clamp(0, 24)) / 24 * 5;
      score += responseScore;
      factors++;
    }

    // Cancellation rate (lower is better)
    if (cancellationRate >= 0) {
      final cancellationScore = (100 - cancellationRate.clamp(0, 100)) / 100 * 5;
      score += cancellationScore;
      factors++;
    }

    return factors > 0 ? score / factors : 0.0;
  }

  /// Check if owner is performing well
  bool get isPerformingWell => performanceRating >= 4.0;

  /// Get earnings trend
  EarningsTrend get earningsTrend {
    if (secondLastMonthEarnings == 0) return EarningsTrend.stable;

    final growth = (lastMonthEarnings - secondLastMonthEarnings) / secondLastMonthEarnings;

    if (growth > 0.1) return EarningsTrend.increasing;
    if (growth < -0.1) return EarningsTrend.decreasing;
    return EarningsTrend.stable;
  }
}

/// Earnings trend enum
enum EarningsTrend {
  increasing,
  decreasing,
  stable,
}

// Extension for commission result
extension CommissionResultExtension on CommissionCalculationResult {
  Map<String, double> toMap() {
    return {
      'customerCommission': customerCommissionAmount,
      'ownerCommission': ownerCommissionAmount,
      'totalAmount': totalAmountForCustomer,
      'ownerEarnings': ownerEarnings,
      'adminEarnings': adminEarnings,
    };
  }
}
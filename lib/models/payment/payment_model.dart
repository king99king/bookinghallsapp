// models/payment/payment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';

/// Comprehensive payment model for booking transactions
class PaymentModel {
  final String paymentId;
  final String bookingId;
  final String userId;
  final String? hallId;
  final String? ownerId;
  final PaymentType paymentType;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentProvider provider;
  final String? providerTransactionId;
  final String? thawaniTransactionId;
  final String? thawaniPaymentId;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? failureReason;
  final String? failureCode;
  final double refundAmount;
  final String? refundReason;
  final DateTime? refundedAt;
  final String? refundTransactionId;
  final CommissionBreakdown commissionBreakdown;
  final Map<String, dynamic>? providerResponse;
  final Map<String, dynamic>? metadata;
  final List<PaymentStatusHistory> statusHistory;

  PaymentModel({
    required this.paymentId,
    required this.bookingId,
    required this.userId,
    this.hallId,
    this.ownerId,
    required this.paymentType,
    required this.amount,
    this.currency = AppConstants.defaultCurrency,
    required this.paymentMethod,
    this.provider = PaymentProvider.thawani,
    this.providerTransactionId,
    this.thawaniTransactionId,
    this.thawaniPaymentId,
    required this.status,
    DateTime? createdAt,
    this.processedAt,
    this.completedAt,
    this.failedAt,
    this.failureReason,
    this.failureCode,
    this.refundAmount = 0.0,
    this.refundReason,
    this.refundedAt,
    this.refundTransactionId,
    required this.commissionBreakdown,
    this.providerResponse,
    this.metadata,
    this.statusHistory = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  // ========== Factory Constructors ==========

  /// Create from Firestore document
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentModel(
        paymentId: Validators.validateString(json[FirebaseConstants.paymentIdField], 'Payment ID'),
        bookingId: Validators.validateString(json[FirebaseConstants.bookingIdField], 'Booking ID'),
        userId: Validators.validateString(json[FirebaseConstants.userIdField], 'User ID'),
        hallId: json[FirebaseConstants.hallIdField] as String?,
        ownerId: json[FirebaseConstants.ownerIdField] as String?,
        paymentType: PaymentType.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.paymentTypeField],
          orElse: () => PaymentType.fullPayment,
        ),
        amount: Validators.validatePositiveDouble(json[FirebaseConstants.amountField], 'Amount'),
        currency: json['currency'] as String? ?? AppConstants.defaultCurrency,
        paymentMethod: PaymentMethod.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.paymentMethodField],
          orElse: () => PaymentMethod.creditCard,
        ),
        provider: PaymentProvider.values.firstWhere(
              (e) => e.name == json['provider'],
          orElse: () => PaymentProvider.thawani,
        ),
        providerTransactionId: json['providerTransactionId'] as String?,
        thawaniTransactionId: json[FirebaseConstants.thawaniTransactionIdField] as String?,
        thawaniPaymentId: json['thawaniPaymentId'] as String?,
        status: PaymentStatus.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.statusField],
          orElse: () => PaymentStatus.pending,
        ),
        createdAt: DateUtils.parseTimestamp(json[FirebaseConstants.createdAtField]) ?? DateTime.now(),
        processedAt: DateUtils.parseTimestamp(json[FirebaseConstants.processedAtField]),
        completedAt: DateUtils.parseTimestamp(json['completedAt']),
        failedAt: DateUtils.parseTimestamp(json['failedAt']),
        failureReason: json[FirebaseConstants.failureReasonField] as String?,
        failureCode: json['failureCode'] as String?,
        refundAmount: (json[FirebaseConstants.refundAmountField] as num?)?.toDouble() ?? 0.0,
        refundReason: json[FirebaseConstants.refundReasonField] as String?,
        refundedAt: DateUtils.parseTimestamp(json['refundedAt']),
        refundTransactionId: json['refundTransactionId'] as String?,
        commissionBreakdown: CommissionBreakdown.fromJson(
          json[FirebaseConstants.commissionBreakdownField] as Map<String, dynamic>? ?? {},
        ),
        providerResponse: json['providerResponse'] as Map<String, dynamic>?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        statusHistory: (json['statusHistory'] as List<dynamic>?)
            ?.map((e) => PaymentStatusHistory.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      throw ModelParseException('Failed to parse PaymentModel: $e');
    }
  }

  /// Create new payment
  factory PaymentModel.create({
    required String bookingId,
    required String userId,
    String? hallId,
    String? ownerId,
    required PaymentType paymentType,
    required double amount,
    String currency = AppConstants.defaultCurrency,
    required PaymentMethod paymentMethod,
    PaymentProvider provider = PaymentProvider.thawani,
    required CommissionBreakdown commissionBreakdown,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();

    return PaymentModel(
      paymentId: '', // Will be generated by service
      bookingId: bookingId,
      userId: userId,
      hallId: hallId,
      ownerId: ownerId,
      paymentType: paymentType,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      provider: provider,
      status: PaymentStatus.pending,
      createdAt: now,
      commissionBreakdown: commissionBreakdown,
      metadata: metadata,
      statusHistory: [
        PaymentStatusHistory(
          status: PaymentStatus.pending,
          timestamp: now,
          notes: 'Payment created',
        ),
      ],
    );
  }

  /// Create from Thawani response
  factory PaymentModel.fromThawaniResponse({
    required String bookingId,
    required String userId,
    String? hallId,
    String? ownerId,
    required PaymentType paymentType,
    required double amount,
    required PaymentMethod paymentMethod,
    required CommissionBreakdown commissionBreakdown,
    required String thawaniPaymentId,
    String? thawaniTransactionId,
    Map<String, dynamic>? thawaniResponse,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel.create(
      bookingId: bookingId,
      userId: userId,
      hallId: hallId,
      ownerId: ownerId,
      paymentType: paymentType,
      amount: amount,
      paymentMethod: paymentMethod,
      commissionBreakdown: commissionBreakdown,
      metadata: metadata,
    ).copyWith(
      thawaniPaymentId: thawaniPaymentId,
      thawaniTransactionId: thawaniTransactionId,
      providerResponse: thawaniResponse,
      status: PaymentStatus.processing,
    );
  }

  // ========== Serialization ==========

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.paymentIdField: paymentId,
      FirebaseConstants.bookingIdField: bookingId,
      FirebaseConstants.userIdField: userId,
      FirebaseConstants.hallIdField: hallId,
      FirebaseConstants.ownerIdField: ownerId,
      FirebaseConstants.paymentTypeField: paymentType.name,
      FirebaseConstants.amountField: amount,
      'currency': currency,
      FirebaseConstants.paymentMethodField: paymentMethod.name,
      'provider': provider.name,
      'providerTransactionId': providerTransactionId,
      FirebaseConstants.thawaniTransactionIdField: thawaniTransactionId,
      'thawaniPaymentId': thawaniPaymentId,
      FirebaseConstants.statusField: status.name,
      FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
      FirebaseConstants.processedAtField: processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'failedAt': failedAt != null
          ? Timestamp.fromDate(failedAt!)
          : null,
      FirebaseConstants.failureReasonField: failureReason,
      'failureCode': failureCode,
      FirebaseConstants.refundAmountField: refundAmount,
      FirebaseConstants.refundReasonField: refundReason,
      'refundedAt': refundedAt != null
          ? Timestamp.fromDate(refundedAt!)
          : null,
      'refundTransactionId': refundTransactionId,
      FirebaseConstants.commissionBreakdownField: commissionBreakdown.toJson(),
      'providerResponse': providerResponse,
      'metadata': metadata,
      'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
    };
  }

  // ========== Business Logic Methods ==========

  /// Check if payment is pending
  bool isPending() => status == PaymentStatus.pending;

  /// Check if payment is processing
  bool isProcessing() => status == PaymentStatus.processing;

  /// Check if payment is completed
  bool isCompleted() => status == PaymentStatus.completed;

  /// Check if payment failed
  bool isFailed() => status == PaymentStatus.failed;

  /// Check if payment is refunded
  bool isRefunded() => status == PaymentStatus.refunded;

  /// Check if payment can be cancelled
  bool canBeCancelled() {
    return status == PaymentStatus.pending || status == PaymentStatus.processing;
  }

  /// Check if payment can be refunded
  bool canBeRefunded() {
    return status == PaymentStatus.completed && refundAmount < amount;
  }

  /// Check if payment is overdue
  bool isOverdue() {
    if (status != PaymentStatus.pending) return false;

    final now = DateTime.now();
    final hoursSinceCreated = now.difference(createdAt).inHours;

    return hoursSinceCreated > AppConstants.paymentTimeoutHours;
  }

  /// Get remaining refundable amount
  double getRemainingRefundableAmount() {
    if (!canBeRefunded()) return 0.0;
    return amount - refundAmount;
  }

  /// Get net amount after commission
  double getNetAmount() {
    return amount - commissionBreakdown.totalCommission;
  }

  /// Get owner earnings from this payment
  double getOwnerEarnings() {
    if (ownerId == null) return 0.0;
    return amount - commissionBreakdown.customerCommission - commissionBreakdown.ownerCommission;
  }

  /// Get admin earnings from this payment
  double getAdminEarnings() {
    return commissionBreakdown.totalCommission;
  }

  /// Get processing time in minutes
  int? getProcessingTimeInMinutes() {
    if (processedAt == null) return null;
    return processedAt!.difference(createdAt).inMinutes;
  }

  /// Get payment type display text
  String getPaymentTypeDisplayText(String languageCode) {
    final typeTranslations = {
      'firstPayment': {'en': 'First Payment', 'ar': 'الدفعة الأولى'},
      'secondPayment': {'en': 'Second Payment', 'ar': 'الدفعة الثانية'},
      'fullPayment': {'en': 'Full Payment', 'ar': 'الدفعة الكاملة'},
      'refund': {'en': 'Refund', 'ar': 'استرداد'},
    };

    return typeTranslations[paymentType.name]?[languageCode] ?? paymentType.name;
  }

  /// Get payment method display text
  String getPaymentMethodDisplayText(String languageCode) {
    final methodTranslations = {
      'creditCard': {'en': 'Credit Card', 'ar': 'بطاقة ائتمان'},
      'debitCard': {'en': 'Debit Card', 'ar': 'بطاقة خصم'},
      'bankTransfer': {'en': 'Bank Transfer', 'ar': 'تحويل بنكي'},
      'cash': {'en': 'Cash', 'ar': 'نقداً'},
      'wallet': {'en': 'Digital Wallet', 'ar': 'محفظة رقمية'},
    };

    return methodTranslations[paymentMethod.name]?[languageCode] ?? paymentMethod.name;
  }

  /// Get status display text
  String getStatusDisplayText(String languageCode) {
    final statusTranslations = {
      'pending': {'en': 'Pending', 'ar': 'في الانتظار'},
      'processing': {'en': 'Processing', 'ar': 'قيد المعالجة'},
      'completed': {'en': 'Completed', 'ar': 'مكتمل'},
      'failed': {'en': 'Failed', 'ar': 'فشل'},
      'cancelled': {'en': 'Cancelled', 'ar': 'ملغي'},
      'refunded': {'en': 'Refunded', 'ar': 'مُسترد'},
      'expired': {'en': 'Expired', 'ar': 'منتهي الصلاحية'},
    };

    return statusTranslations[status.name]?[languageCode] ?? status.name;
  }

  /// Format amount with currency
  String getFormattedAmount({String? languageCode}) {
    final formatted = amount.toStringAsFixed(3);
    final currencySymbol = AppConstants.currencySymbol;

    if (languageCode == 'ar') {
      return '$formatted $currencySymbol';
    }
    return '$currencySymbol $formatted';
  }

  // ========== Update Methods ==========

  /// Mark payment as processing
  PaymentModel markAsProcessing({
    String? providerTransactionId,
    String? thawaniTransactionId,
    Map<String, dynamic>? providerResponse,
  }) {
    final now = DateTime.now();
    final newHistory = List<PaymentStatusHistory>.from(statusHistory)
      ..add(PaymentStatusHistory(
        status: PaymentStatus.processing,
        timestamp: now,
        notes: 'Payment processing started',
      ));

    return copyWith(
      status: PaymentStatus.processing,
      processedAt: now,
      providerTransactionId: providerTransactionId ?? this.providerTransactionId,
      thawaniTransactionId: thawaniTransactionId ?? this.thawaniTransactionId,
      providerResponse: providerResponse ?? this.providerResponse,
      statusHistory: newHistory,
    );
  }

  /// Complete payment
  PaymentModel complete({
    String? providerTransactionId,
    String? thawaniTransactionId,
    Map<String, dynamic>? providerResponse,
  }) {
    final now = DateTime.now();
    final newHistory = List<PaymentStatusHistory>.from(statusHistory)
      ..add(PaymentStatusHistory(
        status: PaymentStatus.completed,
        timestamp: now,
        notes: 'Payment completed successfully',
      ));

    return copyWith(
      status: PaymentStatus.completed,
      completedAt: now,
      providerTransactionId: providerTransactionId ?? this.providerTransactionId,
      thawaniTransactionId: thawaniTransactionId ?? this.thawaniTransactionId,
      providerResponse: providerResponse ?? this.providerResponse,
      statusHistory: newHistory,
    );
  }

  /// Fail payment
  PaymentModel fail({
    required String reason,
    String? failureCode,
    Map<String, dynamic>? providerResponse,
  }) {
    final now = DateTime.now();
    final newHistory = List<PaymentStatusHistory>.from(statusHistory)
      ..add(PaymentStatusHistory(
        status: PaymentStatus.failed,
        timestamp: now,
        notes: 'Payment failed: $reason',
      ));

    return copyWith(
      status: PaymentStatus.failed,
      failedAt: now,
      failureReason: reason,
      failureCode: failureCode,
      providerResponse: providerResponse ?? this.providerResponse,
      statusHistory: newHistory,
    );
  }

  /// Cancel payment
  PaymentModel cancel({String? reason}) {
    final now = DateTime.now();
    final newHistory = List<PaymentStatusHistory>.from(statusHistory)
      ..add(PaymentStatusHistory(
        status: PaymentStatus.cancelled,
        timestamp: now,
        notes: reason ?? 'Payment cancelled',
      ));

    return copyWith(
      status: PaymentStatus.cancelled,
      failureReason: reason,
      statusHistory: newHistory,
    );
  }

  /// Process refund
  PaymentModel processRefund({
    required double refundAmount,
    required String refundReason,
    String? refundTransactionId,
  }) {
    if (refundAmount <= 0 || refundAmount > getRemainingRefundableAmount()) {
      throw ArgumentError('Invalid refund amount');
    }

    final now = DateTime.now();
    final newTotalRefund = this.refundAmount + refundAmount;
    final newStatus = newTotalRefund >= amount ? PaymentStatus.refunded : status;

    final newHistory = List<PaymentStatusHistory>.from(statusHistory)
      ..add(PaymentStatusHistory(
        status: newStatus,
        timestamp: now,
        notes: 'Refund processed: $refundReason (Amount: ${refundAmount.toStringAsFixed(3)})',
      ));

    return copyWith(
      status: newStatus,
      refundAmount: newTotalRefund,
      refundReason: refundReason,
      refundedAt: now,
      refundTransactionId: refundTransactionId,
      statusHistory: newHistory,
    );
  }

  /// Expire payment
  PaymentModel expire() {
    final now = DateTime.now();
    final newHistory = List<PaymentStatusHistory>.from(statusHistory)
      ..add(PaymentStatusHistory(
        status: PaymentStatus.expired,
        timestamp: now,
        notes: 'Payment expired due to timeout',
      ));

    return copyWith(
      status: PaymentStatus.expired,
      failureReason: 'Payment timeout',
      statusHistory: newHistory,
    );
  }

  // ========== Copy With ==========

  PaymentModel copyWith({
    String? paymentId,
    String? bookingId,
    String? userId,
    String? hallId,
    String? ownerId,
    PaymentType? paymentType,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    PaymentProvider? provider,
    String? providerTransactionId,
    String? thawaniTransactionId,
    String? thawaniPaymentId,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? failedAt,
    String? failureReason,
    String? failureCode,
    double? refundAmount,
    String? refundReason,
    DateTime? refundedAt,
    String? refundTransactionId,
    CommissionBreakdown? commissionBreakdown,
    Map<String, dynamic>? providerResponse,
    Map<String, dynamic>? metadata,
    List<PaymentStatusHistory>? statusHistory,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      hallId: hallId ?? this.hallId,
      ownerId: ownerId ?? this.ownerId,
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      provider: provider ?? this.provider,
      providerTransactionId: providerTransactionId ?? this.providerTransactionId,
      thawaniTransactionId: thawaniTransactionId ?? this.thawaniTransactionId,
      thawaniPaymentId: thawaniPaymentId ?? this.thawaniPaymentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      failedAt: failedAt ?? this.failedAt,
      failureReason: failureReason ?? this.failureReason,
      failureCode: failureCode ?? this.failureCode,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      refundTransactionId: refundTransactionId ?? this.refundTransactionId,
      commissionBreakdown: commissionBreakdown ?? this.commissionBreakdown,
      providerResponse: providerResponse ?? this.providerResponse,
      metadata: metadata ?? this.metadata,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.paymentId == paymentId;
  }

  @override
  int get hashCode => paymentId.hashCode;

  @override
  String toString() => 'PaymentModel(id: $paymentId, amount: $amount, status: $status)';
}

// ========== Supporting Enums ==========

/// Payment type enum
enum PaymentType {
  firstPayment,
  secondPayment,
  fullPayment,
  refund,
}

/// Payment method enum
enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  cash,
  wallet,
}

/// Payment provider enum
enum PaymentProvider {
  thawani,
  stripe,
  paypal,
  cash,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  expired,
}

// ========== Supporting Models ==========

/// Commission breakdown for payment
class CommissionBreakdown {
  final double customerCommission;
  final double ownerCommission;
  final double totalCommission;
  final double customerCommissionPercent;
  final double ownerCommissionPercent;
  final double platformEarnings;

  CommissionBreakdown({
    required this.customerCommission,
    required this.ownerCommission,
    required this.totalCommission,
    required this.customerCommissionPercent,
    required this.ownerCommissionPercent,
    required this.platformEarnings,
  });

  factory CommissionBreakdown.fromJson(Map<String, dynamic> json) {
    return CommissionBreakdown(
      customerCommission: (json['customerCommission'] as num?)?.toDouble() ?? 0.0,
      ownerCommission: (json['ownerCommission'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0.0,
      customerCommissionPercent: (json['customerCommissionPercent'] as num?)?.toDouble() ?? 0.0,
      ownerCommissionPercent: (json['ownerCommissionPercent'] as num?)?.toDouble() ?? 0.0,
      platformEarnings: (json['platformEarnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerCommission': customerCommission,
      'ownerCommission': ownerCommission,
      'totalCommission': totalCommission,
      'customerCommissionPercent': customerCommissionPercent,
      'ownerCommissionPercent': ownerCommissionPercent,
      'platformEarnings': platformEarnings,
    };
  }

  /// Calculate from base amount
  factory CommissionBreakdown.calculate({
    required double baseAmount,
    required double customerCommissionPercent,
    required double ownerCommissionPercent,
  }) {
    final customerCommission = baseAmount * (customerCommissionPercent / 100);
    final ownerCommission = baseAmount * (ownerCommissionPercent / 100);
    final totalCommission = customerCommission + ownerCommission;

    return CommissionBreakdown(
      customerCommission: customerCommission,
      ownerCommission: ownerCommission,
      totalCommission: totalCommission,
      customerCommissionPercent: customerCommissionPercent,
      ownerCommissionPercent: ownerCommissionPercent,
      platformEarnings: totalCommission,
    );
  }

  @override
  String toString() => 'CommissionBreakdown(total: $totalCommission)';
}

/// Payment status history tracking
class PaymentStatusHistory {
  final PaymentStatus status;
  final DateTime timestamp;
  final String? notes;
  final Map<String, dynamic>? metadata;

  PaymentStatusHistory({
    required this.status,
    required this.timestamp,
    this.notes,
    this.metadata,
  });

  factory PaymentStatusHistory.fromJson(Map<String, dynamic> json) {
    return PaymentStatusHistory(
      status: PaymentStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      timestamp: DateUtils.parseTimestamp(json['timestamp']) ?? DateTime.now(),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'metadata': metadata,
    };
  }
}

/// Custom exception for payment model parsing errors
class ModelParseException implements Exception {
  final String message;
  ModelParseException(this.message);

  @override
  String toString() => 'ModelParseException: $message';
}
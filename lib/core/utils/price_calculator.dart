// core/utils/price_calculator.dart

import 'dart:math';
import '../constants/app_constants.dart';
import 'date_utils.dart';

/// Comprehensive pricing and commission calculator for the booking system
class PriceCalculator {

  // ========== Base Price Calculations ==========

  /// Calculate base price for a booking (before discounts and commissions)
  static double calculateBasePrice({
    required double hallBasePrice,
    required DateTime bookingDate,
    required bool isFullDay,
    Map<String, double>? dailyPricing,
    double? hourlyRate,
    Map<String, double>? hourlyRatesByDay,
    int? durationInHours,
  }) {
    final dayOfWeek = _getDayOfWeekString(bookingDate);

    if (isFullDay) {
      // Daily booking - check for day-specific pricing
      if (dailyPricing != null && dailyPricing.containsKey(dayOfWeek)) {
        return dailyPricing[dayOfWeek]!;
      }
      return hallBasePrice;
    } else {
      // Hourly booking
      if (durationInHours == null || durationInHours <= 0) {
        throw ArgumentError('Duration in hours is required for hourly bookings');
      }

      double rate;

      // Check for day-specific hourly rates
      if (hourlyRatesByDay != null && hourlyRatesByDay.containsKey(dayOfWeek)) {
        rate = hourlyRatesByDay[dayOfWeek]!;
      } else if (hourlyRate != null) {
        rate = hourlyRate;
      } else {
        // Fallback: calculate hourly rate from daily price (assuming 8-hour day)
        final dailyPrice = dailyPricing?.containsKey(dayOfWeek) == true
            ? dailyPricing![dayOfWeek]!
            : hallBasePrice;
        rate = dailyPrice / 8.0;
      }

      return rate * durationInHours;
    }
  }

  // ========== Discount Calculations ==========

  /// Apply discounts to base price
  static DiscountCalculationResult applyDiscounts({
    required double basePrice,
    required DateTime bookingDate,
    required bool isFullDay,
    String? timeSlotId,
    List<Map<String, dynamic>>? availableDiscounts,
  }) {
    if (availableDiscounts == null || availableDiscounts.isEmpty) {
      return DiscountCalculationResult(
        originalPrice: basePrice,
        discountedPrice: basePrice,
        totalDiscountAmount: 0.0,
        totalDiscountPercent: 0.0,
        appliedDiscounts: [],
      );
    }

    double bestDiscountedPrice = basePrice;
    Map<String, dynamic>? bestDiscount;
    final applicableDiscounts = <Map<String, dynamic>>[];

    // Find all applicable discounts
    for (final discount in availableDiscounts) {
      if (_isDiscountApplicable(
        discount: discount,
        bookingDate: bookingDate,
        isFullDay: isFullDay,
        timeSlotId: timeSlotId,
        bookingAmount: basePrice,
      )) {
        applicableDiscounts.add(discount);

        // Calculate discounted price
        final discountPercent = discount['percentage'] as double;
        final discountedPrice = basePrice * (1 - discountPercent / 100);

        // Keep track of best discount
        if (discountedPrice < bestDiscountedPrice) {
          bestDiscountedPrice = discountedPrice;
          bestDiscount = discount;
        }
      }
    }

    final discountAmount = basePrice - bestDiscountedPrice;
    final discountPercent = bestDiscount != null
        ? bestDiscount['percentage'] as double
        : 0.0;

    return DiscountCalculationResult(
      originalPrice: basePrice,
      discountedPrice: bestDiscountedPrice,
      totalDiscountAmount: discountAmount,
      totalDiscountPercent: discountPercent,
      appliedDiscounts: bestDiscount != null ? [bestDiscount] : [],
      availableDiscounts: applicableDiscounts,
    );
  }

  /// Check if a discount is applicable
  static bool _isDiscountApplicable({
    required Map<String, dynamic> discount,
    required DateTime bookingDate,
    required bool isFullDay,
    String? timeSlotId,
    required double bookingAmount,
  }) {
    try {
      // Check date validity
      final startDate = DateTime.parse(discount['startDate']);
      final endDate = DateTime.parse(discount['endDate']);
      final bookingDateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      if (bookingDateOnly.isBefore(startDate) || bookingDateOnly.isAfter(endDate)) {
        return false;
      }

      // Check day of week
      final dayOfWeek = _getDayOfWeekString(bookingDate);
      final appliesOnDays = List<String>.from(discount['appliesOnDays'] ?? []);
      if (!appliesOnDays.contains(dayOfWeek)) {
        return false;
      }

      // Check booking type
      final appliesToDaily = discount['appliesToDaily'] as bool? ?? true;
      final appliesToHourly = discount['appliesToHourly'] as bool? ?? true;

      if (isFullDay && !appliesToDaily) return false;
      if (!isFullDay && !appliesToHourly) return false;

      // Check specific time slots
      final specificTimeSlotIds = discount['specificTimeSlotIds'] as List<dynamic>?;
      if (specificTimeSlotIds != null && specificTimeSlotIds.isNotEmpty) {
        if (timeSlotId == null || !specificTimeSlotIds.contains(timeSlotId)) {
          return false;
        }
      }

      // Check minimum booking amount
      final minimumBookingAmount = discount['minimumBookingAmount'] as double?;
      if (minimumBookingAmount != null && bookingAmount < minimumBookingAmount) {
        return false;
      }

      return true;
    } catch (e) {
      return false; // Invalid discount data
    }
  }

  // ========== Commission Calculations ==========

  /// Calculate commission breakdown
  static CommissionCalculationResult calculateCommissions({
    required double subtotalPrice,
    required double customerCommissionPercent,
    required double ownerCommissionPercent,
  }) {
    // Validate commission percentages
    final customerCommission = _validateCommissionPercent(customerCommissionPercent);
    final ownerCommission = _validateCommissionPercent(ownerCommissionPercent);

    // Calculate commission amounts
    final customerCommissionAmount = subtotalPrice * (customerCommission / 100);
    final ownerCommissionAmount = subtotalPrice * (ownerCommission / 100);
    final totalCommissionAmount = customerCommissionAmount + ownerCommissionAmount;

    // Calculate final amounts
    final totalAmountForCustomer = subtotalPrice + customerCommissionAmount;
    final ownerEarnings = subtotalPrice - ownerCommissionAmount;
    final adminEarnings = customerCommissionAmount + ownerCommissionAmount;

    return CommissionCalculationResult(
      subtotalPrice: subtotalPrice,
      customerCommissionPercent: customerCommission,
      ownerCommissionPercent: ownerCommission,
      customerCommissionAmount: customerCommissionAmount,
      ownerCommissionAmount: ownerCommissionAmount,
      totalCommissionAmount: totalCommissionAmount,
      totalAmountForCustomer: totalAmountForCustomer,
      ownerEarnings: ownerEarnings,
      adminEarnings: adminEarnings,
    );
  }

  /// Validate commission percentage
  static double _validateCommissionPercent(double percent) {
    return percent.clamp(
      AppConstants.minCommissionPercent,
      AppConstants.maxCommissionPercent,
    );
  }

  // ========== Payment Plan Calculations ==========

  /// Calculate payment breakdown based on payment plan
  static PaymentCalculationResult calculatePaymentBreakdown({
    required double totalAmount,
    required DateTime eventDate,
    double? firstPaymentPercent,
    int? daysBeforeEventForFinalPayment,
  }) {
    final firstPercent = firstPaymentPercent ?? AppConstants.defaultFirstPaymentPercent;
    final daysBefore = daysBeforeEventForFinalPayment ?? AppConstants.defaultDaysBeforeEventForFinalPayment;

    // Validate first payment percentage
    final validFirstPercent = firstPercent.clamp(10.0, 90.0);

    // Calculate payment amounts
    final firstPaymentAmount = _roundToTwoDecimals(totalAmount * (validFirstPercent / 100));
    final finalPaymentAmount = _roundToTwoDecimals(totalAmount - firstPaymentAmount);

    // Calculate due dates
    final paymentDueDates = DateUtils.calculatePaymentDueDates(
      eventDate,
      validFirstPercent,
      daysBefore,
    );

    return PaymentCalculationResult(
      totalAmount: totalAmount,
      firstPaymentPercent: validFirstPercent,
      finalPaymentPercent: 100 - validFirstPercent,
      firstPaymentAmount: firstPaymentAmount,
      finalPaymentAmount: finalPaymentAmount,
      firstPaymentDueDate: paymentDueDates['firstPaymentDue']!,
      finalPaymentDueDate: paymentDueDates['finalPaymentDue']!,
      daysBeforeEventForFinalPayment: daysBefore,
    );
  }

  // ========== Complete Booking Price Calculation ==========

  /// Calculate complete booking price with all factors
  static BookingPriceCalculationResult calculateCompleteBookingPrice({
    required double hallBasePrice,
    required DateTime bookingDate,
    required bool isFullDay,
    required double customerCommissionPercent,
    required double ownerCommissionPercent,
    Map<String, double>? dailyPricing,
    double? hourlyRate,
    Map<String, double>? hourlyRatesByDay,
    int? durationInHours,
    String? timeSlotId,
    List<Map<String, dynamic>>? availableDiscounts,
    double? firstPaymentPercent,
    int? daysBeforeEventForFinalPayment,
  }) {
    // Step 1: Calculate base price
    final basePrice = calculateBasePrice(
      hallBasePrice: hallBasePrice,
      bookingDate: bookingDate,
      isFullDay: isFullDay,
      dailyPricing: dailyPricing,
      hourlyRate: hourlyRate,
      hourlyRatesByDay: hourlyRatesByDay,
      durationInHours: durationInHours,
    );

    // Step 2: Apply discounts
    final discountResult = applyDiscounts(
      basePrice: basePrice,
      bookingDate: bookingDate,
      isFullDay: isFullDay,
      timeSlotId: timeSlotId,
      availableDiscounts: availableDiscounts,
    );

    // Step 3: Calculate commissions
    final commissionResult = calculateCommissions(
      subtotalPrice: discountResult.discountedPrice,
      customerCommissionPercent: customerCommissionPercent,
      ownerCommissionPercent: ownerCommissionPercent,
    );

    // Step 4: Calculate payment breakdown
    final paymentResult = calculatePaymentBreakdown(
      totalAmount: commissionResult.totalAmountForCustomer,
      eventDate: bookingDate,
      firstPaymentPercent: firstPaymentPercent,
      daysBeforeEventForFinalPayment: daysBeforeEventForFinalPayment,
    );

    return BookingPriceCalculationResult(
      basePrice: basePrice,
      discountResult: discountResult,
      commissionResult: commissionResult,
      paymentResult: paymentResult,
    );
  }

  // ========== Currency Formatting ==========

  /// Format currency amount for display
  static String formatCurrency(double amount, {String? languageCode}) {
    final isArabic = languageCode == 'ar';
    final roundedAmount = _roundToTwoDecimals(amount);

    if (isArabic) {
      return '${roundedAmount.toStringAsFixed(2)} ${AppConstants.currencySymbol}';
    } else {
      return '${AppConstants.currencySymbol} ${roundedAmount.toStringAsFixed(2)}';
    }
  }

  /// Format currency with breakdown
  static String formatCurrencyBreakdown({
    required double amount,
    required String description,
    String? languageCode,
  }) {
    final formattedAmount = formatCurrency(amount, languageCode: languageCode);
    final isArabic = languageCode == 'ar';

    if (isArabic) {
      return '$description: $formattedAmount';
    } else {
      return '$description: $formattedAmount';
    }
  }

  // ========== Analytics and Reporting ==========

  /// Calculate total earnings for admin from multiple bookings
  static AdminEarningsResult calculateAdminEarnings(List<Map<String, dynamic>> bookings) {
    double totalCustomerCommissions = 0.0;
    double totalOwnerCommissions = 0.0;
    double totalRevenue = 0.0;
    int totalBookings = bookings.length;

    for (final booking in bookings) {
      final pricing = booking['pricing'] as Map<String, dynamic>?;
      if (pricing != null) {
        totalCustomerCommissions += pricing['customerCommission'] as double? ?? 0.0;
        totalOwnerCommissions += pricing['ownerCommission'] as double? ?? 0.0;
        totalRevenue += pricing['totalAmount'] as double? ?? 0.0;
      }
    }

    final totalAdminEarnings = totalCustomerCommissions + totalOwnerCommissions;
    final averageBookingValue = totalBookings > 0 ? totalRevenue / totalBookings : 0.0;
    final averageAdminEarning = totalBookings > 0 ? totalAdminEarnings / totalBookings : 0.0;

    return AdminEarningsResult(
      totalCustomerCommissions: totalCustomerCommissions,
      totalOwnerCommissions: totalOwnerCommissions,
      totalAdminEarnings: totalAdminEarnings,
      totalRevenue: totalRevenue,
      totalBookings: totalBookings,
      averageBookingValue: averageBookingValue,
      averageAdminEarning: averageAdminEarning,
    );
  }

  /// Calculate owner earnings from bookings
  static OwnerEarningsResult calculateOwnerEarnings(List<Map<String, dynamic>> bookings) {
    double totalEarnings = 0.0;
    double totalCommissionsPaid = 0.0;
    double totalRevenue = 0.0;
    int totalBookings = bookings.length;

    for (final booking in bookings) {
      final pricing = booking['pricing'] as Map<String, dynamic>?;
      if (pricing != null) {
        totalEarnings += pricing['ownerEarnings'] as double? ?? 0.0;
        totalCommissionsPaid += pricing['ownerCommission'] as double? ?? 0.0;
        totalRevenue += pricing['subtotal'] as double? ?? 0.0;
      }
    }

    final averageBookingValue = totalBookings > 0 ? totalRevenue / totalBookings : 0.0;
    final averageEarning = totalBookings > 0 ? totalEarnings / totalBookings : 0.0;
    final commissionRate = totalRevenue > 0 ? (totalCommissionsPaid / totalRevenue) * 100 : 0.0;

    return OwnerEarningsResult(
      totalEarnings: totalEarnings,
      totalCommissionsPaid: totalCommissionsPaid,
      totalRevenue: totalRevenue,
      totalBookings: totalBookings,
      averageBookingValue: averageBookingValue,
      averageEarning: averageEarning,
      effectiveCommissionRate: commissionRate,
    );
  }

  // ========== Utility Methods ==========

  /// Get day of week as lowercase string
  static String _getDayOfWeekString(DateTime date) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[date.weekday - 1];
  }

  /// Round to two decimal places
  static double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }

  /// Calculate percentage
  static double calculatePercentage(double part, double whole) {
    if (whole == 0) return 0.0;
    return (part / whole) * 100;
  }

  /// Calculate percentage of amount
  static double calculatePercentageOf(double amount, double percentage) {
    return amount * (percentage / 100);
  }

  // ========== Validation Methods ==========

  /// Validate price calculation inputs
  static bool validatePriceInputs({
    required double basePrice,
    required double customerCommissionPercent,
    required double ownerCommissionPercent,
    int? durationInHours,
    bool isHourly = false,
  }) {
    if (basePrice <= 0) return false;
    if (customerCommissionPercent < 0 || customerCommissionPercent > 100) return false;
    if (ownerCommissionPercent < 0 || ownerCommissionPercent > 100) return false;
    if (isHourly && (durationInHours == null || durationInHours <= 0)) return false;

    return true;
  }

  /// Check if amount is within reasonable bounds
  static bool isReasonableAmount(double amount) {
    return amount >= AppConstants.minPrice && amount <= AppConstants.maxPrice;
  }
}

// ========== Result Classes ==========

/// Result of discount calculation
class DiscountCalculationResult {
  final double originalPrice;
  final double discountedPrice;
  final double totalDiscountAmount;
  final double totalDiscountPercent;
  final List<Map<String, dynamic>> appliedDiscounts;
  final List<Map<String, dynamic>> availableDiscounts;

  DiscountCalculationResult({
    required this.originalPrice,
    required this.discountedPrice,
    required this.totalDiscountAmount,
    required this.totalDiscountPercent,
    required this.appliedDiscounts,
    this.availableDiscounts = const [],
  });

  bool get hasDiscount => totalDiscountAmount > 0;
  double get savings => totalDiscountAmount;
}

/// Result of commission calculation
class CommissionCalculationResult {
  final double subtotalPrice;
  final double customerCommissionPercent;
  final double ownerCommissionPercent;
  final double customerCommissionAmount;
  final double ownerCommissionAmount;
  final double totalCommissionAmount;
  final double totalAmountForCustomer;
  final double ownerEarnings;
  final double adminEarnings;

  CommissionCalculationResult({
    required this.subtotalPrice,
    required this.customerCommissionPercent,
    required this.ownerCommissionPercent,
    required this.customerCommissionAmount,
    required this.ownerCommissionAmount,
    required this.totalCommissionAmount,
    required this.totalAmountForCustomer,
    required this.ownerEarnings,
    required this.adminEarnings,
  });
}

/// Result of payment calculation
class PaymentCalculationResult {
  final double totalAmount;
  final double firstPaymentPercent;
  final double finalPaymentPercent;
  final double firstPaymentAmount;
  final double finalPaymentAmount;
  final DateTime firstPaymentDueDate;
  final DateTime finalPaymentDueDate;
  final int daysBeforeEventForFinalPayment;

  PaymentCalculationResult({
    required this.totalAmount,
    required this.firstPaymentPercent,
    required this.finalPaymentPercent,
    required this.firstPaymentAmount,
    required this.finalPaymentAmount,
    required this.firstPaymentDueDate,
    required this.finalPaymentDueDate,
    required this.daysBeforeEventForFinalPayment,
  });

  bool isFirstPaymentDue() => DateUtils.nowInOman().isAfter(firstPaymentDueDate);
  bool isFinalPaymentDue() => DateUtils.nowInOman().isAfter(finalPaymentDueDate);
  int daysUntilFinalPayment() => DateUtils.daysUntilPaymentDue(finalPaymentDueDate);
}

/// Complete booking price calculation result
class BookingPriceCalculationResult {
  final double basePrice;
  final DiscountCalculationResult discountResult;
  final CommissionCalculationResult commissionResult;
  final PaymentCalculationResult paymentResult;

  BookingPriceCalculationResult({
    required this.basePrice,
    required this.discountResult,
    required this.commissionResult,
    required this.paymentResult,
  });

  double get finalPrice => commissionResult.totalAmountForCustomer;
  double get savings => discountResult.totalDiscountAmount;
  bool get hasDiscount => discountResult.hasDiscount;
}

/// Admin earnings analysis result
class AdminEarningsResult {
  final double totalCustomerCommissions;
  final double totalOwnerCommissions;
  final double totalAdminEarnings;
  final double totalRevenue;
  final int totalBookings;
  final double averageBookingValue;
  final double averageAdminEarning;

  AdminEarningsResult({
    required this.totalCustomerCommissions,
    required this.totalOwnerCommissions,
    required this.totalAdminEarnings,
    required this.totalRevenue,
    required this.totalBookings,
    required this.averageBookingValue,
    required this.averageAdminEarning,
  });

  double get commissionRate => totalRevenue > 0 ? (totalAdminEarnings / totalRevenue) * 100 : 0.0;
}

/// Owner earnings analysis result
class OwnerEarningsResult {
  final double totalEarnings;
  final double totalCommissionsPaid;
  final double totalRevenue;
  final int totalBookings;
  final double averageBookingValue;
  final double averageEarning;
  final double effectiveCommissionRate;

  OwnerEarningsResult({
    required this.totalEarnings,
    required this.totalCommissionsPaid,
    required this.totalRevenue,
    required this.totalBookings,
    required this.averageBookingValue,
    required this.averageEarning,
    required this.effectiveCommissionRate,
  });

  double get earningsRate => totalRevenue > 0 ? (totalEarnings / totalRevenue) * 100 : 0.0;
}
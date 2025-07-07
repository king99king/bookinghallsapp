// models/hall/hall_model.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/price_calculator.dart';
import '../../core/extensions/string_extension.dart';

/// Enhanced Hall model with integrated business logic
class HallModel {
  final String id;
  final String name;
  final String? nameArabic;
  final String description;
  final String? descriptionArabic;
  final String ownerId;
  final String ownerName;
  final double basePrice;
  final Map<String, double>? dailyPricing;
  final double? hourlyRate;
  final Map<String, double>? hourlyRatesByDay;
  final bool allowsDailyBooking;
  final bool allowsHourlyBooking;
  final List<TimeSlotWithId>? availableTimeSlots;
  final int capacity;
  final String address;
  final double latitude;
  final double longitude;
  final String? locationUrl;
  final List<String> imageUrls;
  final List<String> categoryIds;
  final List<String> amenities;
  final List<String> services;
  final bool isApproved;
  final bool isAvailable;
  final bool isFeatured;
  final String? contactPhone;
  final String? contactEmail;
  final Map<String, dynamic>? regulations;
  final Map<String, dynamic>? regulationsArabic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int? reviewCount;
  final String? governorate;
  final String? wilayat;
  final double? profit;
  final List<Discount>? discounts;
  final PaymentPlan? paymentPlan;
  final BookingSettings? bookingSettings;
  final CommissionSettings? commissionSettings;
  final HallStatistics? statistics;

  HallModel({
    required this.id,
    required this.name,
    this.nameArabic,
    required this.description,
    this.descriptionArabic,
    required this.ownerId,
    required this.ownerName,
    required this.basePrice,
    this.dailyPricing,
    this.hourlyRate,
    this.hourlyRatesByDay,
    this.allowsDailyBooking = true,
    this.allowsHourlyBooking = false,
    this.availableTimeSlots,
    required this.capacity,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.locationUrl,
    required this.imageUrls,
    required this.categoryIds,
    required this.amenities,
    this.services = const [],
    required this.isApproved,
    required this.isAvailable,
    this.isFeatured = false,
    this.contactPhone,
    this.contactEmail,
    this.regulations,
    this.regulationsArabic,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.rating,
    this.reviewCount,
    this.governorate,
    this.wilayat,
    this.profit,
    this.discounts,
    this.paymentPlan,
    this.bookingSettings,
    this.commissionSettings,
    this.statistics,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ========== Factory Constructors ==========

  /// Create from Firestore document (enhanced your original)
  factory HallModel.fromJson(Map<String, dynamic> json) {
    try {
      Map<String, double>? dailyPricing;
      Map<String, double>? hourlyRatesByDay;
      List<TimeSlotWithId>? availableTimeSlots;
      List<Discount>? discounts;
      PaymentPlan? paymentPlan;
      BookingSettings? bookingSettings;
      CommissionSettings? commissionSettings;
      HallStatistics? statistics;

      // Parse daily pricing
      if (json[FirebaseConstants.dailyPricingField] != null) {
        try {
          dailyPricing = {};
          final pricingData = json[FirebaseConstants.dailyPricingField];
          if (pricingData is Map) {
            pricingData.forEach((key, value) {
              if (key != null && value != null) {
                final String dayKey = key.toString().toLowerCase();
                double price;
                if (value is num) {
                  price = value.toDouble();
                } else {
                  price = double.tryParse(value.toString()) ?? 0.0;
                }
                dailyPricing![dayKey] = price;
              }
            });
          }
        } catch (e) {
          debugPrint('Error parsing dailyPricing: $e');
          dailyPricing = null;
        }
      }

      // Parse hourly rates by day
      if (json[FirebaseConstants.hourlyRatesByDayField] != null) {
        try {
          hourlyRatesByDay = {};
          final hourlyRatesData = json[FirebaseConstants.hourlyRatesByDayField];
          if (hourlyRatesData is Map) {
            hourlyRatesData.forEach((key, value) {
              if (key != null && value != null) {
                final String dayKey = key.toString().toLowerCase();
                double rate;
                if (value is num) {
                  rate = value.toDouble();
                } else {
                  rate = double.tryParse(value.toString()) ?? 0.0;
                }
                hourlyRatesByDay![dayKey] = rate;
              }
            });
          }
        } catch (e) {
          debugPrint('Error parsing hourlyRatesByDay: $e');
          hourlyRatesByDay = null;
        }
      }

      // Parse time slots
      if (json[FirebaseConstants.availableTimeSlotsField] != null) {
        try {
          final slotsData = json[FirebaseConstants.availableTimeSlotsField] as List<dynamic>;
          availableTimeSlots = slotsData.map((slotData) =>
              TimeSlotWithId.fromJson(slotData as Map<String, dynamic>)
          ).toList();
        } catch (e) {
          debugPrint('Error parsing time slots: $e');
          availableTimeSlots = [];
        }
      }

      // Parse discounts
      if (json[FirebaseConstants.discountsField] != null) {
        try {
          final discountsData = json[FirebaseConstants.discountsField] as List<dynamic>;
          discounts = discountsData.map((discountData) =>
              Discount.fromJson(discountData as Map<String, dynamic>)
          ).toList();
        } catch (e) {
          debugPrint('Error parsing discounts: $e');
          discounts = [];
        }
      }

      // Parse payment plan
      if (json[FirebaseConstants.paymentPlanField] != null) {
        try {
          paymentPlan = PaymentPlan.fromJson(json[FirebaseConstants.paymentPlanField] as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing payment plan: $e');
        }
      }

      // Parse booking settings
      if (json[FirebaseConstants.bookingSettingsField] != null) {
        try {
          bookingSettings = BookingSettings.fromJson(json[FirebaseConstants.bookingSettingsField] as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing booking settings: $e');
        }
      }

      // Parse commission settings
      if (json[FirebaseConstants.commissionSettingsField] != null) {
        try {
          commissionSettings = CommissionSettings.fromJson(json[FirebaseConstants.commissionSettingsField] as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing commission settings: $e');
        }
      }

      // Parse statistics
      if (json['statistics'] != null) {
        try {
          statistics = HallStatistics.fromJson(json['statistics'] as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing hall statistics: $e');
        }
      }

      return HallModel(
        id: json[FirebaseConstants.idField] as String,
        name: json[FirebaseConstants.nameField] as String,
        nameArabic: json[FirebaseConstants.nameArabicField] as String?,
        description: json[FirebaseConstants.descriptionField] as String,
        descriptionArabic: json[FirebaseConstants.descriptionArabicField] as String?,
        ownerId: json[FirebaseConstants.ownerIdField] as String,
        ownerName: json[FirebaseConstants.ownerNameField] as String? ?? 'Unknown Owner',
        basePrice: (json[FirebaseConstants.basePriceField] as num).toDouble(),
        dailyPricing: dailyPricing,
        hourlyRate: json[FirebaseConstants.hourlyRateField] != null ?
        (json[FirebaseConstants.hourlyRateField] as num).toDouble() : null,
        hourlyRatesByDay: hourlyRatesByDay,
        allowsDailyBooking: json[FirebaseConstants.allowsDailyBookingField] as bool? ?? true,
        allowsHourlyBooking: json[FirebaseConstants.allowsHourlyBookingField] as bool? ?? false,
        availableTimeSlots: availableTimeSlots,
        capacity: json[FirebaseConstants.capacityField] as int,
        address: json[FirebaseConstants.addressField] as String,
        latitude: json[FirebaseConstants.locationField] != null
            ? (json[FirebaseConstants.locationField][FirebaseConstants.latitudeField] as num).toDouble()
            : 0.0,
        longitude: json[FirebaseConstants.locationField] != null
            ? (json[FirebaseConstants.locationField][FirebaseConstants.longitudeField] as num).toDouble()
            : 0.0,
        locationUrl: json[FirebaseConstants.locationUrlField] as String?,
        imageUrls: (json[FirebaseConstants.imageUrlsField] as List<dynamic>?)
            ?.map((e) => e as String).toList() ?? [],
        categoryIds: (json[FirebaseConstants.categoryIdsField] as List<dynamic>?)
            ?.map((e) => e as String).toList() ?? [],
        amenities: (json[FirebaseConstants.amenitiesField] as List<dynamic>?)
            ?.map((e) => e as String).toList() ?? [],
        services: (json[FirebaseConstants.servicesField] as List<dynamic>?)
            ?.map((e) => e as String).toList() ?? [],
        isApproved: json[FirebaseConstants.isApprovedField] as bool? ?? false,
        isAvailable: json[FirebaseConstants.isActiveField] as bool? ?? true,
        isFeatured: json[FirebaseConstants.isFeaturedField] as bool? ?? false,
        contactPhone: json[FirebaseConstants.contactPhoneField] as String?,
        contactEmail: json[FirebaseConstants.contactEmailField] as String?,
        regulations: _convertToStringDynamicMap(json[FirebaseConstants.regulationsField]),
        regulationsArabic: _convertToStringDynamicMap(json[FirebaseConstants.regulationsArabicField]),
        createdAt: _parseDateTime(json[FirebaseConstants.createdAtField]),
        updatedAt: _parseDateTime(json[FirebaseConstants.updatedAtField]),
        rating: json[FirebaseConstants.ratingField] != null ?
        (json[FirebaseConstants.ratingField] as num).toDouble() : null,
        reviewCount: json[FirebaseConstants.reviewCountField] as int?,
        governorate: json[FirebaseConstants.governorateField] as String?,
        wilayat: json[FirebaseConstants.wilayatField] as String?,
        profit: json[FirebaseConstants.profitField] != null ?
        (json[FirebaseConstants.profitField] as num).toDouble() : null,
        discounts: discounts,
        paymentPlan: paymentPlan,
        bookingSettings: bookingSettings,
        commissionSettings: commissionSettings,
        statistics: statistics,
      );
    } catch (e) {
      debugPrint('Error parsing HallModel from JSON: $e');
      rethrow;
    }
  }

  /// Create new hall
  factory HallModel.createNew({
    required String ownerId,
    required String ownerName,
    required String name,
    required String description,
    required double basePrice,
    required int capacity,
    required String address,
    required double latitude,
    required double longitude,
    required String governorate,
    required String wilayat,
    required List<String> categoryIds,
    String? nameArabic,
    String? descriptionArabic,
  }) {
    return HallModel(
      id: '', // Will be generated by service
      name: name,
      nameArabic: nameArabic,
      description: description,
      descriptionArabic: descriptionArabic,
      ownerId: ownerId,
      ownerName: ownerName,
      basePrice: basePrice,
      capacity: capacity,
      address: address,
      latitude: latitude,
      longitude: longitude,
      governorate: governorate,
      wilayat: wilayat,
      categoryIds: categoryIds,
      imageUrls: [],
      amenities: [],
      isApproved: false,
      isAvailable: true,
      bookingSettings: BookingSettings.defaultSettings(),
      commissionSettings: CommissionSettings.defaultSettings(),
    );
  }

  // ========== JSON Conversion ==========

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.idField: id,
      FirebaseConstants.nameField: name,
      FirebaseConstants.nameArabicField: nameArabic,
      FirebaseConstants.descriptionField: description,
      FirebaseConstants.descriptionArabicField: descriptionArabic,
      FirebaseConstants.ownerIdField: ownerId,
      FirebaseConstants.ownerNameField: ownerName,
      FirebaseConstants.basePriceField: basePrice,
      FirebaseConstants.dailyPricingField: dailyPricing,
      FirebaseConstants.hourlyRateField: hourlyRate,
      FirebaseConstants.hourlyRatesByDayField: hourlyRatesByDay,
      FirebaseConstants.allowsDailyBookingField: allowsDailyBooking,
      FirebaseConstants.allowsHourlyBookingField: allowsHourlyBooking,
      FirebaseConstants.availableTimeSlotsField: availableTimeSlots?.map((slot) => slot.toJson()).toList(),
      FirebaseConstants.capacityField: capacity,
      FirebaseConstants.addressField: address,
      FirebaseConstants.locationField: {
        FirebaseConstants.latitudeField: latitude,
        FirebaseConstants.longitudeField: longitude,
      },
      FirebaseConstants.locationUrlField: locationUrl,
      FirebaseConstants.imageUrlsField: imageUrls,
      FirebaseConstants.categoryIdsField: categoryIds,
      FirebaseConstants.amenitiesField: amenities,
      FirebaseConstants.servicesField: services,
      FirebaseConstants.isApprovedField: isApproved,
      FirebaseConstants.isActiveField: isAvailable,
      FirebaseConstants.isFeaturedField: isFeatured,
      FirebaseConstants.contactPhoneField: contactPhone,
      FirebaseConstants.contactEmailField: contactEmail,
      FirebaseConstants.regulationsField: regulations,
      FirebaseConstants.regulationsArabicField: regulationsArabic,
      FirebaseConstants.createdAtField: DateUtils.toISOString(createdAt),
      FirebaseConstants.updatedAtField: DateUtils.toISOString(updatedAt),
      FirebaseConstants.ratingField: rating,
      FirebaseConstants.reviewCountField: reviewCount,
      FirebaseConstants.governorateField: governorate,
      FirebaseConstants.wilayatField: wilayat,
      FirebaseConstants.profitField: profit,
      FirebaseConstants.discountsField: discounts?.map((discount) => discount.toJson()).toList(),
      FirebaseConstants.paymentPlanField: paymentPlan?.toJson(),
      FirebaseConstants.bookingSettingsField: bookingSettings?.toJson(),
      FirebaseConstants.commissionSettingsField: commissionSettings?.toJson(),
      'statistics': statistics?.toJson(),
    };
  }

  // ========== Validation ==========

  List<String> validate() {
    final errors = <String>[];

    // Validate hall ID
    if (id.isNotEmpty && !IdGenerator.isValidHallId(id)) {
      errors.add('Invalid hall ID format');
    }

    // Validate owner ID
    if (!IdGenerator.isValidOwnerId(ownerId)) {
      errors.add('Invalid owner ID format');
    }

    // Validate name
    final nameValidation = Validators.validateName(name, fieldName: 'Hall name');
    if (nameValidation != null) {
      errors.add(nameValidation);
    }

    // Validate Arabic name
    if (nameArabic != null && nameArabic!.isNotEmpty) {
      final arabicNameValidation = Validators.validateArabicName(nameArabic, fieldName: 'Arabic hall name');
      if (arabicNameValidation != null) {
        errors.add(arabicNameValidation);
      }
    }

    // Validate description
    final descriptionValidation = Validators.validateDescription(description);
    if (descriptionValidation != null) {
      errors.add(descriptionValidation);
    }

    // Validate price
    final priceValidation = Validators.validatePrice(basePrice.toString());
    if (priceValidation != null) {
      errors.add(priceValidation);
    }

    // Validate capacity
    final capacityValidation = Validators.validateCapacity(capacity.toString());
    if (capacityValidation != null) {
      errors.add(capacityValidation);
    }

    // Validate location
    final coordinatesValidation = Validators.validateCoordinates(latitude, longitude);
    if (coordinatesValidation != null) {
      errors.add(coordinatesValidation);
    }

    // Validate governorate
    if (governorate != null) {
      final governorateValidation = Validators.validateGovernorate(governorate);
      if (governorateValidation != null) {
        errors.add(governorateValidation);
      }
    }

    // Validate wilayat
    if (wilayat != null && governorate != null) {
      final wilayatValidation = Validators.validateWilayat(wilayat, governorate);
      if (wilayatValidation != null) {
        errors.add(wilayatValidation);
      }
    }

    // Validate contact phone
    if (contactPhone != null) {
      final phoneValidation = Validators.validatePhoneNumber(contactPhone);
      if (phoneValidation != null) {
        errors.add(phoneValidation);
      }
    }

    // Validate contact email
    if (contactEmail != null) {
      final emailValidation = Validators.validateEmail(contactEmail);
      if (emailValidation != null) {
        errors.add(emailValidation);
      }
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  // ========== Computed Properties ==========

  /// Get hall name in preferred language
  String getDisplayName(String? languageCode) {
    final isArabic = languageCode == 'ar';
    if (isArabic && nameArabic?.isNotEmpty == true) {
      return nameArabic!;
    }
    return name;
  }

  /// Get hall description in preferred language
  String getDisplayDescription(String? languageCode) {
    final isArabic = languageCode == 'ar';
    if (isArabic && descriptionArabic?.isNotEmpty == true) {
      return descriptionArabic!;
    }
    return description;
  }

  /// Get location display name
  String? getLocationDisplayName(String? languageCode) {
    if (wilayat != null && governorate != null) {
      if (languageCode == 'ar') {
        final wilayatAr = wilayat!.localizeCommonTerm('ar');
        final governorateAr = governorate!.governorateInArabic;
        return '$wilayatAr، $governorateAr';
      } else {
        return '$wilayat, $governorate';
      }
    } else if (governorate != null) {
      return languageCode == 'ar' ? governorate!.governorateInArabic : governorate;
    }
    return null;
  }

  /// Get formatted rating
  String get formattedRating => rating?.toStringAsFixed(1) ?? '0.0';

  /// Get rating display with review count
  String getRatingDisplay(String? languageCode) {
    final isArabic = languageCode == 'ar';
    if (reviewCount == null || reviewCount == 0) {
      return isArabic ? 'لا توجد تقييمات' : 'No reviews';
    }

    if (isArabic) {
      return '$formattedRating ($reviewCount تقييم)';
    } else {
      return '$formattedRating ($reviewCount review${reviewCount != 1 ? 's' : ''})';
    }
  }

  /// Get main image URL
  String? get mainImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Check if hall has multiple images
  bool get hasMultipleImages => imageUrls.length > 1;

  /// Get image count
  int get imageCount => imageUrls.length;

  /// Check if hall supports both booking types
  bool get supportsAllBookingTypes => allowsDailyBooking && allowsHourlyBooking;

  /// Get supported booking types display
  String getSupportedBookingTypesDisplay(String? languageCode) {
    final isArabic = languageCode == 'ar';
    final types = <String>[];

    if (allowsDailyBooking) {
      types.add(isArabic ? 'يومي' : 'Daily');
    }
    if (allowsHourlyBooking) {
      types.add(isArabic ? 'ساعي' : 'Hourly');
    }

    return types.join(isArabic ? '، ' : ', ');
  }

  /// Check if hall is recently created
  bool get isRecentlyCreated {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return createdAt.isAfter(sevenDaysAgo);
  }

  /// Get hall age in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Check if hall needs attention (low rating, no bookings, etc.)
  bool get needsAttention {
    if (statistics == null) return false;

    // Multiple criteria for needing attention
    final hasLowRating = rating != null && rating! < 3.0;
    final hasNoRecentBookings = statistics!.lastBookingDate == null ||
        DateTime.now().difference(statistics!.lastBookingDate!).inDays > 30;
    final hasLowOccupancy = statistics!.occupancyRate < 20.0;

    return hasLowRating || hasNoRecentBookings || hasLowOccupancy;
  }

  // ========== Price Calculations ==========

  /// Calculate price for specific booking (enhanced your original method)
  double calculatePrice({
    required DateTime bookingDate,
    required bool isFullDay,
    TimeSlotWithId? timeSlot,
    bool applyDiscounts = true,
  }) {
    try {
      return PriceCalculator.calculateBasePrice(
        hallBasePrice: basePrice,
        bookingDate: bookingDate,
        isFullDay: isFullDay,
        dailyPricing: dailyPricing,
        hourlyRate: hourlyRate,
        hourlyRatesByDay: hourlyRatesByDay,
        durationInHours: timeSlot?.durationInHours,
      );
    } catch (e) {
      debugPrint('Error calculating price for hall $id: $e');
      return basePrice;
    }
  }

  /// Get complete booking price calculation
  BookingPriceCalculationResult calculateCompleteBookingPrice({
    required DateTime bookingDate,
    required bool isFullDay,
    TimeSlotWithId? timeSlot,
    bool applyDiscounts = true,
  }) {
    final effectiveCommissionSettings = commissionSettings ?? CommissionSettings.defaultSettings();

    return PriceCalculator.calculateCompleteBookingPrice(
      hallBasePrice: basePrice,
      bookingDate: bookingDate,
      isFullDay: isFullDay,
      customerCommissionPercent: effectiveCommissionSettings.customerCommissionPercent,
      ownerCommissionPercent: effectiveCommissionSettings.ownerCommissionPercent,
      dailyPricing: dailyPricing,
      hourlyRate: hourlyRate,
      hourlyRatesByDay: hourlyRatesByDay,
      durationInHours: timeSlot?.durationInHours,
      timeSlotId: timeSlot?.id,
      availableDiscounts: discounts?.map((d) => d.toJson()).toList(),
      firstPaymentPercent: paymentPlan?.firstPaymentPercentage,
      daysBeforeEventForFinalPayment: paymentPlan?.daysBeforeEventForFinalPayment,
    );
  }

  /// Get price range display
  String getPriceRangeDisplay(String? languageCode) {
    final isArabic = languageCode == 'ar';

    if (allowsDailyBooking && allowsHourlyBooking) {
      // Show range from hourly to daily
      final minHourlyRate = hourlyRate ?? (basePrice / 8);
      final maxDailyRate = dailyPricing?.values.isNotEmpty == true
          ? dailyPricing!.values.reduce((a, b) => a > b ? a : b)
          : basePrice;

      if (isArabic) {
        return '${minHourlyRate.toStringAsFixed(0)} - ${maxDailyRate.toStringAsFixed(0)} ${AppConstants.currencySymbol}';
      } else {
        return '${AppConstants.currencySymbol} ${minHourlyRate.toStringAsFixed(0)} - ${maxDailyRate.toStringAsFixed(0)}';
      }
    } else {
      // Show single price
      if (isArabic) {
        return '${basePrice.toStringAsFixed(0)} ${AppConstants.currencySymbol}';
      } else {
        return '${AppConstants.currencySymbol} ${basePrice.toStringAsFixed(0)}';
      }
    }
  }

  // ========== Availability Checks ==========

  /// Check if hall is available for booking
  bool isAvailableForBooking({
    required DateTime bookingDate,
    required bool isFullDay,
    TimeSlotWithId? timeSlot,
  }) {
    // Basic availability checks
    if (!isApproved || !isAvailable) return false;

    // Check booking date validity
    if (!DateUtils.isValidBookingDate(bookingDate)) return false;

    // Check if booking type is supported
    if (isFullDay && !allowsDailyBooking) return false;
    if (!isFullDay && !allowsHourlyBooking) return false;

    // Check booking settings
    if (bookingSettings != null) {
      if (!bookingSettings!.allowInstantBooking) {
        // Requires owner approval - always show as available for booking request
      }

      // Check advance booking limits
      final daysDifference = DateUtils.daysBetween(DateTime.now(), bookingDate);
      if (daysDifference > bookingSettings!.maxAdvanceBookingDays) return false;

      final hoursDifference = DateUtils.hoursBetween(DateTime.now(), bookingDate);
      if (hoursDifference < bookingSettings!.minAdvanceBookingHours) return false;
    }

    return true;
  }

  /// Get availability status display
  String getAvailabilityStatus(String? languageCode) {
    final isArabic = languageCode == 'ar';

    if (!isApproved) {
      return isArabic ? 'في انتظار الموافقة' : 'Pending Approval';
    }

    if (!isAvailable) {
      return isArabic ? 'غير متاح' : 'Unavailable';
    }

    return isArabic ? 'متاح' : 'Available';
  }

  // ========== Update Methods ==========

  /// Update basic information
  HallModel updateBasicInfo({
    String? name,
    String? nameArabic,
    String? description,
    String? descriptionArabic,
    double? basePrice,
    int? capacity,
    String? address,
    String? contactPhone,
    String? contactEmail,
  }) {
    return copyWith(
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      basePrice: basePrice ?? this.basePrice,
      capacity: capacity ?? this.capacity,
      address: address ?? this.address,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      updatedAt: DateTime.now(),
    );
  }

  /// Update pricing settings
  HallModel updatePricing({
    double? basePrice,
    Map<String, double>? dailyPricing,
    double? hourlyRate,
    Map<String, double>? hourlyRatesByDay,
  }) {
    return copyWith(
      basePrice: basePrice ?? this.basePrice,
      dailyPricing: dailyPricing ?? this.dailyPricing,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      hourlyRatesByDay: hourlyRatesByDay ?? this.hourlyRatesByDay,
      updatedAt: DateTime.now(),
    );
  }

  /// Update images
  HallModel updateImages(List<String> newImageUrls) {
    return copyWith(
      imageUrls: newImageUrls,
      updatedAt: DateTime.now(),
    );
  }

  /// Add images
  HallModel addImages(List<String> additionalImageUrls) {
    final updatedUrls = List<String>.from(imageUrls)..addAll(additionalImageUrls);
    return copyWith(
      imageUrls: updatedUrls,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove images
  HallModel removeImages(List<String> urlsToRemove) {
    final updatedUrls = imageUrls.where((url) => !urlsToRemove.contains(url)).toList();
    return copyWith(
      imageUrls: updatedUrls,
      updatedAt: DateTime.now(),
    );
  }

  /// Update amenities and services
  HallModel updateAmenitiesAndServices({
    List<String>? amenities,
    List<String>? services,
  }) {
    return copyWith(
      amenities: amenities ?? this.amenities,
      services: services ?? this.services,
      updatedAt: DateTime.now(),
    );
  }

  /// Approve hall
  HallModel approve() {
    return copyWith(
      isApproved: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Reject hall
  HallModel reject() {
    return copyWith(
      isApproved: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Toggle availability
  HallModel toggleAvailability() {
    return copyWith(
      isAvailable: !isAvailable,
      updatedAt: DateTime.now(),
    );
  }

  /// Toggle featured status
  HallModel toggleFeatured() {
    return copyWith(
      isFeatured: !isFeatured,
      updatedAt: DateTime.now(),
    );
  }

  /// Update rating
  HallModel updateRating(double newRating, int newReviewCount) {
    return copyWith(
      rating: newRating,
      reviewCount: newReviewCount,
      updatedAt: DateTime.now(),
    );
  }

  /// Update statistics
  HallModel updateStatistics(HallStatistics newStatistics) {
    return copyWith(
      statistics: newStatistics,
      updatedAt: DateTime.now(),
    );
  }

  // ========== Copy With ==========

  HallModel copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? description,
    String? descriptionArabic,
    String? ownerId,
    String? ownerName,
    double? basePrice,
    Map<String, double>? dailyPricing,
    double? hourlyRate,
    Map<String, double>? hourlyRatesByDay,
    bool? allowsDailyBooking,
    bool? allowsHourlyBooking,
    List<TimeSlotWithId>? availableTimeSlots,
    int? capacity,
    String? address,
    double? latitude,
    double? longitude,
    String? locationUrl,
    List<String>? imageUrls,
    List<String>? categoryIds,
    List<String>? amenities,
    List<String>? services,
    bool? isApproved,
    bool? isAvailable,
    bool? isFeatured,
    String? contactPhone,
    String? contactEmail,
    Map<String, dynamic>? regulations,
    Map<String, dynamic>? regulationsArabic,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    String? governorate,
    String? wilayat,
    double? profit,
    List<Discount>? discounts,
    PaymentPlan? paymentPlan,
    BookingSettings? bookingSettings,
    CommissionSettings? commissionSettings,
    HallStatistics? statistics,
  }) {
    return HallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      basePrice: basePrice ?? this.basePrice,
      dailyPricing: dailyPricing ?? this.dailyPricing,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      hourlyRatesByDay: hourlyRatesByDay ?? this.hourlyRatesByDay,
      allowsDailyBooking: allowsDailyBooking ?? this.allowsDailyBooking,
      allowsHourlyBooking: allowsHourlyBooking ?? this.allowsHourlyBooking,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      capacity: capacity ?? this.capacity,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationUrl: locationUrl ?? this.locationUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryIds: categoryIds ?? this.categoryIds,
      amenities: amenities ?? this.amenities,
      services: services ?? this.services,
      isApproved: isApproved ?? this.isApproved,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      regulations: regulations ?? this.regulations,
      regulationsArabic: regulationsArabic ?? this.regulationsArabic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      governorate: governorate ?? this.governorate,
      wilayat: wilayat ?? this.wilayat,
      profit: profit ?? this.profit,
      discounts: discounts ?? this.discounts,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      bookingSettings: bookingSettings ?? this.bookingSettings,
      commissionSettings: commissionSettings ?? this.commissionSettings,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HallModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HallModel(id: $id, name: $name, ownerId: $ownerId, isApproved: $isApproved)';
  }

  // ========== Static Helper Methods ==========

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateUtils.parseISODate(value) ?? DateTime.now();
    return DateTime.now();
  }

  static Map<String, dynamic>? _convertToStringDynamicMap(dynamic map) {
    if (map == null) return null;
    if (map is Map<String, dynamic>) return map;
    if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}

// ========== Supporting Classes (Enhanced from your original) ==========

/// Time slot with ID (enhanced)
class TimeSlotWithId {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isFullDay;
  final int? durationInHours;
  final String? name;
  final String? nameArabic;

  TimeSlotWithId({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isFullDay,
    this.durationInHours,
    this.name,
    this.nameArabic,
  });

  factory TimeSlotWithId.fromJson(Map<String, dynamic> json) {
    return TimeSlotWithId(
      id: json['id'] as String,
      startTime: DateUtils.parseISODate(json['startTime'] as String) ?? DateTime.now(),
      endTime: DateUtils.parseISODate(json['endTime'] as String) ?? DateTime.now(),
      isFullDay: json['isFullDay'] as bool? ?? false,
      durationInHours: json['durationInHours'] as int?,
      name: json['name'] as String?,
      nameArabic: json['nameArabic'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': DateUtils.toISOString(startTime),
    'endTime': DateUtils.toISOString(endTime),
    'isFullDay': isFullDay,
    'durationInHours': durationInHours,
    'name': name,
    'nameArabic': nameArabic,
  };

  String getDisplayName(String? languageCode) {
    final isArabic = languageCode == 'ar';
    if (isArabic && nameArabic?.isNotEmpty == true) {
      return nameArabic!;
    }
    return name ?? '${DateUtils.formatTime(startTime)} - ${DateUtils.formatTime(endTime)}';
  }
}

/// Discount model (enhanced)
class Discount {
  final String id;
  final String name;
  final String? nameArabic;
  final String? description;
  final String? descriptionArabic;
  final double percentage;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> appliesOnDays;
  final bool appliesToHourly;
  final bool appliesToDaily;
  final List<String>? specificTimeSlotIds;
  final double? minimumBookingAmount;

  Discount({
    required this.id,
    required this.name,
    this.nameArabic,
    this.description,
    this.descriptionArabic,
    required this.percentage,
    required this.startDate,
    required this.endDate,
    required this.appliesOnDays,
    this.appliesToHourly = true,
    this.appliesToDaily = true,
    this.specificTimeSlotIds,
    this.minimumBookingAmount,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
    id: json['id'],
    name: json['name'],
    nameArabic: json['nameArabic'],
    description: json['description'],
    descriptionArabic: json['descriptionArabic'],
    percentage: (json['percentage'] as num).toDouble(),
    startDate: DateUtils.parseISODate(json['startDate']) ?? DateTime.now(),
    endDate: DateUtils.parseISODate(json['endDate']) ?? DateTime.now(),
    appliesOnDays: List<String>.from(json['appliesOnDays'] ?? []),
    appliesToHourly: json['appliesToHourly'] ?? true,
    appliesToDaily: json['appliesToDaily'] ?? true,
    specificTimeSlotIds: json['specificTimeSlotIds'] != null
        ? List<String>.from(json['specificTimeSlotIds'])
        : null,
    minimumBookingAmount: json['minimumBookingAmount'] != null
        ? (json['minimumBookingAmount'] as num).toDouble()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameArabic': nameArabic,
    'description': description,
    'descriptionArabic': descriptionArabic,
    'percentage': percentage,
    'startDate': DateUtils.toISOString(startDate),
    'endDate': DateUtils.toISOString(endDate),
    'appliesOnDays': appliesOnDays,
    'appliesToHourly': appliesToHourly,
    'appliesToDaily': appliesToDaily,
    'specificTimeSlotIds': specificTimeSlotIds,
    'minimumBookingAmount': minimumBookingAmount,
  };

  String getDisplayName(String? languageCode) {
    final isArabic = languageCode == 'ar';
    if (isArabic && nameArabic?.isNotEmpty == true) {
      return nameArabic!;
    }
    return name;
  }
}

/// Payment plan model (enhanced)
class PaymentPlan {
  final bool enabled;
  final double firstPaymentPercentage;
  final int daysBeforeEventForFinalPayment;
  final String? description;
  final String? descriptionArabic;

  PaymentPlan({
    required this.enabled,
    required this.firstPaymentPercentage,
    required this.daysBeforeEventForFinalPayment,
    this.description,
    this.descriptionArabic,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) => PaymentPlan(
    enabled: json['enabled'] as bool? ?? false,
    firstPaymentPercentage: json['firstPaymentPercentage'] != null
        ? (json['firstPaymentPercentage'] as num).toDouble()
        : AppConstants.defaultFirstPaymentPercent,
    daysBeforeEventForFinalPayment: json['daysBeforeEventForFinalPayment'] as int? ??
        AppConstants.defaultDaysBeforeEventForFinalPayment,
    description: json['description'] as String?,
    descriptionArabic: json['descriptionArabic'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'firstPaymentPercentage': firstPaymentPercentage,
    'daysBeforeEventForFinalPayment': daysBeforeEventForFinalPayment,
    'description': description,
    'descriptionArabic': descriptionArabic,
  };

  PaymentCalculationResult calculatePaymentBreakdown(double totalAmount, DateTime eventDate) {
    return PriceCalculator.calculatePaymentBreakdown(
      totalAmount: totalAmount,
      eventDate: eventDate,
      firstPaymentPercent: firstPaymentPercentage,
      daysBeforeEventForFinalPayment: daysBeforeEventForFinalPayment,
    );
  }
}

/// Booking settings for hall
class BookingSettings {
  final bool allowInstantBooking;
  final int maxAdvanceBookingDays;
  final int minAdvanceBookingHours;
  final bool requiresApproval;

  BookingSettings({
    required this.allowInstantBooking,
    required this.maxAdvanceBookingDays,
    required this.minAdvanceBookingHours,
    required this.requiresApproval,
  });

  factory BookingSettings.defaultSettings() {
    return BookingSettings(
      allowInstantBooking: false,
      maxAdvanceBookingDays: AppConstants.maxAdvanceBookingDays,
      minAdvanceBookingHours: AppConstants.minAdvanceBookingHours,
      requiresApproval: true,
    );
  }

  factory BookingSettings.fromJson(Map<String, dynamic> json) {
    return BookingSettings(
      allowInstantBooking: json['allowInstantBooking'] as bool? ?? false,
      maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int? ?? AppConstants.maxAdvanceBookingDays,
      minAdvanceBookingHours: json['minAdvanceBookingHours'] as int? ?? AppConstants.minAdvanceBookingHours,
      requiresApproval: json['requiresApproval'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowInstantBooking': allowInstantBooking,
      'maxAdvanceBookingDays': maxAdvanceBookingDays,
      'minAdvanceBookingHours': minAdvanceBookingHours,
      'requiresApproval': requiresApproval,
    };
  }
}

/// Commission settings for hall
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
}

/// Hall performance statistics
class HallStatistics {
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double averageBookingValue;
  final double occupancyRate;
  final DateTime? lastBookingDate;
  final int viewCount;
  final int favoriteCount;

  HallStatistics({
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.totalRevenue = 0.0,
    this.averageBookingValue = 0.0,
    this.occupancyRate = 0.0,
    this.lastBookingDate,
    this.viewCount = 0,
    this.favoriteCount = 0,
  });

  factory HallStatistics.fromJson(Map<String, dynamic> json) {
    return HallStatistics(
      totalBookings: json['totalBookings'] as int? ?? 0,
      completedBookings: json['completedBookings'] as int? ?? 0,
      cancelledBookings: json['cancelledBookings'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageBookingValue: (json['averageBookingValue'] as num?)?.toDouble() ?? 0.0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      lastBookingDate: DateUtils.parseISODate(json['lastBookingDate'] as String?),
      viewCount: json['viewCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
      'averageBookingValue': averageBookingValue,
      'occupancyRate': occupancyRate,
      'lastBookingDate': lastBookingDate != null ? DateUtils.toISOString(lastBookingDate!) : null,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
    };
  }

  double get cancellationRate {
    if (totalBookings == 0) return 0.0;
    return (cancelledBookings / totalBookings) * 100;
  }

  double get completionRate {
    if (totalBookings == 0) return 0.0;
    return (completedBookings / totalBookings) * 100;
  }

  bool get isPopular => favoriteCount > 10 && viewCount > 100;
}
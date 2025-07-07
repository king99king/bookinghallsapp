// core/utils/validators.dart

import 'dart:io';
import '../constants/app_constants.dart';
import '../constants/firebase_constants.dart';
import 'id_generator.dart';

/// Comprehensive validation utility for all app inputs
class Validators {
  // ========== Email Validation ==========

  /// Validate email address (supports Arabic domains)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    email = email.trim().toLowerCase();

    // Basic email pattern validation
    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Check for Arabic characters in email (not allowed in email addresses)
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(email)) {
      return 'Email cannot contain Arabic characters';
    }

    // Additional validation rules
    if (email.length > 254) {
      return 'Email address is too long';
    }

    if (email.startsWith('.') || email.endsWith('.')) {
      return 'Email cannot start or end with a dot';
    }

    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    return null; // Valid
  }

  // ========== Phone Number Validation ==========

  /// Validate Oman phone number (+968XXXXXXXX)
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }

    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');

    // Ensure it starts with +968
    if (!phone.startsWith('+968')) {
      // Try to fix common formats
      if (phone.startsWith('968')) {
        phone = '+$phone';
      } else if (phone.startsWith('0')) {
        phone = '+968${phone.substring(1)}';
      } else if (phone.length == 8) {
        phone = '+968$phone';
      } else {
        return 'Phone number must start with +968';
      }
    }

    // Validate against Oman phone pattern
    final phoneRegex = RegExp(AppConstants.phoneNumberPattern);
    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid Oman phone number (+968XXXXXXXX)';
    }

    // Additional checks for valid Oman mobile prefixes
    final number = phone.substring(4); // Remove +968
    final validPrefixes = ['9', '7', '8']; // Common Oman mobile prefixes

    if (!validPrefixes.any((prefix) => number.startsWith(prefix))) {
      return 'Invalid Oman mobile number prefix';
    }

    return null; // Valid
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    if (phone.startsWith('+968')) {
      final number = phone.substring(4);
      if (number.length == 8) {
        return '+968 ${number.substring(0, 4)} ${number.substring(4)}';
      }
    }
    return phone;
  }

  // ========== Name Validation ==========

  /// Validate name (supports Arabic and English)
  static String? validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.trim().isEmpty) {
      return '$fieldName is required';
    }

    name = name.trim();

    if (name.length < AppConstants.minNameLength) {
      return '$fieldName must be at least ${AppConstants.minNameLength} characters';
    }

    if (name.length > AppConstants.maxNameLength) {
      return '$fieldName must be less than ${AppConstants.maxNameLength} characters';
    }

    // Allow letters, spaces, Arabic characters, and common name characters
    final nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s\'\-\.]+$');
    if (!nameRegex.hasMatch(name)) {
    return '$fieldName can only contain letters, spaces, and common name characters';
    }

    // Check for excessive spaces
    if (name.contains(RegExp(r'\s{2,}'))) {
    return '$fieldName cannot contain multiple consecutive spaces';
    }

    // Check for leading/trailing spaces
    if (name != name.trim()) {
    return '$fieldName cannot start or end with spaces';
    }

    return null; // Valid
  }

  /// Validate Arabic name specifically
  static String? validateArabicName(String? name, {String fieldName = 'Arabic name'}) {
    if (name == null || name.trim().isEmpty) {
      return null; // Arabic names are optional
    }

    name = name.trim();

    // Must contain at least some Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (!arabicRegex.hasMatch(name)) {
      return '$fieldName must contain Arabic characters';
    }

    return validateName(name, fieldName: fieldName);
  }

  // ========== Price Validation ==========

  /// Validate price/amount
  static String? validatePrice(String? price, {
    String fieldName = 'Price',
    double? minPrice,
    double? maxPrice,
  }) {
    if (price == null || price.trim().isEmpty) {
      return '$fieldName is required';
    }

    final double? amount = double.tryParse(price.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }

    final min = minPrice ?? AppConstants.minPrice;
    final max = maxPrice ?? AppConstants.maxPrice;

    if (amount < min) {
      return '$fieldName must be at least ${AppConstants.formatCurrency(min)}';
    }

    if (amount > max) {
      return '$fieldName cannot exceed ${AppConstants.formatCurrency(max)}';
    }

    // Check for reasonable decimal places (max 2)
    final decimalPlaces = price.contains('.') ? price.split('.')[1].length : 0;
    if (decimalPlaces > 2) {
      return '$fieldName can have maximum 2 decimal places';
    }

    return null; // Valid
  }

  /// Validate commission percentage
  static String? validateCommissionPercent(String? percent) {
    if (percent == null || percent.trim().isEmpty) {
      return 'Commission percentage is required';
    }

    final double? value = double.tryParse(percent.trim());
    if (value == null) {
      return 'Please enter a valid percentage';
    }

    if (value < AppConstants.minCommissionPercent) {
      return 'Commission must be at least ${AppConstants.minCommissionPercent}%';
    }

    if (value > AppConstants.maxCommissionPercent) {
      return 'Commission cannot exceed ${AppConstants.maxCommissionPercent}%';
    }

    return null; // Valid
  }

  // ========== Capacity Validation ==========

  /// Validate hall capacity
  static String? validateCapacity(String? capacity) {
    if (capacity == null || capacity.trim().isEmpty) {
      return 'Capacity is required';
    }

    final int? count = int.tryParse(capacity.trim());
    if (count == null) {
      return 'Please enter a valid number';
    }

    if (count < AppConstants.minCapacity) {
      return 'Capacity must be at least ${AppConstants.minCapacity}';
    }

    if (count > AppConstants.maxCapacity) {
      return 'Capacity cannot exceed ${AppConstants.maxCapacity}';
    }

    return null; // Valid
  }

  // ========== Date and Time Validation ==========

  /// Validate booking date
  static String? validateBookingDate(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    // Check minimum advance booking
    final minAdvanceDate = today.add(Duration(hours: AppConstants.minAdvanceBookingHours));
    if (date.isBefore(minAdvanceDate)) {
      return 'Booking must be at least ${AppConstants.minAdvanceBookingHours} hours in advance';
    }

    // Check maximum advance booking
    final maxAdvanceDate = today.add(Duration(days: AppConstants.maxAdvanceBookingDays));
    if (selectedDate.isAfter(maxAdvanceDate)) {
      return 'Booking cannot be more than ${AppConstants.maxAdvanceBookingDays} days in advance';
    }

    return null; // Valid
  }

  /// Validate time range
  static String? validateTimeRange(String? startTime, String? endTime) {
    if (startTime == null || startTime.trim().isEmpty) {
      return 'Start time is required';
    }

    if (endTime == null || endTime.trim().isEmpty) {
      return 'End time is required';
    }

    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);

      if (start.isAfter(end) || start.isAtSameMomentAs(end)) {
        return 'End time must be after start time';
      }

      final duration = end.difference(start);
      if (duration.inHours < AppConstants.minBookingDuration) {
        return 'Booking duration must be at least ${AppConstants.minBookingDuration} hour(s)';
      }

      if (duration.inHours > AppConstants.maxBookingDuration) {
        return 'Booking duration cannot exceed ${AppConstants.maxBookingDuration} hours';
      }

      return null; // Valid
    } catch (e) {
      return 'Invalid time format';
    }
  }

  /// Parse time string (HH:mm) to DateTime
  static DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) throw FormatException('Invalid time format');

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < 0 || hour > 23) throw FormatException('Invalid hour');
    if (minute < 0 || minute > 59) throw FormatException('Invalid minute');

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // ========== Text Content Validation ==========

  /// Validate description
  static String? validateDescription(String? description, {
    String fieldName = 'Description',
    bool isRequired = true,
  }) {
    if (description == null || description.trim().isEmpty) {
      return isRequired ? '$fieldName is required' : null;
    }

    description = description.trim();

    if (description.length < AppConstants.minDescriptionLength) {
      return '$fieldName must be at least ${AppConstants.minDescriptionLength} characters';
    }

    if (description.length > AppConstants.maxDescriptionLength) {
      return '$fieldName must be less than ${AppConstants.maxDescriptionLength} characters';
    }

    return null; // Valid
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ========== Location Validation ==========

  /// Validate governorate
  static String? validateGovernorate(String? governorate) {
    if (governorate == null || governorate.trim().isEmpty) {
      return 'Governorate is required';
    }

    if (!AppConstants.omanGovernorates.contains(governorate) &&
        !AppConstants.omanGovernoratesArabic.contains(governorate)) {
      return 'Please select a valid Oman governorate';
    }

    return null; // Valid
  }

  /// Validate wilayat
  static String? validateWilayat(String? wilayat, String? governorate) {
    if (wilayat == null || wilayat.trim().isEmpty) {
      return 'Wilayat is required';
    }

    if (governorate != null && governorate.isNotEmpty) {
      final validWilayats = AppConstants.wilayatsByGovernorate[governorate];
      final validWilayatsArabic = AppConstants.wilayatsByGovernorateArabic[governorate];

      if (validWilayats != null && validWilayatsArabic != null) {
        if (!validWilayats.contains(wilayat) && !validWilayatsArabic.contains(wilayat)) {
          return 'Please select a valid wilayat for $governorate';
        }
      }
    }

    return null; // Valid
  }

  /// Validate coordinates
  static String? validateCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Location coordinates are required';
    }

    // Validate latitude range
    if (latitude < -90 || latitude > 90) {
      return 'Invalid latitude value';
    }

    // Validate longitude range
    if (longitude < -180 || longitude > 180) {
      return 'Invalid longitude value';
    }

    // Check if coordinates are within Oman boundaries (approximate)
    if (latitude < 16.0 || latitude > 26.5 || longitude < 51.0 || longitude > 60.0) {
      return 'Location must be within Oman';
    }

    return null; // Valid
  }

  // ========== File Validation ==========

  /// Validate image file
  static String? validateImageFile(File? file) {
    if (file == null) {
      return 'Please select an image';
    }

    // Check file exists
    if (!file.existsSync()) {
      return 'Selected file does not exist';
    }

    // Check file size
    final sizeInMB = file.lengthSync() / (1024 * 1024);
    if (sizeInMB > AppConstants.maxImageSizeInMB) {
      return 'Image size cannot exceed ${AppConstants.maxImageSizeInMB}MB';
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!AppConstants.allowedImageFormats.contains(extension)) {
      return 'Only ${AppConstants.allowedImageFormats.join(', ')} files are allowed';
    }

    return null; // Valid
  }

  /// Validate document file
  static String? validateDocumentFile(File? file) {
    if (file == null) {
      return 'Please select a document';
    }

    // Check file exists
    if (!file.existsSync()) {
      return 'Selected file does not exist';
    }

    // Check file size
    final sizeInMB = file.lengthSync() / (1024 * 1024);
    if (sizeInMB > AppConstants.maxDocumentSizeInMB) {
      return 'Document size cannot exceed ${AppConstants.maxDocumentSizeInMB}MB';
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!AppConstants.allowedDocumentFormats.contains(extension)) {
      return 'Only ${AppConstants.allowedDocumentFormats.join(', ')} files are allowed';
    }

    return null; // Valid
  }

  // ========== ID Validation ==========

  /// Validate entity ID using IdGenerator
  static String? validateEntityId(String? id, String entityType) {
    if (id == null || id.trim().isEmpty) {
      return '$entityType ID is required';
    }

    if (!IdGenerator.isValidId(id)) {
      return 'Invalid $entityType ID format';
    }

    switch (entityType.toLowerCase()) {
      case 'user':
        return IdGenerator.isValidUserId(id) ? null : 'Invalid User ID';
      case 'hall':
        return IdGenerator.isValidHallId(id) ? null : 'Invalid Hall ID';
      case 'booking':
        return IdGenerator.isValidBookingId(id) ? null : 'Invalid Booking ID';
      case 'payment':
        return IdGenerator.isValidPaymentId(id) ? null : 'Invalid Payment ID';
      default:
        return IdGenerator.isValidId(id) ? null : 'Invalid ID format';
    }
  }

  // ========== Business Logic Validation ==========

  /// Validate event type
  static String? validateEventType(String? eventType) {
    if (eventType == null || eventType.trim().isEmpty) {
      return 'Event type is required';
    }

    if (!AppConstants.eventTypes.contains(eventType) &&
        !AppConstants.eventTypesArabic.contains(eventType)) {
      return 'Please select a valid event type';
    }

    return null; // Valid
  }

  /// Validate user type
  static String? validateUserType(String? userType) {
    if (userType == null || userType.trim().isEmpty) {
      return 'User type is required';
    }

    if (!FirebaseConstants.isValidUserType(userType)) {
      return 'Invalid user type';
    }

    return null; // Valid
  }

  /// Validate booking status
  static String? validateBookingStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return 'Booking status is required';
    }

    if (!FirebaseConstants.isValidBookingStatus(status)) {
      return 'Invalid booking status';
    }

    return null; // Valid
  }

  /// Validate payment status
  static String? validatePaymentStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return 'Payment status is required';
    }

    if (!FirebaseConstants.isValidPaymentStatus(status)) {
      return 'Invalid payment status';
    }

    return null; // Valid
  }

  // ========== URL Validation ==========

  /// Validate URL
  static String? validateUrl(String? url, {bool isRequired = false}) {
    if (url == null || url.trim().isEmpty) {
      return isRequired ? 'URL is required' : null;
    }

    url = url.trim();

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'URL must start with http:// or https://';
      }
      return null; // Valid
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  // ========== Rating Validation ==========

  /// Validate rating value
  static String? validateRating(int? rating) {
    if (rating == null) {
      return 'Rating is required';
    }

    if (rating < AppConstants.minRating || rating > AppConstants.maxRating) {
      return 'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}';
    }

    return null; // Valid
  }

  /// Validate review comment
  static String? validateReviewComment(String? comment) {
    if (comment == null || comment.trim().isEmpty) {
      return 'Review comment is required';
    }

    comment = comment.trim();

    if (comment.length < AppConstants.minReviewLength) {
      return 'Review must be at least ${AppConstants.minReviewLength} characters';
    }

    if (comment.length > AppConstants.maxReviewLength) {
      return 'Review must be less than ${AppConstants.maxReviewLength} characters';
    }

    return null; // Valid
  }

  // ========== Tax and Business Validation ==========

  /// Validate Oman tax number (basic format)
  static String? validateTaxNumber(String? taxNumber) {
    if (taxNumber == null || taxNumber.trim().isEmpty) {
      return null; // Optional field
    }

    taxNumber = taxNumber.trim().replaceAll(' ', '').replaceAll('-', '');

    // Basic Oman tax number validation (adjust based on actual format)
    if (taxNumber.length < 8 || taxNumber.length > 15) {
      return 'Tax number must be between 8 and 15 digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(taxNumber)) {
      return 'Tax number can only contain numbers';
    }

    return null; // Valid
  }

  /// Validate IBAN (basic validation)
  static String? validateIBAN(String? iban) {
    if (iban == null || iban.trim().isEmpty) {
      return 'IBAN is required';
    }

    iban = iban.trim().replaceAll(' ', '').toUpperCase();

    // Basic IBAN format check for Oman (OM)
    if (!iban.startsWith('OM')) {
      return 'IBAN must be for Oman (start with OM)';
    }

    if (iban.length != 23) {
      return 'Oman IBAN must be exactly 23 characters';
    }

    if (!RegExp(r'^OM\d{21}$').hasMatch(iban)) {
      return 'Invalid IBAN format';
    }

    return null; // Valid
  }

  // ========== Utility Methods ==========

  /// Combine multiple validation results
  static String? combineValidations(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Validate all fields in a form and return first error
  static String? validateForm(Map<String, String? Function()> validations) {
    for (final entry in validations.entries) {
      final error = entry.value();
      if (error != null) {
        return '${entry.key}: $error';
      }
    }
    return null;
  }

  /// Clean and normalize text input
  static String cleanText(String? text) {
    if (text == null) return '';
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if string contains only Arabic characters
  static bool isArabicText(String text) {
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return arabicRegex.hasMatch(text.trim());
  }

  /// Check if string contains only English characters
  static bool isEnglishText(String text) {
    final englishRegex = RegExp(r'^[a-zA-Z\s]+$');
    return englishRegex.hasMatch(text.trim());
  }

  /// Format error message for display
  static String formatErrorMessage(String? error, {String? fieldName}) {
    if (error == null) return '';

    if (fieldName != null && !error.toLowerCase().contains(fieldName.toLowerCase())) {
      return '$fieldName: $error';
    }

    return error;
  }
}
// core/extensions/string_extension.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Comprehensive string extensions for Arabic/English text handling
extension StringExtension on String {

  // ========== Basic String Operations ==========

  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Get string or default value if empty
  String orDefault(String defaultValue) => isEmpty ? defaultValue : this;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize)
        .join(' ');
  }

  /// Remove extra whitespace
  String get cleanWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Truncate string to specified number of words
  String truncateWords(int maxWords, {String suffix = '...'}) {
    final words = trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$suffix';
  }

  // ========== Arabic Text Detection ==========

  /// Check if text contains Arabic characters
  bool get hasArabic {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(this);
  }

  /// Check if text is primarily Arabic
  bool get isArabic {
    if (isEmpty) return false;
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final arabicMatches = arabicRegex.allMatches(this);
    final arabicCharCount = arabicMatches.length;
    final totalChars = replaceAll(RegExp(r'\s'), '').length;
    return totalChars > 0 && (arabicCharCount / totalChars) > 0.5;
  }

  /// Check if text is primarily English
  bool get isEnglish {
    if (isEmpty) return false;
    final englishRegex = RegExp(r'[a-zA-Z]');
    final englishMatches = englishRegex.allMatches(this);
    final englishCharCount = englishMatches.length;
    final totalChars = replaceAll(RegExp(r'\s'), '').length;
    return totalChars > 0 && (englishCharCount / totalChars) > 0.5;
  }

  /// Get text direction based on content
  TextDirection get textDirection => isArabic ? TextDirection.RTL : TextDirection.LTR;

  /// Check if text contains mixed languages
  bool get isMixed => hasArabic && contains(RegExp(r'[a-zA-Z]'));

  // ========== Arabic Number Formatting ==========

  /// Convert Western numerals to Arabic-Indic numerals
  String get toArabicNumerals {
    const westernToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    String result = this;
    westernToArabic.forEach((western, arabic) {
      result = result.replaceAll(western, arabic);
    });
    return result;
  }

  /// Convert Arabic-Indic numerals to Western numerals
  String get toWesternNumerals {
    const arabicToWestern = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String result = this;
    arabicToWestern.forEach((arabic, western) {
      result = result.replaceAll(arabic, western);
    });
    return result;
  }

  /// Format numbers based on locale
  String formatNumberForLocale(String languageCode) {
    return languageCode == 'ar' ? toArabicNumerals : toWesternNumerals;
  }

  // ========== Validation Helpers ==========

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(AppConstants.emailPattern);
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid Oman phone number
  bool get isValidOmanPhone {
    final phoneRegex = RegExp(AppConstants.phoneNumberPattern);
    return phoneRegex.hasMatch(this);
  }

  /// Check if string contains only numeric characters
  bool get isNumeric {
    return double.tryParse(toWesternNumerals) != null;
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Check if string contains special characters
  bool get hasSpecialCharacters {
    final specialCharsRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return specialCharsRegex.hasMatch(this);
  }

  /// Check if string has minimum length
  bool hasMinLength(int minLength) => length >= minLength;

  /// Check if string has maximum length
  bool hasMaxLength(int maxLength) => length <= maxLength;

  // ========== Date and Time Formatting ==========

  /// Parse string as DateTime
  DateTime? get toDateTime {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Parse string as double
  double? get toDouble {
    try {
      return double.parse(toWesternNumerals);
    } catch (e) {
      return null;
    }
  }

  /// Parse string as int
  int? get toInt {
    try {
      return int.parse(toWesternNumerals);
    } catch (e) {
      return null;
    }
  }

  /// Format as currency
  String toCurrency({String? languageCode}) {
    final amount = toDouble;
    if (amount == null) return this;

    final isArabic = languageCode == 'ar';
    final formattedAmount = amount.toStringAsFixed(2);
    final localizedAmount = formattedAmount.formatNumberForLocale(languageCode ?? 'en');

    if (isArabic) {
      return '$localizedAmount ${AppConstants.currencySymbol}';
    } else {
      return '${AppConstants.currencySymbol} $localizedAmount';
    }
  }

  // ========== Text Transformation ==========

  /// Remove diacritics from Arabic text
  String get removeDiacritics {
    // Arabic diacritics Unicode ranges
    const diacritics = [
      '\u064B', '\u064C', '\u064D', '\u064E', '\u064F', // Fatha, Damma, Kasra, etc.
      '\u0650', '\u0651', '\u0652', '\u0653', '\u0654', // Shadda, Sukun, etc.
      '\u0655', '\u0656', '\u0657', '\u0658', '\u0659',
      '\u065A', '\u065B', '\u065C', '\u065D', '\u065E',
      '\u065F', '\u0670', '\u06D6', '\u06D7', '\u06D8',
      '\u06D9', '\u06DA', '\u06DB', '\u06DC', '\u06DF',
      '\u06E0', '\u06E1', '\u06E2', '\u06E3', '\u06E4',
      '\u06E7', '\u06E8', '\u06EA', '\u06EB', '\u06EC',
      '\u06ED'
    ];

    String result = this;
    for (final diacritic in diacritics) {
      result = result.replaceAll(diacritic, '');
    }
    return result;
  }

  /// Normalize Arabic text for search
  String get normalizeArabic {
    return removeDiacritics
        .replaceAll('أ', 'ا')  // Replace alif with hamza
        .replaceAll('إ', 'ا')  // Replace alif with hamza below
        .replaceAll('آ', 'ا')  // Replace alif with madda
        .replaceAll('ة', 'ه')  // Replace taa marbouta with haa
        .replaceAll('ي', 'ى')  // Replace yaa with alif maksura
        .trim();
  }

  /// Convert to search-friendly format
  String get toSearchFormat {
    if (isArabic) {
      return normalizeArabic.toLowerCase();
    } else {
      return toLowerCase().cleanWhitespace;
    }
  }

  // ========== Security and Sanitization ==========

  /// Remove HTML tags
  String get removeHtmlTags => replaceAll(RegExp(r'<[^>]*>'), '');

  /// Escape special characters for SQL
  String get escapeSql {
    return replaceAll("'", "''")
        .replaceAll('"', '""')
        .replaceAll('\\', '\\\\');
  }

  /// Mask sensitive information (email, phone)
  String get maskSensitive {
    if (isValidEmail) {
      final parts = split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domain = parts[1];
        final maskedUsername = username.length > 2
            ? '${username.substring(0, 2)}${'*' * (username.length - 2)}'
            : username;
        return '$maskedUsername@$domain';
      }
    }

    if (isValidOmanPhone) {
      if (length > 6) {
        return '${substring(0, 4)}${'*' * (length - 6)}${substring(length - 2)}';
      }
    }

    return this;
  }

  // ========== Localization Helpers ==========

  /// Get localized version of common terms
  String localizeCommonTerm(String languageCode) {
    if (languageCode != 'ar') return this;

    const commonTerms = {
      'wedding': 'زفاف',
      'birthday': 'عيد ميلاد',
      'corporate': 'شركات',
      'conference': 'مؤتمر',
      'graduation': 'تخرج',
      'anniversary': 'ذكرى سنوية',
      'cultural': 'ثقافي',
      'sports': 'رياضي',
      'exhibition': 'معرض',
      'other': 'أخرى',
      'monday': 'الاثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
      'saturday': 'السبت',
      'sunday': 'الأحد',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'yesterday': 'أمس',
      'morning': 'صباحي',
      'afternoon': 'بعد الظهر',
      'evening': 'مسائي',
      'full_day': 'يوم كامل',
    };

    return commonTerms[toLowerCase()] ?? this;
  }

  /// Get governorate in Arabic
  String get governorateInArabic {
    return AppConstants.getGovernorateArabic(this);
  }

  /// Get event type in Arabic
  String get eventTypeInArabic {
    return AppConstants.getEventTypeArabic(this);
  }

  /// Get amenity in Arabic
  String get amenityInArabic {
    return AppConstants.getAmenityArabic(this);
  }

  // ========== File and Path Helpers ==========

  /// Get file extension
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    return lastDot == -1 ? '' : substring(lastDot + 1).toLowerCase();
  }

  /// Get filename without extension
  String get filenameWithoutExtension {
    final lastDot = lastIndexOf('.');
    final lastSlash = lastIndexOf('/');
    final start = lastSlash == -1 ? 0 : lastSlash + 1;
    final end = lastDot == -1 ? length : lastDot;
    return substring(start, end);
  }

  /// Check if file is an image
  bool get isImageFile {
    return AppConstants.allowedImageFormats.contains(fileExtension);
  }

  /// Check if file is a document
  bool get isDocumentFile {
    return AppConstants.allowedDocumentFormats.contains(fileExtension);
  }

  // ========== ID and Code Helpers ==========

  /// Check if string is a valid structured ID
  bool get isValidStructuredId {
    final regex = RegExp(r'^[A-Z]+_(\d{8}|FB_\d+)_\d{3}$');
    return regex.hasMatch(this);
  }

  /// Extract prefix from structured ID
  String get idPrefix {
    if (!isValidStructuredId) return '';
    return split('_').first;
  }

  /// Extract date from structured ID
  String get idDate {
    if (!isValidStructuredId) return '';
    final parts = split('_');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Extract sequence from structured ID
  String get idSequence {
    if (!isValidStructuredId) return '';
    return split('_').last;
  }

  /// Get short version of ID (last 6 characters)
  String get shortId {
    if (length <= 6) return this;
    return substring(length - 6);
  }

  // ========== Color Helpers ==========

  /// Convert hex color string to Color
  Color get toColor {
    try {
      String hexColor = replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor'; // Add alpha if not provided
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.transparent;
    }
  }

  // ========== Search and Matching ==========

  /// Check if string contains query (case-insensitive, normalized)
  bool containsQuery(String query) {
    final normalizedThis = toSearchFormat;
    final normalizedQuery = query.toSearchFormat;
    return normalizedThis.contains(normalizedQuery);
  }

  /// Get similarity score with another string (0.0 to 1.0)
  double similarityWith(String other) {
    if (isEmpty && other.isEmpty) return 1.0;
    if (isEmpty || other.isEmpty) return 0.0;

    final thisNormalized = toSearchFormat;
    final otherNormalized = other.toSearchFormat;

    // Simple Levenshtein distance implementation
    final matrix = List.generate(
      thisNormalized.length + 1,
          (i) => List.generate(otherNormalized.length + 1, (j) => 0),
    );

    for (int i = 0; i <= thisNormalized.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= otherNormalized.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= thisNormalized.length; i++) {
      for (int j = 1; j <= otherNormalized.length; j++) {
        final cost = thisNormalized[i - 1] == otherNormalized[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,     // deletion
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    final maxLength = [thisNormalized.length, otherNormalized.length].reduce((a, b) => a > b ? a : b);
    return 1.0 - (matrix[thisNormalized.length][otherNormalized.length] / maxLength);
  }

  // ========== Utility Methods ==========

  /// Generate slug from string
  String get slug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
        .replaceAll(RegExp(r'\s+'), '-')     // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-')      // Remove multiple hyphens
        .replaceAll(RegExp(r'^-|-$'), '');   // Remove leading/trailing hyphens
  }

  /// Convert to title case
  String get toTitleCase {
    return split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Reverse string
  String get reverse {
    return split('').reversed.join('');
  }

  /// Count words
  int get wordCount {
    return trim().isEmpty ? 0 : trim().split(RegExp(r'\s+')).length;
  }

  /// Count characters (excluding spaces)
  int get characterCount {
    return replaceAll(' ', '').length;
  }

  /// Check if string is palindrome
  bool get isPalindrome {
    final normalized = toLowerCase().replaceAll(RegExp(r'\s'), '');
    return normalized == normalized.reverse;
  }
}

/// Extension for nullable strings
extension NullableStringExtension on String? {

  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Get string or default value
  String orDefault(String defaultValue) => isNullOrEmpty ? defaultValue : this!;

  /// Get string or empty string
  String get orEmpty => this ?? '';

  /// Safe capitalize
  String get safeCapitalize => orEmpty.capitalize;

  /// Safe length
  int get safeLength => orEmpty.length;

  /// Safe contains check
  bool safeContains(String other) => orEmpty.contains(other);
}
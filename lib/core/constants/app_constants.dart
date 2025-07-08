// core/constants/app_constants.dart

class AppConstants {
  // App Information
  static const String appName = 'HallBooking';
  static const String appNameArabic = 'حجز القاعات';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@hallbooking.om';
  static const String supportPhone = '+968XXXXXXXX';

  // Default Values
  static const String defaultLanguage = 'en';
  static const String fallbackLanguage = 'en';
  static const String defaultCurrency = 'OMR';
  static const String currencySymbol = 'ر.ع';

  // Commission Settings (Default percentages)
  static const double defaultCustomerCommissionPercent = 5.0;
  static const double defaultOwnerCommissionPercent = 3.0;
  static const double minCommissionPercent = 1.0;
  static const double maxCommissionPercent = 15.0;

  // Payment Settings
  static const double defaultFirstPaymentPercent = 60.0;
  static const int defaultDaysBeforeEventForFinalPayment = 7;
  static const int maxAdvanceBookingDays = 365;
  static const int minAdvanceBookingHours = 24;
  static const int paymentTimeoutMinutes = 15;
  static const int paymentTimeoutHours = 24;
  static const int commissionPaymentDueDays = 30;

  // Cancellation Policy
  static const int defaultCancellationHours = 48;
  static const double defaultRefundPercentage = 80.0;
  static const int minCancellationHours = 24;
  static const int minModificationHours = 48;

  // Review Settings
  static const int reviewEditTimeLimit = 24; // hours
  static const int reviewAutoModerationThreshold = 3; // reports
  static const int minHelpfulVotes = 2;
  static const List<String> inappropriateWords = [
    'spam', 'offensive', 'inappropriate', 'fake', 'scam'
  ];

  // System Settings
  static const String systemUserId = 'SYSTEM';
  static const String systemUserName = 'System';
  static const String systemUserEmail = 'system@hallbooking.om';

  // Validation Constants
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  static const int minCapacity = 10;
  static const int maxCapacity = 5000;
  static const double minPrice = 1.0;
  static const double maxPrice = 10000.0;
  static const int minPhoneLength = 8;
  static const int maxPhoneLength = 15;

  // File Upload Limits
  static const int maxImageSizeInMB = 5;
  static const int maxDocumentSizeInMB = 10;
  static const int maxImagesPerHall = 10;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx'];

  // Booking Constraints
  static const int maxBookingDuration = 24; // hours
  static const int minBookingDuration = 1; // hours
  static const double minHourlyRate = 5.0;
  static const double maxHourlyRate = 500.0;

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  static const int searchResultsLimit = 20;

  // Search and Filter
  static const double defaultSearchRadius = 50.0; // km
  static const double maxSearchRadius = 200.0; // km
  static const int searchQueryMinLength = 2;
  static const int searchQueryMaxLength = 100;

  // Rating System
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;

  // Time Constants
  static const int sessionTimeoutMinutes = 30;
  static const int cacheExpirationHours = 24;
  static const int tokenRefreshThresholdMinutes = 5;

  // Network
  static const int apiTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 120;
  static const int maxRetryAttempts = 3;

  // Notification Settings
  static const int maxNotificationTitle = 100;
  static const int maxNotificationBody = 500;
  static const int notificationRetentionDays = 30;

  // Admin Settings
  static const int maxAdminUsers = 50;
  static const List<String> availableAdminRoles = [
    'super_admin',
    'content_moderator',
    'support',
    'finance'
  ];

  // Hall Status
  static const List<String> hallStatuses = [
    'pending',
    'approved',
    'rejected',
    'suspended'
  ];

  // Booking Status
  static const List<String> bookingStatuses = [
    'pending',
    'confirmed',
    'payment_pending',
    'completed',
    'cancelled'
  ];

  // Payment Status
  static const List<String> paymentStatuses = [
    'pending',
    'first_paid',
    'fully_paid',
    'failed',
    'refunded'
  ];

  // User Types
  static const List<String> userTypes = [
    'customer',
    'hall_owner',
    'admin'
  ];

  // Auth Providers
  static const List<String> authProviders = [
    'google',
    'apple'
  ];

  // Days of Week
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  static const List<String> daysOfWeekArabic = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];

  // Oman Governorates
  static const List<String> omanGovernorates = [
    'Muscat',
    'Dhofar',
    'Al Batinah North',
    'Al Batinah South',
    'Al Dakhiliyah',
    'Al Dhahirah',
    'Al Sharqiyah North',
    'Al Sharqiyah South',
    'Al Wusta',
    'Musandam',
    'Al Buraimi'
  ];

  static const List<String> omanGovernoratesArabic = [
    'مسقط',
    'ظفار',
    'الباطنة شمال',
    'الباطنة جنوب',
    'الداخلية',
    'الظاهرة',
    'الشرقية شمال',
    'الشرقية جنوب',
    'الوسطى',
    'مسندم',
    'البريمي'
  ];

  // Wilayats by Governorate (Sample - you can expand this)
  static const Map<String, List<String>> wilayatsByGovernorate = {
    'Muscat': [
      'Muscat',
      'Mutrah',
      'Al Seeb',
      'Qurayyat',
      'Al Amerat',
      'Bausher'
    ],
    'Dhofar': [
      'Salalah',
      'Taqah',
      'Mirbat',
      'Rakhyut',
      'Thumrait',
      'Dalkut'
    ],
    // Add more wilayats as needed
  };

  static const Map<String, List<String>> wilayatsByGovernorateArabic = {
    'مسقط': [
      'مسقط',
      'مطرح',
      'السيب',
      'قريات',
      'العامرات',
      'بوشر'
    ],
    'ظفار': [
      'صلالة',
      'طاقة',
      'مرباط',
      'رخيوت',
      'ثمريت',
      'دلكوت'
    ],
    // Add more wilayats as needed
  };

  // Event Types
  static const List<String> eventTypes = [
    'wedding',
    'birthday',
    'corporate',
    'conference',
    'graduation',
    'anniversary',
    'cultural',
    'sports',
    'exhibition',
    'other'
  ];

  static const List<String> eventTypesArabic = [
    'زفاف',
    'عيد ميلاد',
    'شركات',
    'مؤتمر',
    'تخرج',
    'ذكرى سنوية',
    'ثقافي',
    'رياضي',
    'معرض',
    'أخرى'
  ];

  // Amenities (Sample)
  static const List<String> commonAmenities = [
    'parking',
    'wifi',
    'air_conditioning',
    'sound_system',
    'lighting',
    'stage',
    'kitchen',
    'prayer_room',
    'wheelchair_access',
    'security',
    'decorations',
    'catering'
  ];

  static const List<String> commonAmenitiesArabic = [
    'موقف سيارات',
    'واي فاي',
    'تكييف',
    'نظام صوتي',
    'إضاءة',
    'منصة',
    'مطبخ',
    'مصلى',
    'كراسي متحركة',
    'أمن',
    'ديكورات',
    'تموين'
  ];

  // Default Time Slots (24-hour format)
  static const List<Map<String, String>> defaultTimeSlots = [
    {'start': '08:00', 'end': '12:00', 'name': 'Morning'},
    {'start': '13:00', 'end': '17:00', 'name': 'Afternoon'},
    {'start': '18:00', 'end': '23:00', 'name': 'Evening'},
    {'start': '08:00', 'end': '23:59', 'name': 'Full Day'},
  ];

  static const List<Map<String, String>> defaultTimeSlotsArabic = [
    {'start': '08:00', 'end': '12:00', 'name': 'صباحي'},
    {'start': '13:00', 'end': '17:00', 'name': 'بعد الظهر'},
    {'start': '18:00', 'end': '23:00', 'name': 'مسائي'},
    {'start': '08:00', 'end': '23:59', 'name': 'يوم كامل'},
  ];

  // Image Placeholder URLs
  static const String defaultHallImage = 'assets/images/default_hall.png';
  static const String defaultUserAvatar = 'assets/images/default_avatar.png';
  static const String logoImage = 'assets/images/logo.png';
  static const String splashBackground = 'assets/images/splash_bg.png';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce Durations
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const Duration buttonDebounceDelay = Duration(milliseconds: 1000);

  // URL Patterns
  static const String phoneNumberPattern = r'^\+968[0-9]{8}$';
  static const String emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String strongPasswordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
  static const String authErrorMessage = 'Authentication failed. Please sign in again.';

  // Success Messages
  static const String bookingSuccessMessage = 'Booking confirmed successfully!';
  static const String paymentSuccessMessage = 'Payment completed successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Helper Methods
  static String formatCurrency(double amount) {
    return '$currencySymbol ${amount.toStringAsFixed(2)}';
  }

  static String getGovernorateArabic(String englishName) {
    final index = omanGovernorates.indexOf(englishName);
    return index != -1 ? omanGovernoratesArabic[index] : englishName;
  }

  static String getEventTypeArabic(String englishType) {
    final index = eventTypes.indexOf(englishType);
    return index != -1 ? eventTypesArabic[index] : englishType;
  }

  static String getAmenityArabic(String englishAmenity) {
    final index = commonAmenities.indexOf(englishAmenity);
    return index != -1 ? commonAmenitiesArabic[index] : englishAmenity;
  }

  static String getDayOfWeekArabic(String englishDay) {
    final index = daysOfWeek.indexOf(englishDay);
    return index != -1 ? daysOfWeekArabic[index] : englishDay;
  }
}
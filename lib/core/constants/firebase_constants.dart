// core/constants/firebase_constants.dart

class FirebaseConstants {
  // Collection Names
  static const String usersCollection = 'users';
  static const String adminUsersCollection = 'admin_users';
  static const String hallOwnersCollection = 'hall_owners';
  static const String hallsCollection = 'halls';
  static const String bookingsCollection = 'bookings';
  static const String paymentsCollection = 'payments';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String categoriesCollection = 'categories';
  static const String appSettingsCollection = 'app_settings';
  static const String transactionsCollection = 'transactions';
  static const String commissionsCollection = 'commissions';
  static const String auditLogsCollection = 'audit_logs';

  // SubCollection Names
  static const String userNotificationsSubCollection = 'notifications';
  static const String userBookingsSubCollection = 'bookings';
  static const String hallReviewsSubCollection = 'reviews';
  static const String hallBookingsSubCollection = 'bookings';
  static const String ownerHallsSubCollection = 'halls';
  static const String ownerEarningsSubCollection = 'earnings';

  // Common Field Names
  static const String idField = 'id';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String isActiveField = 'isActive';
  static const String isApprovedField = 'isApproved';
  static const String statusField = 'status';

  // User Fields
  static const String userIdField = 'userId';
  static const String emailField = 'email';
  static const String authProviderField = 'authProvider';
  static const String providerUserIdField = 'providerUserId';
  static const String displayNameField = 'displayName';
  static const String profileImageUrlField = 'profileImageUrl';
  static const String phoneNumberField = 'phoneNumber';
  static const String firstNameField = 'firstName';
  static const String lastNameField = 'lastName';
  static const String firstNameArabicField = 'firstNameArabic';
  static const String lastNameArabicField = 'lastNameArabic';
  static const String userTypeField = 'userType';
  static const String governorateField = 'governorate';
  static const String wilayatField = 'wilayat';
  static const String isVerifiedField = 'isVerified';
  static const String isProfileCompletedField = 'isProfileCompleted';
  static const String lastLoginAtField = 'lastLoginAt';
  static const String preferredLanguageField = 'preferredLanguage';
  static const String fcmTokensField = 'fcmTokens';
  static const String notificationSettingsField = 'notificationSettings';

  // Admin User Fields
  static const String adminIdField = 'adminId';
  static const String roleField = 'role';
  static const String permissionsField = 'permissions';
  static const String assignedByField = 'assignedBy';
  static const String assignedAtField = 'assignedAt';

  // Hall Owner Fields
  static const String ownerIdField = 'ownerId';
  static const String businessNameField = 'businessName';
  static const String businessNameArabicField = 'businessNameArabic';
  static const String businessLicenseField = 'businessLicense';
  static const String taxNumberField = 'taxNumber';
  static const String bankDetailsField = 'bankDetails';
  static const String commissionSettingsField = 'commissionSettings';
  static const String approvedByField = 'approvedBy';
  static const String approvedAtField = 'approvedAt';
  static const String totalEarningsField = 'totalEarnings';
  static const String totalBookingsField = 'totalBookings';
  static const String ratingField = 'rating';

  // Hall Fields
  static const String hallIdField = 'hallId';
  static const String nameField = 'name';
  static const String nameArabicField = 'nameArabic';
  static const String descriptionField = 'description';
  static const String descriptionArabicField = 'descriptionArabic';
  static const String ownerNameField = 'ownerName';
  static const String basePriceField = 'basePrice';
  static const String dailyPricingField = 'dailyPricing';
  static const String hourlyRateField = 'hourlyRate';
  static const String hourlyRatesByDayField = 'hourlyRatesByDay';
  static const String allowsDailyBookingField = 'allowsDailyBooking';
  static const String allowsHourlyBookingField = 'allowsHourlyBooking';
  static const String availableTimeSlotsField = 'availableTimeSlots';
  static const String capacityField = 'capacity';
  static const String addressField = 'address';
  static const String locationField = 'location';
  static const String latitudeField = 'latitude';
  static const String longitudeField = 'longitude';
  static const String locationUrlField = 'locationUrl';
  static const String imageUrlsField = 'imageUrls';
  static const String categoryIdsField = 'categoryIds';
  static const String amenitiesField = 'amenities';
  static const String servicesField = 'services';
  static const String isFeaturedField = 'isFeatured';
  static const String contactPhoneField = 'contactPhone';
  static const String contactEmailField = 'contactEmail';
  static const String regulationsField = 'regulations';
  static const String regulationsArabicField = 'regulationsArabic';
  static const String reviewCountField = 'reviewCount';
  static const String profitField = 'profit';
  static const String discountsField = 'discounts';
  static const String paymentPlanField = 'paymentPlan';
  static const String bookingSettingsField = 'bookingSettings';

  // Booking Fields
  static const String bookingIdField = 'bookingId';
  static const String bookingTypeField = 'bookingType';
  static const String eventDateField = 'eventDate';
  static const String timeSlotField = 'timeSlot';
  static const String guestCountField = 'guestCount';
  static const String eventTypeField = 'eventType';
  static const String eventDescriptionField = 'eventDescription';
  static const String contactInfoField = 'contactInfo';
  static const String pricingField = 'pricing';
  static const String paymentStatusField = 'paymentStatus';
  static const String cancellationReasonField = 'cancellationReason';
  static const String ownerApprovalStatusField = 'ownerApprovalStatus';
  static const String ownerApprovedAtField = 'ownerApprovedAt';

  // Payment Fields
  static const String paymentIdField = 'paymentId';
  static const String paymentTypeField = 'paymentType';
  static const String amountField = 'amount';
  static const String paymentMethodField = 'paymentMethod';
  static const String thawaniTransactionIdField = 'thawaniTransactionId';
  static const String processedAtField = 'processedAt';
  static const String failureReasonField = 'failureReason';
  static const String refundAmountField = 'refundAmount';
  static const String refundReasonField = 'refundReason';
  static const String commissionBreakdownField = 'commissionBreakdown';

  // Review Fields
  static const String reviewIdField = 'reviewId';
  static const String commentField = 'comment';
  static const String commentArabicField = 'commentArabic';
  static const String imagesField = 'images';
  static const String ownerResponseField = 'ownerResponse';
  static const String ownerResponseDateField = 'ownerResponseDate';

  // Notification Fields
  static const String notificationIdField = 'notificationId';
  static const String typeField = 'type';
  static const String titleField = 'title';
  static const String titleArabicField = 'titleArabic';
  static const String bodyField = 'body';
  static const String bodyArabicField = 'bodyArabic';
  static const String dataField = 'data';
  static const String isReadField = 'isRead';
  static const String sentAtField = 'sentAt';

  // Category Fields
  static const String categoryIdField = 'categoryId';
  static const String iconField = 'icon';
  static const String orderField = 'order';

  // App Settings Fields
  static const String settingIdField = 'settingId';
  static const String keyField = 'key';
  static const String valueField = 'value';
  static const String updatedByField = 'updatedBy';

  // Storage Bucket Paths
  static const String hallImagesPath = 'hall_images';
  static const String userAvatarsPath = 'user_avatars';
  static const String businessDocumentsPath = 'business_documents';
  static const String reviewImagesPath = 'review_images';
  static const String categoryIconsPath = 'category_icons';

  // Cloud Functions
  static const String processPaymentFunction = 'processPayment';
  static const String refundPaymentFunction = 'refundPayment';
  static const String calculateCommissionFunction = 'calculateCommission';
  static const String sendNotificationFunction = 'sendNotification';
  static const String generateBookingIdFunction = 'generateBookingId';
  static const String validateBookingFunction = 'validateBooking';
  static const String updateHallStatisticsFunction = 'updateHallStatistics';
  static const String sendBookingConfirmationFunction = 'sendBookingConfirmation';
  static const String handlePaymentWebhookFunction = 'handlePaymentWebhook';
  static const String processRefundFunction = 'processRefund';

  // Indexes (for Firestore queries)
  static const List<String> hallSearchIndexes = [
    'name',
    'categoryIds',
    'governorate',
    'wilayat',
    'isApproved',
    'isActive',
    'isFeatured'
  ];

  static const List<String> bookingQueryIndexes = [
    'userId',
    'hallId',
    'ownerId',
    'eventDate',
    'status',
    'paymentStatus',
    'createdAt'
  ];

  static const List<String> userQueryIndexes = [
    'userType',
    'governorate',
    'wilayat',
    'isActive',
    'isVerified',
    'createdAt'
  ];

  // Notification Types
  static const String bookingConfirmedNotification = 'booking_confirmed';
  static const String bookingCancelledNotification = 'booking_cancelled';
  static const String paymentSuccessNotification = 'payment_success';
  static const String paymentFailedNotification = 'payment_failed';
  static const String paymentReminderNotification = 'payment_reminder';
  static const String hallApprovedNotification = 'hall_approved';
  static const String hallRejectedNotification = 'hall_rejected';
  static const String reviewSubmittedNotification = 'review_submitted';
  static const String bookingRequestNotification = 'booking_request';
  static const String newHallSubmissionNotification = 'new_hall_submission';
  static const String systemMaintenanceNotification = 'system_maintenance';
  static const String promotionalNotification = 'promotional';

  // User Types
  static const String customerUserType = 'customer';
  static const String hallOwnerUserType = 'hall_owner';
  static const String adminUserType = 'admin';

  // Auth Providers
  static const String googleAuthProvider = 'google';
  static const String appleAuthProvider = 'apple';

  // Booking Types
  static const String dailyBookingType = 'daily';
  static const String hourlyBookingType = 'hourly';

  // Booking Statuses
  static const String pendingBookingStatus = 'pending';
  static const String confirmedBookingStatus = 'confirmed';
  static const String paymentPendingBookingStatus = 'payment_pending';
  static const String completedBookingStatus = 'completed';
  static const String cancelledBookingStatus = 'cancelled';

  // Payment Statuses
  static const String pendingPaymentStatus = 'pending';
  static const String firstPaidPaymentStatus = 'first_paid';
  static const String fullyPaidPaymentStatus = 'fully_paid';
  static const String failedPaymentStatus = 'failed';
  static const String refundedPaymentStatus = 'refunded';

  // Payment Types
  static const String firstPaymentType = 'first_payment';
  static const String secondPaymentType = 'second_payment';
  static const String fullPaymentType = 'full_payment';

  // Admin Roles
  static const String superAdminRole = 'super_admin';
  static const String contentModeratorRole = 'content_moderator';
  static const String supportRole = 'support';
  static const String financeRole = 'finance';

  // Admin Permissions
  static const String manageUsersPermission = 'manage_users';
  static const String manageHallsPermission = 'manage_halls';
  static const String manageBookingsPermission = 'manage_bookings';
  static const String managePaymentsPermission = 'manage_payments';
  static const String viewAnalyticsPermission = 'view_analytics';
  static const String manageSettingsPermission = 'manage_settings';
  static const String manageNotificationsPermission = 'manage_notifications';
  static const String manageReviewsPermission = 'manage_reviews';

  // Approval Statuses
  static const String pendingApprovalStatus = 'pending';
  static const String approvedStatus = 'approved';
  static const String rejectedStatus = 'rejected';

  // Hall Statuses
  static const String pendingHallStatus = 'pending';
  static const String approvedHallStatus = 'approved';
  static const String rejectedHallStatus = 'rejected';
  static const String suspendedHallStatus = 'suspended';

  // Payment Methods
  static const String thawaniPaymentMethod = 'thawani';
  static const String creditCardPaymentMethod = 'credit_card';
  static const String debitCardPaymentMethod = 'debit_card';

  // Languages
  static const String englishLanguage = 'en';
  static const String arabicLanguage = 'ar';

  // Query Limits
  static const int defaultQueryLimit = 10;
  static const int maxQueryLimit = 50;
  static const int searchResultsLimit = 20;

  // Cache Keys
  static const String userCacheKey = 'user_cache';
  static const String hallsCacheKey = 'halls_cache';
  static const String categoriesCacheKey = 'categories_cache';
  static const String settingsCacheKey = 'settings_cache';

  // Error Codes
  static const String insufficientPermissionsError = 'insufficient_permissions';
  static const String userNotFoundError = 'user_not_found';
  static const String hallNotFoundError = 'hall_not_found';
  static const String bookingNotFoundError = 'booking_not_found';
  static const String paymentFailedError = 'payment_failed';
  static const String bookingConflictError = 'booking_conflict';
  static const String invalidDataError = 'invalid_data';
  static const String networkError = 'network_error';
  static const String unknownError = 'unknown_error';

  // Success Codes
  static const String operationSuccessful = 'operation_successful';
  static const String bookingCreated = 'booking_created';
  static const String paymentProcessed = 'payment_processed';
  static const String profileUpdated = 'profile_updated';
  static const String hallCreated = 'hall_created';
  static const String hallUpdated = 'hall_updated';

  // Firestore Query Operators
  static const String equalToOperator = '==';
  static const String notEqualToOperator = '!=';
  static const String lessThanOperator = '<';
  static const String lessThanOrEqualToOperator = '<=';
  static const String greaterThanOperator = '>';
  static const String greaterThanOrEqualToOperator = '>=';
  static const String arrayContainsOperator = 'array-contains';
  static const String arrayContainsAnyOperator = 'array-contains-any';
  static const String inOperator = 'in';
  static const String notInOperator = 'not-in';

  // Order By Directions
  static const String ascendingOrder = 'asc';
  static const String descendingOrder = 'desc';

  // Helper Methods
  static String getUserDocumentPath(String userId) {
    return '$usersCollection/$userId';
  }

  static String getHallDocumentPath(String hallId) {
    return '$hallsCollection/$hallId';
  }

  static String getBookingDocumentPath(String bookingId) {
    return '$bookingsCollection/$bookingId';
  }

  static String getPaymentDocumentPath(String paymentId) {
    return '$paymentsCollection/$paymentId';
  }

  static String getUserNotificationPath(String userId, String notificationId) {
    return '$usersCollection/$userId/$userNotificationsSubCollection/$notificationId';
  }

  static String getHallImagePath(String hallId, String imageName) {
    return '$hallImagesPath/$hallId/$imageName';
  }

  static String getUserAvatarPath(String userId, String imageName) {
    return '$userAvatarsPath/$userId/$imageName';
  }

  static String getBusinessDocumentPath(String ownerId, String documentName) {
    return '$businessDocumentsPath/$ownerId/$documentName';
  }

  static bool isValidUserType(String userType) {
    return [customerUserType, hallOwnerUserType, adminUserType].contains(userType);
  }

  static bool isValidAuthProvider(String provider) {
    return [googleAuthProvider, appleAuthProvider].contains(provider);
  }

  static bool isValidBookingStatus(String status) {
    return [
      pendingBookingStatus,
      confirmedBookingStatus,
      paymentPendingBookingStatus,
      completedBookingStatus,
      cancelledBookingStatus
    ].contains(status);
  }

  static bool isValidPaymentStatus(String status) {
    return [
      pendingPaymentStatus,
      firstPaidPaymentStatus,
      fullyPaidPaymentStatus,
      failedPaymentStatus,
      refundedPaymentStatus
    ].contains(status);
  }

  static bool isValidAdminRole(String role) {
    return [
      superAdminRole,
      contentModeratorRole,
      supportRole,
      financeRole
    ].contains(role);
  }
}
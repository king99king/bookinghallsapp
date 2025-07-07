// models/user/user_model.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../core/extensions/string_extension.dart';

/// Comprehensive user model supporting all user types
class UserModel {
  final String userId;
  final AuthProvider authProvider;
  final String providerUserId;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? firstNameArabic;
  final String? lastNameArabic;
  final UserType userType;
  final String? governorate;
  final String? wilayat;
  final bool isActive;
  final bool isVerified;
  final bool isProfileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final String preferredLanguage;
  final List<String> fcmTokens;
  final NotificationSettings notificationSettings;

  UserModel({
    required this.userId,
    required this.authProvider,
    required this.providerUserId,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.firstNameArabic,
    this.lastNameArabic,
    required this.userType,
    this.governorate,
    this.wilayat,
    this.isActive = true,
    this.isVerified = true,
    this.isProfileCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastLoginAt,
    this.preferredLanguage = AppConstants.defaultLanguage,
    this.fcmTokens = const [],
    NotificationSettings? notificationSettings,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        notificationSettings = notificationSettings ?? NotificationSettings.defaultSettings();

  // ========== Factory Constructors ==========

  /// Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        userId: json[FirebaseConstants.userIdField] as String,
        authProvider: AuthProvider.fromString(json[FirebaseConstants.authProviderField] as String),
        providerUserId: json[FirebaseConstants.providerUserIdField] as String,
        email: json[FirebaseConstants.emailField] as String? ?? '',
        displayName: json[FirebaseConstants.displayNameField] as String? ?? '',
        profileImageUrl: json[FirebaseConstants.profileImageUrlField] as String?,
        phoneNumber: json[FirebaseConstants.phoneNumberField] as String?,
        firstName: json[FirebaseConstants.firstNameField] as String?,
        lastName: json[FirebaseConstants.lastNameField] as String?,
        firstNameArabic: json[FirebaseConstants.firstNameArabicField] as String?,
        lastNameArabic: json[FirebaseConstants.lastNameArabicField] as String?,
        userType: UserType.fromString(json[FirebaseConstants.userTypeField] as String? ?? 'customer'),
        governorate: json[FirebaseConstants.governorateField] as String?,
        wilayat: json[FirebaseConstants.wilayatField] as String?,
        isActive: json[FirebaseConstants.isActiveField] as bool? ?? true,
        isVerified: json[FirebaseConstants.isVerifiedField] as bool? ?? false,
        isProfileCompleted: json[FirebaseConstants.isProfileCompletedField] as bool? ?? false,
        createdAt: DateUtils.parseISODate(json[FirebaseConstants.createdAtField] as String?) ?? DateTime.now(),
        updatedAt: DateUtils.parseISODate(json[FirebaseConstants.updatedAtField] as String?) ?? DateTime.now(),
        lastLoginAt: DateUtils.parseISODate(json[FirebaseConstants.lastLoginAtField] as String?),
        preferredLanguage: json[FirebaseConstants.preferredLanguageField] as String? ?? AppConstants.defaultLanguage,
        fcmTokens: List<String>.from(json[FirebaseConstants.fcmTokensField] as List<dynamic>? ?? []),
        notificationSettings: NotificationSettings.fromJson(
            json[FirebaseConstants.notificationSettingsField] as Map<String, dynamic>? ?? {}
        ),
      );
    } catch (e) {
      debugPrint('Error parsing UserModel from JSON: $e');
      rethrow;
    }
  }

  /// Create new user for registration
  factory UserModel.createNew({
    required String providerUserId,
    required AuthProvider authProvider,
    required String email,
    required String displayName,
    String? profileImageUrl,
  }) {
    return UserModel(
      userId: '', // Will be set by auth service
      authProvider: authProvider,
      providerUserId: providerUserId,
      email: email,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      userType: UserType.customer, // Default to customer
      preferredLanguage: AppConstants.defaultLanguage,
    );
  }

  // ========== JSON Conversion ==========

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.userIdField: userId,
      FirebaseConstants.authProviderField: authProvider.value,
      FirebaseConstants.providerUserIdField: providerUserId,
      FirebaseConstants.emailField: email,
      FirebaseConstants.displayNameField: displayName,
      FirebaseConstants.profileImageUrlField: profileImageUrl,
      FirebaseConstants.phoneNumberField: phoneNumber,
      FirebaseConstants.firstNameField: firstName,
      FirebaseConstants.lastNameField: lastName,
      FirebaseConstants.firstNameArabicField: firstNameArabic,
      FirebaseConstants.lastNameArabicField: lastNameArabic,
      FirebaseConstants.userTypeField: userType.value,
      FirebaseConstants.governorateField: governorate,
      FirebaseConstants.wilayatField: wilayat,
      FirebaseConstants.isActiveField: isActive,
      FirebaseConstants.isVerifiedField: isVerified,
      FirebaseConstants.isProfileCompletedField: isProfileCompleted,
      FirebaseConstants.createdAtField: DateUtils.toISOString(createdAt),
      FirebaseConstants.updatedAtField: DateUtils.toISOString(updatedAt),
      FirebaseConstants.lastLoginAtField: lastLoginAt != null ? DateUtils.toISOString(lastLoginAt!) : null,
      FirebaseConstants.preferredLanguageField: preferredLanguage,
      FirebaseConstants.fcmTokensField: fcmTokens,
      FirebaseConstants.notificationSettingsField: notificationSettings.toJson(),
    };
  }

  // ========== Validation ==========

  /// Validate user data
  List<String> validate() {
    final errors = <String>[];

    // Validate user ID
    if (userId.isNotEmpty && !IdGenerator.isValidUserId(userId)) {
      errors.add('Invalid user ID format');
    }

    // Validate email
    final emailValidation = Validators.validateEmail(email);
    if (emailValidation != null) {
      errors.add(emailValidation);
    }

    // Validate phone number if provided
    if (phoneNumber != null) {
      final phoneValidation = Validators.validatePhoneNumber(phoneNumber);
      if (phoneValidation != null) {
        errors.add(phoneValidation);
      }
    }

    // Validate names if provided
    if (firstName != null) {
      final firstNameValidation = Validators.validateName(firstName, fieldName: 'First name');
      if (firstNameValidation != null) {
        errors.add(firstNameValidation);
      }
    }

    if (lastName != null) {
      final lastNameValidation = Validators.validateName(lastName, fieldName: 'Last name');
      if (lastNameValidation != null) {
        errors.add(lastNameValidation);
      }
    }

    // Validate Arabic names if provided
    if (firstNameArabic != null && firstNameArabic!.isNotEmpty) {
      final arabicFirstNameValidation = Validators.validateArabicName(firstNameArabic, fieldName: 'Arabic first name');
      if (arabicFirstNameValidation != null) {
        errors.add(arabicFirstNameValidation);
      }
    }

    if (lastNameArabic != null && lastNameArabic!.isNotEmpty) {
      final arabicLastNameValidation = Validators.validateArabicName(lastNameArabic, fieldName: 'Arabic last name');
      if (arabicLastNameValidation != null) {
        errors.add(arabicLastNameValidation);
      }
    }

    // Validate location if provided
    if (governorate != null) {
      final governorateValidation = Validators.validateGovernorate(governorate);
      if (governorateValidation != null) {
        errors.add(governorateValidation);
      }
    }

    if (wilayat != null && governorate != null) {
      final wilayatValidation = Validators.validateWilayat(wilayat, governorate);
      if (wilayatValidation != null) {
        errors.add(wilayatValidation);
      }
    }

    return errors;
  }

  /// Check if user data is valid
  bool get isValid => validate().isEmpty;

  // ========== Computed Properties ==========

  /// Get full name in preferred language
  String get fullName {
    if (preferredLanguage == 'ar' && hasArabicName) {
      return '${firstNameArabic ?? firstName ?? ''} ${lastNameArabic ?? lastName ?? ''}'.trim();
    }
    return '${firstName ?? ''} ${lastName ?? ''}'.trim().orDefault(displayName);
  }

  /// Get initials for avatar
  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts[0].substring(0, 1).toUpperCase();
      }
    }
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }

  /// Check if user has Arabic name
  bool get hasArabicName =>
      (firstNameArabic != null && firstNameArabic!.isNotEmpty) ||
          (lastNameArabic != null && lastNameArabic!.isNotEmpty);

  /// Check if user is using Arabic language
  bool get isArabicUser => preferredLanguage == 'ar';

  /// Get formatted phone number
  String? get formattedPhoneNumber {
    return phoneNumber != null ? Validators.formatPhoneNumber(phoneNumber!) : null;
  }

  /// Get masked email for privacy
  String get maskedEmail => email.maskSensitive;

  /// Get user location display name
  String? get locationDisplayName {
    if (wilayat != null && governorate != null) {
      if (isArabicUser) {
        final wilayatAr = AppConstants.wilayatsByGovernorateArabic[governorate]?.firstWhere(
              (w) => w == wilayat,
          orElse: () => wilayat!,
        );
        final governorateAr = governorate!.governorateInArabic;
        return '$wilayatAr، $governorateAr';
      } else {
        return '$wilayat, $governorate';
      }
    } else if (governorate != null) {
      return isArabicUser ? governorate!.governorateInArabic : governorate;
    }
    return null;
  }

  /// Get time since last login
  String? getTimeSinceLastLogin(String? languageCode) {
    if (lastLoginAt == null) return null;
    return DateUtils.formatTimeDifference(lastLoginAt!, languageCode: languageCode);
  }

  /// Get account age
  String getAccountAge(String? languageCode) {
    return DateUtils.formatTimeDifference(createdAt, languageCode: languageCode);
  }

  /// Check if user was recently active (within 30 days)
  bool get isRecentlyActive {
    if (lastLoginAt == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastLoginAt!.isAfter(thirtyDaysAgo);
  }

  /// Check if user needs profile completion
  bool get needsProfileCompletion =>
      !isProfileCompleted ||
          phoneNumber == null ||
          firstName == null ||
          lastName == null ||
          governorate == null ||
          wilayat == null;

  /// Get completion percentage
  double get profileCompletionPercentage {
    int totalFields = 7; // phone, firstName, lastName, governorate, wilayat, profileImage, arabicNames
    int completedFields = 0;

    if (phoneNumber != null) completedFields++;
    if (firstName != null) completedFields++;
    if (lastName != null) completedFields++;
    if (governorate != null) completedFields++;
    if (wilayat != null) completedFields++;
    if (profileImageUrl != null) completedFields++;
    if (hasArabicName) completedFields++;

    return completedFields / totalFields;
  }

  // ========== User Type Checks ==========

  /// Check if user is customer
  bool get isCustomer => userType == UserType.customer;

  /// Check if user is hall owner
  bool get isHallOwner => userType == UserType.hallOwner;

  /// Check if user is admin
  bool get isAdmin => userType == UserType.admin;

  /// Get user type display name
  String getUserTypeDisplayName(String? languageCode) {
    final isArabic = languageCode == 'ar';
    switch (userType) {
      case UserType.customer:
        return isArabic ? 'عميل' : 'Customer';
      case UserType.hallOwner:
        return isArabic ? 'مالك قاعة' : 'Hall Owner';
      case UserType.admin:
        return isArabic ? 'مدير' : 'Admin';
    }
  }

  // ========== FCM Token Management ==========

  /// Add FCM token
  UserModel addFCMToken(String token) {
    if (fcmTokens.contains(token)) return this;
    final updatedTokens = List<String>.from(fcmTokens)..add(token);
    return copyWith(fcmTokens: updatedTokens);
  }

  /// Remove FCM token
  UserModel removeFCMToken(String token) {
    final updatedTokens = List<String>.from(fcmTokens)..remove(token);
    return copyWith(fcmTokens: updatedTokens);
  }

  /// Clear all FCM tokens
  UserModel clearFCMTokens() {
    return copyWith(fcmTokens: []);
  }

  // ========== Update Methods ==========

  /// Update profile information
  UserModel updateProfile({
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? firstNameArabic,
    String? lastNameArabic,
    String? governorate,
    String? wilayat,
    String? profileImageUrl,
  }) {
    return copyWith(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      firstNameArabic: firstNameArabic ?? this.firstNameArabic,
      lastNameArabic: lastNameArabic ?? this.lastNameArabic,
      governorate: governorate ?? this.governorate,
      wilayat: wilayat ?? this.wilayat,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isProfileCompleted: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Update preferences
  UserModel updatePreferences({
    String? preferredLanguage,
    NotificationSettings? notificationSettings,
  }) {
    return copyWith(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      updatedAt: DateTime.now(),
    );
  }

  /// Update last login time
  UserModel updateLastLogin() {
    return copyWith(
      lastLoginAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Deactivate user
  UserModel deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Reactivate user
  UserModel reactivate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  // ========== Copy With ==========

  UserModel copyWith({
    String? userId,
    AuthProvider? authProvider,
    String? providerUserId,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? firstNameArabic,
    String? lastNameArabic,
    UserType? userType,
    String? governorate,
    String? wilayat,
    bool? isActive,
    bool? isVerified,
    bool? isProfileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? preferredLanguage,
    List<String>? fcmTokens,
    NotificationSettings? notificationSettings,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      authProvider: authProvider ?? this.authProvider,
      providerUserId: providerUserId ?? this.providerUserId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      firstNameArabic: firstNameArabic ?? this.firstNameArabic,
      lastNameArabic: lastNameArabic ?? this.lastNameArabic,
      userType: userType ?? this.userType,
      governorate: governorate ?? this.governorate,
      wilayat: wilayat ?? this.wilayat,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  // ========== Equality & Hash ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, userType: ${userType.value}, isActive: $isActive)';
  }
}

// ========== Enums ==========

/// Authentication provider enum
enum AuthProvider {
  google('google'),
  apple('apple');

  const AuthProvider(this.value);
  final String value;

  static AuthProvider fromString(String value) {
    return AuthProvider.values.firstWhere(
          (provider) => provider.value == value,
      orElse: () => AuthProvider.google,
    );
  }
}

/// User type enum
enum UserType {
  customer('customer'),
  hallOwner('hall_owner'),
  admin('admin');

  const UserType(this.value);
  final String value;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => UserType.customer,
    );
  }
}

// ========== Notification Settings ==========

/// Notification preferences model
class NotificationSettings {
  final bool bookingUpdates;
  final bool paymentReminders;
  final bool promotions;
  final bool systemNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  NotificationSettings({
    this.bookingUpdates = true,
    this.paymentReminders = true,
    this.promotions = false,
    this.systemNotifications = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings();
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      bookingUpdates: json['bookingUpdates'] as bool? ?? true,
      paymentReminders: json['paymentReminders'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      systemNotifications: json['systemNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingUpdates': bookingUpdates,
      'paymentReminders': paymentReminders,
      'promotions': promotions,
      'systemNotifications': systemNotifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  NotificationSettings copyWith({
    bool? bookingUpdates,
    bool? paymentReminders,
    bool? promotions,
    bool? systemNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationSettings(
      bookingUpdates: bookingUpdates ?? this.bookingUpdates,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      promotions: promotions ?? this.promotions,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.bookingUpdates == bookingUpdates &&
        other.paymentReminders == paymentReminders &&
        other.promotions == promotions &&
        other.systemNotifications == systemNotifications &&
        other.emailNotifications == emailNotifications &&
        other.pushNotifications == pushNotifications;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookingUpdates,
      paymentReminders,
      promotions,
      systemNotifications,
      emailNotifications,
      pushNotifications,
    );
  }
}
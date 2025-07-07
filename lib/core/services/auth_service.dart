// core/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';

import '../constants/firebase_constants.dart';
import '../constants/app_constants.dart';
import '../utils/id_generator.dart';
import '../utils/validators.dart';
import 'firebase_service.dart';

/// Comprehensive authentication service for Google & Apple Sign-In
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Firebase Service for user data management
  final FirebaseService _firebaseService = FirebaseService();

  // Current user cache
  Map<String, dynamic>? _currentUserData;

  // Authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current Firebase user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // ========== Authentication Methods ==========

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.cancelled('Google sign-in cancelled by user');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to authenticate with Firebase');
      }

      // Process user data and check profile completion
      final authResult = await _processAuthenticatedUser(
        userCredential.user!,
        FirebaseConstants.googleAuthProvider,
        googleUser.id,
      );

      debugPrint('Google sign-in successful: ${userCredential.user!.uid}');
      return authResult;

    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return AuthResult.failure('Google sign-in failed: ${_getErrorMessage(e)}');
    }
  }

  /// Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with Apple credential
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to authenticate with Firebase');
      }

      // Process user data and check profile completion
      final authResult = await _processAuthenticatedUser(
        userCredential.user!,
        FirebaseConstants.appleAuthProvider,
        appleCredential.userIdentifier ?? userCredential.user!.uid,
        appleCredential: appleCredential,
      );

      debugPrint('Apple sign-in successful: ${userCredential.user!.uid}');
      return authResult;

    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      return AuthResult.failure('Apple sign-in failed: ${_getErrorMessage(e)}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Clear cached user data
      _currentUserData = null;

      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Note: Apple doesn't require explicit sign-out

      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw AuthException('Failed to sign out: ${_getErrorMessage(e)}');
    }
  }

  // ========== User Profile Management ==========

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData({bool forceRefresh = false}) async {
    try {
      if (!isSignedIn) return null;

      // Return cached data if available and not forcing refresh
      if (_currentUserData != null && !forceRefresh) {
        return _currentUserData;
      }

      // Fetch from Firestore
      final userData = await _firebaseService.getUser(currentUser!.uid);

      if (userData != null) {
        _currentUserData = userData;
        return userData;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting current user data: $e');
      return null;
    }
  }

  /// Update current user data
  Future<void> updateCurrentUserData(Map<String, dynamic> userData) async {
    try {
      if (!isSignedIn) {
        throw AuthException('User not signed in');
      }

      await _firebaseService.updateUser(currentUser!.uid, userData);

      // Update cache
      if (_currentUserData != null) {
        _currentUserData!.addAll(userData);
      }

      debugPrint('User data updated successfully');
    } catch (e) {
      debugPrint('Error updating user data: $e');
      throw AuthException('Failed to update user data: ${_getErrorMessage(e)}');
    }
  }

  /// Complete user profile after initial sign-in
  Future<AuthResult> completeProfile({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? firstNameArabic,
    String? lastNameArabic,
    required String governorate,
    required String wilayat,
    required String userType,
    required String preferredLanguage,
  }) async {
    try {
      if (!isSignedIn) {
        return AuthResult.failure('User not signed in');
      }

      // Validate input data
      final validationErrors = _validateProfileData(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        governorate: governorate,
        wilayat: wilayat,
        userType: userType,
      );

      if (validationErrors.isNotEmpty) {
        return AuthResult.failure('Validation errors: ${validationErrors.join(', ')}');
      }

      // Prepare update data
      final updateData = {
        FirebaseConstants.phoneNumberField: phoneNumber,
        FirebaseConstants.firstNameField: firstName,
        FirebaseConstants.lastNameField: lastName,
        FirebaseConstants.governorateField: governorate,
        FirebaseConstants.wilayatField: wilayat,
        FirebaseConstants.userTypeField: userType,
        FirebaseConstants.preferredLanguageField: preferredLanguage,
        FirebaseConstants.isProfileCompletedField: true,
      };

      // Add Arabic names if provided
      if (firstNameArabic != null && firstNameArabic.isNotEmpty) {
        updateData[FirebaseConstants.firstNameArabicField] = firstNameArabic;
      }
      if (lastNameArabic != null && lastNameArabic.isNotEmpty) {
        updateData[FirebaseConstants.lastNameArabicField] = lastNameArabic;
      }

      // Update user profile
      await updateCurrentUserData(updateData);

      // Handle user type specific actions
      if (userType == FirebaseConstants.hallOwnerUserType) {
        await _createHallOwnerProfile();
      }

      debugPrint('Profile completed successfully for user type: $userType');

      return AuthResult.success(
        message: 'Profile completed successfully',
        userType: userType,
        isProfileCompleted: true,
      );

    } catch (e) {
      debugPrint('Error completing profile: $e');
      return AuthResult.failure('Failed to complete profile: ${_getErrorMessage(e)}');
    }
  }

  // ========== User Type Management ==========

  /// Get user type
  Future<String?> getUserType() async {
    final userData = await getCurrentUserData();
    return userData?[FirebaseConstants.userTypeField] as String?;
  }

  /// Check if user profile is completed
  Future<bool> isProfileCompleted() async {
    final userData = await getCurrentUserData();
    return userData?[FirebaseConstants.isProfileCompletedField] as bool? ?? false;
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == FirebaseConstants.adminUserType;
  }

  /// Check if user is hall owner
  Future<bool> isHallOwner() async {
    final userType = await getUserType();
    return userType == FirebaseConstants.hallOwnerUserType;
  }

  /// Check if user is customer
  Future<bool> isCustomer() async {
    final userType = await getUserType();
    return userType == FirebaseConstants.customerUserType;
  }

  /// Get user permissions (for admin users)
  Future<List<String>> getUserPermissions() async {
    try {
      if (!await isAdmin()) return [];

      final adminData = await _firebaseService.query(
        collection: FirebaseConstants.adminUsersCollection,
        filters: [
          QueryFilter.equal(FirebaseConstants.userIdField, currentUser!.uid),
          QueryFilter.equal(FirebaseConstants.isActiveField, true),
        ],
        limit: 1,
      );

      if (adminData.isNotEmpty) {
        return List<String>.from(adminData.first[FirebaseConstants.permissionsField] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('Error getting user permissions: $e');
      return [];
    }
  }

  /// Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    final permissions = await getUserPermissions();
    return permissions.contains(permission);
  }

  // ========== Account Management ==========

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      if (!isSignedIn) {
        throw AuthException('User not signed in');
      }

      final userId = currentUser!.uid;

      // Delete user data from Firestore
      await _firebaseService.delete(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );

      // Delete additional user type specific data
      final userType = await getUserType();
      if (userType == FirebaseConstants.hallOwnerUserType) {
        await _deleteHallOwnerData(userId);
      } else if (userType == FirebaseConstants.adminUserType) {
        await _deleteAdminData(userId);
      }

      // Delete Firebase Auth account
      await currentUser!.delete();

      // Clear cache
      _currentUserData = null;

      debugPrint('Account deleted successfully');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      throw AuthException('Failed to delete account: ${_getErrorMessage(e)}');
    }
  }

  /// Update email (requires re-authentication)
  Future<void> updateEmail(String newEmail) async {
    try {
      if (!isSignedIn) {
        throw AuthException('User not signed in');
      }

      // Validate email
      final emailValidation = Validators.validateEmail(newEmail);
      if (emailValidation != null) {
        throw AuthException(emailValidation);
      }

      // Update Firebase Auth email
      await currentUser!.updateEmail(newEmail);

      // Update Firestore data
      await updateCurrentUserData({
        FirebaseConstants.emailField: newEmail,
      });

      debugPrint('Email updated successfully');
    } catch (e) {
      debugPrint('Error updating email: $e');
      throw AuthException('Failed to update email: ${_getErrorMessage(e)}');
    }
  }

  // ========== Token Management ==========

  /// Get current user ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      if (!isSignedIn) return null;
      return await currentUser!.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  /// Refresh ID token
  Future<void> refreshToken() async {
    try {
      if (!isSignedIn) return;
      await currentUser!.getIdToken(true);
      debugPrint('Token refreshed successfully');
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
  }

  // ========== FCM Token Management ==========

  /// Add FCM token for notifications
  Future<void> addFCMToken(String fcmToken) async {
    try {
      if (!isSignedIn) return;

      final userData = await getCurrentUserData();
      final currentTokens = List<String>.from(userData?[FirebaseConstants.fcmTokensField] ?? []);

      if (!currentTokens.contains(fcmToken)) {
        currentTokens.add(fcmToken);
        await updateCurrentUserData({
          FirebaseConstants.fcmTokensField: currentTokens,
        });
        debugPrint('FCM token added successfully');
      }
    } catch (e) {
      debugPrint('Error adding FCM token: $e');
    }
  }

  /// Remove FCM token
  Future<void> removeFCMToken(String fcmToken) async {
    try {
      if (!isSignedIn) return;

      final userData = await getCurrentUserData();
      final currentTokens = List<String>.from(userData?[FirebaseConstants.fcmTokensField] ?? []);

      if (currentTokens.remove(fcmToken)) {
        await updateCurrentUserData({
          FirebaseConstants.fcmTokensField: currentTokens,
        });
        debugPrint('FCM token removed successfully');
      }
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  // ========== Private Helper Methods ==========

  /// Process authenticated user after sign-in
  Future<AuthResult> _processAuthenticatedUser(
      User firebaseUser,
      String authProvider,
      String providerUserId, {
        AuthorizationCredentialAppleID? appleCredential,
      }) async {
    try {
      // Check if user exists in Firestore
      final existingUser = await _firebaseService.getUser(firebaseUser.uid);

      if (existingUser != null) {
        // Existing user - update last login
        await _firebaseService.updateUser(firebaseUser.uid, {
          FirebaseConstants.lastLoginAtField: FieldValue.serverTimestamp(),
        });

        _currentUserData = existingUser;

        final isProfileCompleted = existingUser[FirebaseConstants.isProfileCompletedField] as bool? ?? false;
        final userType = existingUser[FirebaseConstants.userTypeField] as String?;

        return AuthResult.success(
          message: 'Welcome back!',
          userType: userType,
          isProfileCompleted: isProfileCompleted,
        );
      } else {
        // New user - create profile
        final userId = await _createUserProfile(
          firebaseUser,
          authProvider,
          providerUserId,
          appleCredential: appleCredential,
        );

        return AuthResult.success(
          message: 'Account created successfully',
          userType: null, // Will be set during profile completion
          isProfileCompleted: false,
        );
      }
    } catch (e) {
      debugPrint('Error processing authenticated user: $e');
      return AuthResult.failure('Failed to process user data: ${_getErrorMessage(e)}');
    }
  }

  /// Create new user profile
  Future<String> _createUserProfile(
      User firebaseUser,
      String authProvider,
      String providerUserId, {
        AuthorizationCredentialAppleID? appleCredential,
      }) async {
    try {
      // Prepare user data
      final userData = {
        FirebaseConstants.userIdField: firebaseUser.uid,
        FirebaseConstants.authProviderField: authProvider,
        FirebaseConstants.providerUserIdField: providerUserId,
        FirebaseConstants.emailField: firebaseUser.email ?? '',
        FirebaseConstants.displayNameField: firebaseUser.displayName ?? '',
        FirebaseConstants.profileImageUrlField: firebaseUser.photoURL,
        FirebaseConstants.isActiveField: true,
        FirebaseConstants.isVerifiedField: true, // Google/Apple verified
        FirebaseConstants.isProfileCompletedField: false,
        FirebaseConstants.preferredLanguageField: AppConstants.defaultLanguage,
        FirebaseConstants.fcmTokensField: [],
        FirebaseConstants.lastLoginAtField: FieldValue.serverTimestamp(),
        FirebaseConstants.notificationSettingsField: {
          'bookingUpdates': true,
          'paymentReminders': true,
          'promotions': false,
        },
      };

      // Handle Apple-specific data
      if (appleCredential != null) {
        final fullName = appleCredential.givenName != null && appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : firebaseUser.displayName ?? '';
        userData[FirebaseConstants.displayNameField] = fullName;
      }

      // Create user in Firestore
      await _firebaseService.createUser(userData);

      _currentUserData = userData;

      debugPrint('New user profile created: ${firebaseUser.uid}');
      return firebaseUser.uid;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      throw AuthException('Failed to create user profile: ${_getErrorMessage(e)}');
    }
  }

  /// Create hall owner profile
  Future<void> _createHallOwnerProfile() async {
    try {
      if (!isSignedIn) return;

      final ownerId = await IdGenerator.generateOwnerId();
      final ownerData = {
        FirebaseConstants.ownerIdField: ownerId,
        FirebaseConstants.userIdField: currentUser!.uid,
        FirebaseConstants.isApprovedField: false, // Requires admin approval
        FirebaseConstants.isActiveField: true,
        FirebaseConstants.totalEarningsField: 0.0,
        FirebaseConstants.totalBookingsField: 0,
        FirebaseConstants.ratingField: 0.0,
        FirebaseConstants.commissionSettingsField: {
          'customerCommissionPercent': AppConstants.defaultCustomerCommissionPercent,
          'ownerCommissionPercent': AppConstants.defaultOwnerCommissionPercent,
        },
      };

      await _firebaseService.create(
        collection: FirebaseConstants.hallOwnersCollection,
        documentId: ownerId,
        data: ownerData,
      );

      debugPrint('Hall owner profile created: $ownerId');
    } catch (e) {
      debugPrint('Error creating hall owner profile: $e');
    }
  }

  /// Delete hall owner data
  Future<void> _deleteHallOwnerData(String userId) async {
    try {
      // Find hall owner record
      final ownerData = await _firebaseService.query(
        collection: FirebaseConstants.hallOwnersCollection,
        filters: [QueryFilter.equal(FirebaseConstants.userIdField, userId)],
        limit: 1,
      );

      if (ownerData.isNotEmpty) {
        final ownerId = ownerData.first[FirebaseConstants.ownerIdField];
        await _firebaseService.delete(
          collection: FirebaseConstants.hallOwnersCollection,
          documentId: ownerId,
        );
      }
    } catch (e) {
      debugPrint('Error deleting hall owner data: $e');
    }
  }

  /// Delete admin data
  Future<void> _deleteAdminData(String userId) async {
    try {
      // Find admin record
      final adminData = await _firebaseService.query(
        collection: FirebaseConstants.adminUsersCollection,
        filters: [QueryFilter.equal(FirebaseConstants.userIdField, userId)],
        limit: 1,
      );

      if (adminData.isNotEmpty) {
        final adminId = adminData.first[FirebaseConstants.adminIdField];
        await _firebaseService.delete(
          collection: FirebaseConstants.adminUsersCollection,
          documentId: adminId,
        );
      }
    } catch (e) {
      debugPrint('Error deleting admin data: $e');
    }
  }

  /// Validate profile completion data
  List<String> _validateProfileData({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String governorate,
    required String wilayat,
    required String userType,
  }) {
    final errors = <String>[];

    final phoneValidation = Validators.validatePhoneNumber(phoneNumber);
    if (phoneValidation != null) errors.add(phoneValidation);

    final firstNameValidation = Validators.validateName(firstName, fieldName: 'First name');
    if (firstNameValidation != null) errors.add(firstNameValidation);

    final lastNameValidation = Validators.validateName(lastName, fieldName: 'Last name');
    if (lastNameValidation != null) errors.add(lastNameValidation);

    final governorateValidation = Validators.validateGovernorate(governorate);
    if (governorateValidation != null) errors.add(governorateValidation);

    final wilayatValidation = Validators.validateWilayat(wilayat, governorate);
    if (wilayatValidation != null) errors.add(wilayatValidation);

    final userTypeValidation = Validators.validateUserType(userType);
    if (userTypeValidation != null) errors.add(userTypeValidation);

    return errors;
  }

  /// Generate random nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Generate SHA256 hash of nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-disabled':
          return 'This account has been disabled';
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Invalid password';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        case 'requires-recent-login':
          return 'Please sign in again to continue';
        case 'network-request-failed':
          return 'Network error. Please check your connection';
        default:
          return error.message ?? 'Authentication failed';
      }
    }
    return error.toString();
  }
}

// ========== Result Classes ==========

/// Authentication result
class AuthResult {
  final bool success;
  final String message;
  final String? userType;
  final bool? isProfileCompleted;

  AuthResult._({
    required this.success,
    required this.message,
    this.userType,
    this.isProfileCompleted,
  });

  factory AuthResult.success({
    required String message,
    String? userType,
    bool? isProfileCompleted,
  }) {
    return AuthResult._(
      success: true,
      message: message,
      userType: userType,
      isProfileCompleted: isProfileCompleted,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }

  factory AuthResult.cancelled(String message) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
}

/// Authentication exception
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
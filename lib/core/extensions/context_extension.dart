// core/extensions/context_extension.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../constants/route_constants.dart';

/// Comprehensive context extensions for easier UI development
extension ContextExtension on BuildContext {

  // ========== Theme Access ==========

  /// Get current theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  // ========== Common Colors ==========

  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;
  Color get backgroundColor => colorScheme.surface;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get onBackgroundColor => colorScheme.onSurface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get onErrorColor => colorScheme.onError;

  // Additional semantic colors
  Color get successColor => Colors.green;
  Color get warningColor => Colors.orange;
  Color get infoColor => Colors.blue;
  Color get disabledColor => colorScheme.onSurface.withOpacity(0.38);
  Color get dividerColor => colorScheme.onSurface.withOpacity(0.12);
  Color get cardColor => theme.cardColor;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  // ========== Text Styles ==========

  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get displaySmall => textTheme.displaySmall;
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;
  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;

  // Custom text styles
  TextStyle? get priceTextStyle => titleLarge?.copyWith(
    color: primaryColor,
    fontWeight: FontWeight.bold,
  );

  TextStyle? get discountTextStyle => bodyMedium?.copyWith(
    color: successColor,
    fontWeight: FontWeight.w600,
  );

  TextStyle? get errorTextStyle => bodySmall?.copyWith(
    color: errorColor,
  );

  TextStyle? get captionTextStyle => bodySmall?.copyWith(
    color: onSurfaceColor.withOpacity(0.6),
  );

  // ========== Screen Dimensions ==========

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Get view insets (keyboard)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get status bar height
  double get statusBarHeight => safeAreaPadding.top;

  /// Get bottom safe area height
  double get bottomSafeArea => safeAreaPadding.bottom;

  // ========== Device Type Checks ==========

  /// Check if device is mobile (width < 600)
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet (width >= 600 && width < 1200)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Check if device is desktop (width >= 1200)
  bool get isDesktop => screenWidth >= 1200;

  /// Check if device is in landscape mode
  bool get isLandscape => screenWidth > screenHeight;

  /// Check if device is in portrait mode
  bool get isPortrait => screenHeight > screenWidth;

  // ========== Common Dimensions ==========

  /// Small spacing (8px)
  double get spacingSmall => 8.0;

  /// Medium spacing (16px)
  double get spacingMedium => 16.0;

  /// Large spacing (24px)
  double get spacingLarge => 24.0;

  /// Extra large spacing (32px)
  double get spacingXLarge => 32.0;

  /// Border radius small (4px)
  double get radiusSmall => 4.0;

  /// Border radius medium (8px)
  double get radiusMedium => 8.0;

  /// Border radius large (12px)
  double get radiusLarge => 12.0;

  /// Border radius extra large (16px)
  double get radiusXLarge => 16.0;

  /// Default border radius for cards
  BorderRadius get cardBorderRadius => BorderRadius.circular(radiusMedium);

  /// Default border radius for buttons
  BorderRadius get buttonBorderRadius => BorderRadius.circular(radiusLarge);

  /// Default padding for screens
  EdgeInsets get screenPadding => EdgeInsets.all(spacingMedium);

  /// Default padding for cards
  EdgeInsets get cardPadding => EdgeInsets.all(spacingMedium);

  /// Default padding for buttons
  EdgeInsets get buttonPadding => EdgeInsets.symmetric(
    horizontal: spacingLarge,
    vertical: spacingMedium,
  );

  // ========== Localization ==========

  /// Get current locale
  Locale get locale => Localizations.localeOf(this);

  /// Check if current language is Arabic
  bool get isArabic => locale.languageCode == 'ar';

  /// Check if current language is English
  bool get isEnglish => locale.languageCode == 'en';

  /// Get current language code
  String get languageCode => locale.languageCode;

  /// Get text direction based on locale
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// Get localized app name
  String get appName => isArabic ? AppConstants.appNameArabic : AppConstants.appName;

  /// Get localized currency symbol
  String get currencySymbol => AppConstants.currencySymbol;

  // Helper method to get localized text (you can integrate with your localization package)
  String translate(String key, {Map<String, dynamic>? params}) {
    // This should integrate with your localization package (e.g., flutter_localizations, easy_localization)
    // For now, returning the key as placeholder
    return key; // Replace with actual localization implementation
  }

  // Short alias for translate
  String tr(String key, {Map<String, dynamic>? params}) => translate(key, params: params);

  // ========== Navigation ==========

  /// Get navigator
  NavigatorState get navigator => Navigator.of(this);

  /// Push named route
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push replacement named route
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName, {
        Object? arguments,
        TO? result,
      }) {
    return navigator.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Push named and clear stack
  Future<T?> pushNamedAndClearStack<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator.pushNamedAndRemoveUntil<T>(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  void pop<T extends Object?>([T? result]) {
    return navigator.pop<T>(result);
  }

  /// Pop until route
  void popUntil(String routeName) {
    return navigator.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  bool get canPop => navigator.canPop();

  // ========== Common Navigation Actions ==========

  /// Go to home based on user type
  Future<void> goToHome(String userType) {
    final route = RouteConstants.getHomeRoute(userType);
    return pushNamedAndClearStack(route);
  }

  /// Go to login
  Future<void> goToLogin() {
    return pushNamedAndClearStack(RouteConstants.login);
  }

  /// Go to profile
  Future<void> goToProfile() {
    return pushNamed(RouteConstants.profile);
  }

  /// Go back or to fallback route
  void goBackOrTo(String fallbackRoute) {
    if (canPop) {
      pop();
    } else {
      pushReplacementNamed(fallbackRoute);
    }
  }

  // ========== Dialogs & Overlays ==========

  /// Show snackbar
  void showSnackBar(
      String message, {
        Color? backgroundColor,
        Color? textColor,
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor ?? onPrimaryColor),
      ),
      backgroundColor: backgroundColor ?? primaryColor,
      duration: duration,
      action: action,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: successColor,
      textColor: Colors.white,
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: errorColor,
      textColor: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  /// Show warning snackbar
  void showWarningSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: warningColor,
      textColor: Colors.white,
    );
  }

  /// Show info snackbar
  void showInfoSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: infoColor,
      textColor: Colors.white,
    );
  }

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: spacingMedium),
            Expanded(
              child: Text(
                message ?? translate('loading'),
                style: bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    if (canPop) pop();
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: Text(cancelText ?? translate('cancel')),
          ),
          TextButton(
            onPressed: () => navigator.pop(true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: errorColor)
                : null,
            child: Text(confirmText ?? translate('confirm')),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show error dialog
  Future<void> showErrorDialog({
    required String title,
    required String message,
    String? buttonText,
  }) async {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: errorColor),
            SizedBox(width: spacingSmall),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: Text(buttonText ?? translate('ok')),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  Future<void> showSuccessDialog({
    required String title,
    required String message,
    String? buttonText,
  }) async {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: successColor),
            SizedBox(width: spacingSmall),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: Text(buttonText ?? translate('ok')),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet
  Future<T?> showCustomBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radiusLarge),
        ),
      ),
      builder: (context) => Container(
        height: height,
        padding: EdgeInsets.all(spacingMedium),
        child: child,
      ),
    );
  }

  // ========== Input & Focus ==========

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Request focus for a node
  void requestFocus(FocusNode focusNode) {
    FocusScope.of(this).requestFocus(focusNode);
  }

  /// Clear focus
  void clearFocus() {
    FocusScope.of(this).unfocus();
  }

  // ========== Haptic Feedback ==========

  /// Light haptic feedback
  void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback
  void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback
  void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // ========== Responsive Helpers ==========

  /// Get responsive value based on screen size
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  EdgeInsets responsivePadding({
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsiveValue(
      mobile: mobile ?? EdgeInsets.all(spacingMedium),
      tablet: tablet ?? EdgeInsets.all(spacingLarge),
      desktop: desktop ?? EdgeInsets.all(spacingXLarge),
    );
  }

  /// Get responsive font size
  double responsiveFontSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  /// Get grid column count based on screen size
  int responsiveGridColumns({
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    return responsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // ========== Animation Helpers ==========

  /// Get animation duration based on type
  Duration animationDuration(String type) {
    switch (type.toLowerCase()) {
      case 'short':
        return AppConstants.shortAnimationDuration;
      case 'long':
        return AppConstants.longAnimationDuration;
      default:
        return AppConstants.mediumAnimationDuration;
    }
  }

  /// Create slide transition
  Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  /// Create fade transition
  Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // ========== Utility Methods ==========

  /// Format price with currency
  String formatPrice(double amount) {
    return '${AppConstants.currencySymbol} ${amount.toStringAsFixed(2)}';
  }

  /// Format price for Arabic locale
  String formatPriceArabic(double amount) {
    return '${amount.toStringAsFixed(2)} ${AppConstants.currencySymbol}';
  }

  /// Get formatted price based on locale
  String getFormattedPrice(double amount) {
    return isArabic ? formatPriceArabic(amount) : formatPrice(amount);
  }

  /// Check if route requires authentication
  bool routeRequiresAuth(String route) {
    return RouteConstants.requiresAuth(route);
  }

  /// Check if user can access route
  bool canAccessRoute(String route, String userType) {
    return RouteConstants.hasPermissionForRoute(
      route: route,
      userType: userType,
    );
  }
}
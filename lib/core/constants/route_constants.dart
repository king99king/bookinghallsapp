// core/constants/route_constants.dart

class RouteConstants {
  // Root Routes
  static const String root = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Authentication Routes
  static const String login = '/login';
  static const String languageSelection = '/language-selection';
  static const String profileCompletion = '/profile-completion';
  static const String userTypeSelection = '/user-type-selection';
  static const String pendingApproval = '/pending-approval';

  // Common Routes (Shared across user types)
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String contactSupport = '/contact-support';

  // Customer Routes
  static const String customerHome = '/customer/home';
  static const String customerDashboard = '/customer/dashboard';
  static const String hallSearch = '/customer/search';
  static const String hallDetails = '/customer/hall-details';
  static const String hallGallery = '/customer/hall-gallery';
  static const String hallReviews = '/customer/hall-reviews';
  static const String booking = '/customer/booking';
  static const String bookingConfirmation = '/customer/booking-confirmation';
  static const String payment = '/customer/payment';
  static const String paymentSuccess = '/customer/payment-success';
  static const String paymentFailed = '/customer/payment-failed';
  static const String myBookings = '/customer/my-bookings';
  static const String bookingDetails = '/customer/booking-details';
  static const String writeReview = '/customer/write-review';
  static const String myReviews = '/customer/my-reviews';
  static const String favorites = '/customer/favorites';
  static const String searchResults = '/customer/search-results';
  static const String categoryHalls = '/customer/category-halls';
  static const String nearbyHalls = '/customer/nearby-halls';
  static const String featuredHalls = '/customer/featured-halls';

  // Hall Owner Routes
  static const String ownerHome = '/owner/home';
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerProfile = '/owner/profile';
  static const String manageHalls = '/owner/manage-halls';
  static const String addHall = '/owner/add-hall';
  static const String editHall = '/owner/edit-hall';
  static const String hallAnalytics = '/owner/hall-analytics';
  static const String ownerBookings = '/owner/bookings';
  static const String bookingManagement = '/owner/booking-management';
  static const String ownerEarnings = '/owner/earnings';
  static const String earningsDetails = '/owner/earnings-details';
  static const String payoutHistory = '/owner/payout-history';
  static const String ownerReviews = '/owner/reviews';
  static const String respondToReview = '/owner/respond-to-review';
  static const String ownerSettings = '/owner/settings';
  static const String hallPricing = '/owner/hall-pricing';
  static const String hallAvailability = '/owner/hall-availability';
  static const String ownerNotifications = '/owner/notifications';
  static const String businessDocuments = '/owner/business-documents';
  static const String bankDetails = '/owner/bank-details';

  // Admin Routes
  static const String adminHome = '/admin/home';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProfile = '/admin/profile';

  // User Management
  static const String usersManagement = '/admin/users-management';
  static const String customersList = '/admin/customers-list';
  static const String ownersList = '/admin/owners-list';
  static const String adminsList = '/admin/admins-list';
  static const String userDetails = '/admin/user-details';
  static const String addAdmin = '/admin/add-admin';
  static const String editUserPermissions = '/admin/edit-user-permissions';

  // Hall Management
  static const String hallsManagement = '/admin/halls-management';
  static const String pendingHalls = '/admin/pending-halls';
  static const String approvedHalls = '/admin/approved-halls';
  static const String rejectedHalls = '/admin/rejected-halls';
  static const String adminHallDetails = '/admin/hall-details';
  static const String hallApproval = '/admin/hall-approval';

  // Booking Management
  static const String bookingsManagement = '/admin/bookings-management';
  static const String allBookings = '/admin/all-bookings';
  static const String pendingBookings = '/admin/pending-bookings';
  static const String adminBookingDetails = '/admin/booking-details';

  // Payment Management
  static const String paymentsManagement = '/admin/payments-management';
  static const String paymentTransactions = '/admin/payment-transactions';
  static const String paymentAnalytics = '/admin/payment-analytics';
  static const String refundRequests = '/admin/refund-requests';
  static const String commissionReports = '/admin/commission-reports';

  // Review Management
  static const String reviewsManagement = '/admin/reviews-management';
  static const String pendingReviews = '/admin/pending-reviews';
  static const String reportedReviews = '/admin/reported-reviews';

  // Analytics & Reports
  static const String systemAnalytics = '/admin/system-analytics';
  static const String userAnalytics = '/admin/user-analytics';
  static const String bookingAnalytics = '/admin/booking-analytics';
  static const String revenueAnalytics = '/admin/revenue-analytics';
  static const String performanceReports = '/admin/performance-reports';

  // System Management
  static const String systemSettings = '/admin/system-settings';
  static const String appSettings = '/admin/app-settings';
  static const String categoriesManagement = '/admin/categories-management';
  static const String amenitiesManagement = '/admin/amenities-management';
  static const String notificationsManagement = '/admin/notifications-management';
  static const String sendNotification = '/admin/send-notification';
  static const String auditLogs = '/admin/audit-logs';
  static const String systemMaintenance = '/admin/system-maintenance';
  static const String backupRestore = '/admin/backup-restore';

  // Error Routes
  static const String notFound = '/404';
  static const String unauthorized = '/unauthorized';
  static const String serverError = '/server-error';
  static const String maintenanceMode = '/maintenance';

  // Route Parameters
  static const String hallIdParam = 'hallId';
  static const String bookingIdParam = 'bookingId';
  static const String userIdParam = 'userId';
  static const String reviewIdParam = 'reviewId';
  static const String paymentIdParam = 'paymentId';
  static const String categoryIdParam = 'categoryId';
  static const String notificationIdParam = 'notificationId';

  // Route Arguments
  static const String hallArg = 'hall';
  static const String bookingArg = 'booking';
  static const String userArg = 'user';
  static const String reviewArg = 'review';
  static const String paymentArg = 'payment';
  static const String isEditModeArg = 'isEditMode';
  static const String returnRouteArg = 'returnRoute';

  // Query Parameters
  static const String searchQueryParam = 'q';
  static const String categoryParam = 'category';
  static const String locationParam = 'location';
  static const String priceMinParam = 'priceMin';
  static const String priceMaxParam = 'priceMax';
  static const String capacityMinParam = 'capacityMin';
  static const String capacityMaxParam = 'capacityMax';
  static const String dateParam = 'date';
  static const String sortByParam = 'sortBy';
  static const String filterParam = 'filter';
  static const String pageParam = 'page';
  static const String limitParam = 'limit';

  // Route Groups for Authorization
  static const List<String> publicRoutes = [
    root,
    splash,
    onboarding,
    login,
    languageSelection,
    about,
    privacyPolicy,
    termsOfService,
    help,
    contactSupport,
    notFound,
    unauthorized,
    serverError,
    maintenanceMode,
  ];

  static const List<String> authRequiredRoutes = [
    profile,
    editProfile,
    settings,
    notifications,
    profileCompletion,
    userTypeSelection,
    pendingApproval,
  ];

  static const List<String> customerRoutes = [
    customerHome,
    customerDashboard,
    hallSearch,
    hallDetails,
    hallGallery,
    hallReviews,
    booking,
    bookingConfirmation,
    payment,
    paymentSuccess,
    paymentFailed,
    myBookings,
    bookingDetails,
    writeReview,
    myReviews,
    favorites,
    searchResults,
    categoryHalls,
    nearbyHalls,
    featuredHalls,
  ];

  static const List<String> ownerRoutes = [
    ownerHome,
    ownerDashboard,
    ownerProfile,
    manageHalls,
    addHall,
    editHall,
    hallAnalytics,
    ownerBookings,
    bookingManagement,
    ownerEarnings,
    earningsDetails,
    payoutHistory,
    ownerReviews,
    respondToReview,
    ownerSettings,
    hallPricing,
    hallAvailability,
    ownerNotifications,
    businessDocuments,
    bankDetails,
  ];

  static const List<String> adminRoutes = [
    adminHome,
    adminDashboard,
    adminProfile,
    usersManagement,
    customersList,
    ownersList,
    adminsList,
    userDetails,
    addAdmin,
    editUserPermissions,
    hallsManagement,
    pendingHalls,
    approvedHalls,
    rejectedHalls,
    adminHallDetails,
    hallApproval,
    bookingsManagement,
    allBookings,
    pendingBookings,
    adminBookingDetails,
    paymentsManagement,
    paymentTransactions,
    paymentAnalytics,
    refundRequests,
    commissionReports,
    reviewsManagement,
    pendingReviews,
    reportedReviews,
    systemAnalytics,
    userAnalytics,
    bookingAnalytics,
    revenueAnalytics,
    performanceReports,
    systemSettings,
    appSettings,
    categoriesManagement,
    amenitiesManagement,
    notificationsManagement,
    sendNotification,
    auditLogs,
    systemMaintenance,
    backupRestore,
  ];

  static const List<String> superAdminOnlyRoutes = [
    addAdmin,
    editUserPermissions,
    systemSettings,
    appSettings,
    systemMaintenance,
    backupRestore,
    auditLogs,
  ];

  // Helper Methods

  /// Check if a route is public (doesn't require authentication)
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }

  /// Check if a route requires authentication
  static bool requiresAuth(String route) {
    return !isPublicRoute(route);
  }

  /// Check if a route is for customers
  static bool isCustomerRoute(String route) {
    return customerRoutes.contains(route);
  }

  /// Check if a route is for hall owners
  static bool isOwnerRoute(String route) {
    return ownerRoutes.contains(route);
  }

  /// Check if a route is for admin users
  static bool isAdminRoute(String route) {
    return adminRoutes.contains(route);
  }

  /// Check if a route requires super admin permissions
  static bool requiresSuperAdmin(String route) {
    return superAdminOnlyRoutes.contains(route);
  }

  /// Get the initial route based on user type and authentication status
  static String getInitialRoute({
    required bool isAuthenticated,
    required bool isProfileCompleted,
    String? userType,
    String? adminRole,
  }) {
    if (!isAuthenticated) {
      return login;
    }

    if (!isProfileCompleted) {
      return profileCompletion;
    }

    switch (userType) {
      case 'customer':
        return customerHome;
      case 'hall_owner':
        return ownerHome;
      case 'admin':
        return adminHome;
      default:
        return userTypeSelection;
    }
  }

  /// Build route with parameters
  static String buildRoute(String route, Map<String, String> params) {
    String builtRoute = route;
    params.forEach((key, value) {
      builtRoute = builtRoute.replaceAll(':$key', value);
    });
    return builtRoute;
  }

  /// Build route with query parameters
  static String buildRouteWithQuery(String route, Map<String, String> queryParams) {
    if (queryParams.isEmpty) return route;

    final queryString = queryParams.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    return '$route?$queryString';
  }

  /// Extract route parameters from a route path
  static Map<String, String> extractParams(String routeTemplate, String actualRoute) {
    final params = <String, String>{};
    final templateParts = routeTemplate.split('/');
    final actualParts = actualRoute.split('/');

    if (templateParts.length != actualParts.length) {
      return params;
    }

    for (int i = 0; i < templateParts.length; i++) {
      final templatePart = templateParts[i];
      if (templatePart.startsWith(':')) {
        final paramName = templatePart.substring(1);
        params[paramName] = actualParts[i];
      }
    }

    return params;
  }

  /// Get the home route for a specific user type
  static String getHomeRoute(String userType) {
    switch (userType) {
      case 'customer':
        return customerHome;
      case 'hall_owner':
        return ownerHome;
      case 'admin':
        return adminHome;
      default:
        return login;
    }
  }

  /// Get the dashboard route for a specific user type
  static String getDashboardRoute(String userType) {
    switch (userType) {
      case 'customer':
        return customerDashboard;
      case 'hall_owner':
        return ownerDashboard;
      case 'admin':
        return adminDashboard;
      default:
        return login;
    }
  }

  /// Check if user has permission to access a route
  static bool hasPermissionForRoute({
    required String route,
    required String userType,
    String? adminRole,
    List<String>? permissions,
  }) {
    // Public routes are accessible to everyone
    if (isPublicRoute(route)) return true;

    // Check user type specific routes
    switch (userType) {
      case 'customer':
        return isCustomerRoute(route) || authRequiredRoutes.contains(route);
      case 'hall_owner':
        return isOwnerRoute(route) || authRequiredRoutes.contains(route);
      case 'admin':
      // Check if super admin route
        if (requiresSuperAdmin(route)) {
          return adminRole == 'super_admin';
        }
        return isAdminRoute(route) || authRequiredRoutes.contains(route);
      default:
        return false;
    }
  }

  /// Get navigation stack for back button behavior
  static List<String> getNavigationStack(String currentRoute, String userType) {
    final homeRoute = getHomeRoute(userType);

    if (currentRoute == homeRoute) {
      return [homeRoute];
    }

    // Build appropriate navigation stack based on current route
    if (isCustomerRoute(currentRoute)) {
      return [customerHome, currentRoute];
    } else if (isOwnerRoute(currentRoute)) {
      return [ownerHome, currentRoute];
    } else if (isAdminRoute(currentRoute)) {
      return [adminHome, currentRoute];
    }

    return [homeRoute, currentRoute];
  }
}
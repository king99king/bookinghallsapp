// core/utils/date_utils.dart

import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Comprehensive date and time utilities for the booking system
class DateUtils {
  // ========== Oman Timezone Configuration ==========

  /// Oman timezone (Gulf Standard Time - GST, UTC+4)
  static const String omanTimezone = 'Asia/Muscat';
  static const Duration omanUtcOffset = Duration(hours: 4);

  // ========== Date Formatting ==========

  /// Format date for display (localized)
  static String formatDate(DateTime date, {String? languageCode}) {
    final isArabic = languageCode == 'ar';

    if (isArabic) {
      return formatDateArabic(date);
    }

    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  /// Format date and time for display (localized)
  static String formatDateTime(DateTime dateTime, {String? languageCode}) {
    final isArabic = languageCode == 'ar';

    if (isArabic) {
      return formatDateTimeArabic(dateTime);
    }

    return DateFormat(AppConstants.displayDateTimeFormat).format(dateTime);
  }

  /// Format time for display (24-hour format)
  static String formatTime(DateTime time, {String? languageCode}) {
    final isArabic = languageCode == 'ar';

    if (isArabic) {
      return formatTimeArabic(time);
    }

    return DateFormat(AppConstants.timeFormat).format(time);
  }

  /// Format date in Arabic
  static String formatDateArabic(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format date and time in Arabic
  static String formatDateTimeArabic(DateTime dateTime) {
    final dateStr = formatDateArabic(dateTime);
    final timeStr = formatTimeArabic(dateTime);
    return '$dateStr - $timeStr';
  }

  /// Format time in Arabic (24-hour format)
  static String formatTimeArabic(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format day of week (localized)
  static String formatDayOfWeek(DateTime date, {String? languageCode}) {
    final isArabic = languageCode == 'ar';
    final dayIndex = date.weekday - 1; // Convert to 0-based index

    if (isArabic) {
      return AppConstants.daysOfWeekArabic[dayIndex];
    }

    return AppConstants.daysOfWeek[dayIndex];
  }

  /// Format relative date (Today, Tomorrow, etc.)
  static String formatRelativeDate(DateTime date, {String? languageCode}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    final isArabic = languageCode == 'ar';

    switch (difference) {
      case 0:
        return isArabic ? 'اليوم' : 'Today';
      case 1:
        return isArabic ? 'غداً' : 'Tomorrow';
      case -1:
        return isArabic ? 'أمس' : 'Yesterday';
      default:
        if (difference > 1 && difference <= 7) {
          return formatDayOfWeek(date, languageCode: languageCode);
        }
        return formatDate(date, languageCode: languageCode);
    }
  }

  // ========== Date Calculations ==========

  /// Get current Oman time
  static DateTime nowInOman() {
    return DateTime.now().toUtc().add(omanUtcOffset);
  }

  /// Convert UTC to Oman time
  static DateTime utcToOman(DateTime utcTime) {
    return utcTime.add(omanUtcOffset);
  }

  /// Convert Oman time to UTC
  static DateTime omanToUtc(DateTime omanTime) {
    return omanTime.subtract(omanUtcOffset);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = nowInOman();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = nowInOman().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Check if date is in the past
  static bool isPastDate(DateTime date) {
    final now = nowInOman();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  /// Check if date is in the future
  static bool isFutureDate(DateTime date) {
    final now = nowInOman();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  /// Check if date is weekend (Friday/Saturday in Oman)
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
  }

  /// Check if date is a working day
  static bool isWorkingDay(DateTime date) {
    return !isWeekend(date);
  }

  /// Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  /// Get hours between two times
  static double hoursBetween(DateTime start, DateTime end) {
    return end.difference(start).inMinutes / 60.0;
  }

  /// Add business days (excluding weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var remainingDays = days;

    while (remainingDays > 0) {
      result = result.add(const Duration(days: 1));
      if (isWorkingDay(result)) {
        remainingDays--;
      }
    }

    return result;
  }

  // ========== Booking Date Validation ==========

  /// Check if booking date meets advance notice requirements
  static bool meetsAdvanceNotice(DateTime bookingDate) {
    final now = nowInOman();
    final minAdvanceTime = now.add(Duration(hours: AppConstants.minAdvanceBookingHours));
    return bookingDate.isAfter(minAdvanceTime);
  }

  /// Check if booking date is within maximum advance period
  static bool withinMaxAdvance(DateTime bookingDate) {
    final now = nowInOman();
    final maxAdvanceDate = now.add(Duration(days: AppConstants.maxAdvanceBookingDays));
    return bookingDate.isBefore(maxAdvanceDate) || bookingDate.isAtSameMomentAs(maxAdvanceDate);
  }

  /// Validate booking date
  static bool isValidBookingDate(DateTime bookingDate) {
    return meetsAdvanceNotice(bookingDate) && withinMaxAdvance(bookingDate);
  }

  /// Get earliest valid booking date
  static DateTime getEarliestBookingDate() {
    final now = nowInOman();
    return now.add(Duration(hours: AppConstants.minAdvanceBookingHours));
  }

  /// Get latest valid booking date
  static DateTime getLatestBookingDate() {
    final now = nowInOman();
    return now.add(Duration(days: AppConstants.maxAdvanceBookingDays));
  }

  // ========== Time Slot Management ==========

  /// Parse time string to DateTime (today's date with specified time)
  static DateTime parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeStr');
    }

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Invalid time values: $timeStr');
    }

    final now = nowInOman();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Convert DateTime to time string (HH:mm)
  static String timeToString(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Create time slot from start and end times
  static Map<String, dynamic> createTimeSlot(String startTime, String endTime, {String? name}) {
    final start = parseTimeString(startTime);
    final end = parseTimeString(endTime);

    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      throw ArgumentError('End time must be after start time');
    }

    final duration = hoursBetween(start, end);

    return {
      'start': startTime,
      'end': endTime,
      'name': name ?? '$startTime - $endTime',
      'duration': duration,
      'isFullDay': duration >= 12, // Consider 12+ hours as full day
    };
  }

  /// Generate default time slots for a hall
  static List<Map<String, dynamic>> generateDefaultTimeSlots({String? languageCode}) {
    final isArabic = languageCode == 'ar';
    final slots = isArabic ? AppConstants.defaultTimeSlotsArabic : AppConstants.defaultTimeSlots;

    return slots.map((slot) => {
      'start': slot['start']!,
      'end': slot['end']!,
      'name': slot['name']!,
      'duration': hoursBetween(
          parseTimeString(slot['start']!),
          parseTimeString(slot['end']!)
      ),
      'isFullDay': slot['start'] == '08:00' && slot['end'] == '23:59',
    }).toList();
  }

  /// Check if two time slots overlap
  static bool timeSlotsOverlap(
      String start1, String end1,
      String start2, String end2,
      ) {
    final slot1Start = parseTimeString(start1);
    final slot1End = parseTimeString(end1);
    final slot2Start = parseTimeString(start2);
    final slot2End = parseTimeString(end2);

    return slot1Start.isBefore(slot2End) && slot2Start.isBefore(slot1End);
  }

  /// Get available time slots (excluding booked ones)
  static List<Map<String, dynamic>> getAvailableTimeSlots(
      List<Map<String, dynamic>> allSlots,
      List<Map<String, dynamic>> bookedSlots,
      ) {
    return allSlots.where((slot) {
      return !bookedSlots.any((bookedSlot) =>
          timeSlotsOverlap(
            slot['start'],
            slot['end'],
            bookedSlot['start'],
            bookedSlot['end'],
          )
      );
    }).toList();
  }

  // ========== Duration Calculations ==========

  /// Format duration in hours and minutes
  static String formatDuration(double hours, {String? languageCode}) {
    final isArabic = languageCode == 'ar';
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();

    if (isArabic) {
      if (minutes == 0) {
        return '$wholeHours ساعة';
      } else if (wholeHours == 0) {
        return '$minutes دقيقة';
      } else {
        return '$wholeHours ساعة و $minutes دقيقة';
      }
    } else {
      if (minutes == 0) {
        return '$wholeHours hour${wholeHours != 1 ? 's' : ''}';
      } else if (wholeHours == 0) {
        return '$minutes minute${minutes != 1 ? 's' : ''}';
      } else {
        return '$wholeHours hour${wholeHours != 1 ? 's' : ''} and $minutes minute${minutes != 1 ? 's' : ''}';
      }
    }
  }

  /// Calculate booking duration from time slot
  static double calculateBookingDuration(String startTime, String endTime) {
    final start = parseTimeString(startTime);
    final end = parseTimeString(endTime);
    return hoursBetween(start, end);
  }

  // ========== Payment Date Calculations ==========

  /// Calculate payment due dates based on event date and payment plan
  static Map<String, DateTime> calculatePaymentDueDates(
      DateTime eventDate,
      double firstPaymentPercent,
      int daysBeforeEventForFinalPayment,
      ) {
    final now = nowInOman();
    final finalPaymentDueDate = eventDate.subtract(Duration(days: daysBeforeEventForFinalPayment));

    return {
      'firstPaymentDue': now, // First payment due immediately
      'finalPaymentDue': finalPaymentDueDate.isBefore(now) ? now : finalPaymentDueDate,
    };
  }

  /// Check if payment is overdue
  static bool isPaymentOverdue(DateTime dueDate) {
    return nowInOman().isAfter(dueDate);
  }

  /// Get days until payment due
  static int daysUntilPaymentDue(DateTime dueDate) {
    final now = nowInOman();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDateOnly.difference(today).inDays;
  }

  // ========== Calendar Utilities ==========

  /// Get calendar month data for display
  static Map<String, dynamic> getCalendarMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    // Adjust for calendar starting on Sunday (common in Gulf countries)
    final adjustedFirstWeekday = firstWeekday == 7 ? 0 : firstWeekday;

    final daysInMonth = lastDayOfMonth.day;
    final weeksInMonth = ((daysInMonth + adjustedFirstWeekday) / 7).ceil();

    return {
      'year': date.year,
      'month': date.month,
      'firstDay': firstDayOfMonth,
      'lastDay': lastDayOfMonth,
      'daysInMonth': daysInMonth,
      'firstWeekday': adjustedFirstWeekday,
      'weeksInMonth': weeksInMonth,
    };
  }

  /// Get list of dates for a calendar month
  static List<DateTime?> getCalendarDates(DateTime date) {
    final monthData = getCalendarMonth(date);
    final dates = <DateTime?>[];

    // Add empty dates for days before month starts
    for (int i = 0; i < monthData['firstWeekday']; i++) {
      dates.add(null);
    }

    // Add all days of the month
    for (int day = 1; day <= monthData['daysInMonth']; day++) {
      dates.add(DateTime(date.year, date.month, day));
    }

    // Pad with nulls to complete the last week
    while (dates.length % 7 != 0) {
      dates.add(null);
    }

    return dates;
  }

  /// Check if date falls within a date range
  static bool isDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    return (checkDate.isAfter(start) || checkDate.isAtSameMomentAs(start)) &&
        (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end));
  }

  // ========== Search and Filter Utilities ==========

  /// Get date range for filtering (e.g., "This Week", "Next Month")
  static Map<String, DateTime> getDateRangeFilter(String filterType) {
    final now = nowInOman();
    final today = DateTime(now.year, now.month, now.day);

    switch (filterType.toLowerCase()) {
      case 'today':
        return {
          'start': today,
          'end': today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        };

      case 'tomorrow':
        final tomorrow = today.add(const Duration(days: 1));
        return {
          'start': tomorrow,
          'end': tomorrow.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        };

      case 'this_week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return {'start': startOfWeek, 'end': endOfWeek};

      case 'next_week':
        final nextMonday = today.add(Duration(days: 8 - today.weekday));
        final nextSunday = nextMonday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return {'start': nextMonday, 'end': nextSunday};

      case 'this_month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return {'start': startOfMonth, 'end': endOfMonth};

      case 'next_month':
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
        final endOfNextMonth = DateTime(now.year, now.month + 2, 0, 23, 59, 59);
        return {'start': startOfNextMonth, 'end': endOfNextMonth};

      default:
      // Default to next 30 days
        return {
          'start': today,
          'end': today.add(const Duration(days: 30)),
        };
    }
  }

  // ========== Utility Methods ==========

  /// Parse ISO 8601 date string
  static DateTime? parseISODate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Convert DateTime to ISO 8601 string
  static String toISOString(DateTime date) {
    return date.toIso8601String();
  }

  /// Get age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = nowInOman();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Round time to nearest 15 minutes
  static DateTime roundToNearestQuarterHour(DateTime time) {
    final minutes = time.minute;
    final roundedMinutes = ((minutes / 15).round()) * 15;

    if (roundedMinutes == 60) {
      return DateTime(time.year, time.month, time.day, time.hour + 1, 0);
    } else {
      return DateTime(time.year, time.month, time.day, time.hour, roundedMinutes);
    }
  }

  /// Get time zones for display
  static Map<String, String> getTimezoneInfo() {
    return {
      'timezone': omanTimezone,
      'offset': '+04:00',
      'name': 'Gulf Standard Time (GST)',
      'nameArabic': 'توقيت الخليج المعياري',
    };
  }

  /// Format time difference (e.g., "2 hours ago", "in 3 days")
  static String formatTimeDifference(DateTime date, {String? languageCode}) {
    final now = nowInOman();
    final difference = date.difference(now);
    final isArabic = languageCode == 'ar';
    final isPast = difference.isNegative;
    final absDifference = difference.abs();

    String timeStr;

    if (absDifference.inDays > 0) {
      final days = absDifference.inDays;
      timeStr = isArabic ? '$days يوم' : '$days day${days != 1 ? 's' : ''}';
    } else if (absDifference.inHours > 0) {
      final hours = absDifference.inHours;
      timeStr = isArabic ? '$hours ساعة' : '$hours hour${hours != 1 ? 's' : ''}';
    } else {
      final minutes = absDifference.inMinutes;
      timeStr = isArabic ? '$minutes دقيقة' : '$minutes minute${minutes != 1 ? 's' : ''}';
    }

    if (isPast) {
      return isArabic ? 'منذ $timeStr' : '$timeStr ago';
    } else {
      return isArabic ? 'خلال $timeStr' : 'in $timeStr';
    }
  }

  /// Get business hours check
  static bool isWithinBusinessHours(DateTime time, {
    int startHour = 8,
    int endHour = 22,
  }) {
    return time.hour >= startHour && time.hour < endHour;
  }

  /// Get next business day
  static DateTime getNextBusinessDay(DateTime date) {
    var nextDay = date.add(const Duration(days: 1));
    while (isWeekend(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }
}
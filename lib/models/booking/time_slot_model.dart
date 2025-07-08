// models/booking/time_slot_model.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';

/// Time slot model for hourly bookings
class TimeSlot {
  final String startTime; // Format: "HH:mm"
  final String endTime;   // Format: "HH:mm"
  final bool isFullDay;
  final double? customRate;
  final bool isAvailable;
  final String? unavailableReason;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isFullDay = false,
    this.customRate,
    this.isAvailable = true,
    this.unavailableReason,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    final startTimeError = Validators.validateTimeFormat(json['startTime'], 'Start time');
    final endTimeError = Validators.validateTimeFormat(json['endTime'], 'End time');
    
    if (startTimeError != null) {
      throw ArgumentError(startTimeError);
    }
    if (endTimeError != null) {
      throw ArgumentError(endTimeError);
    }
    
    return TimeSlot(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isFullDay: json['isFullDay'] as bool? ?? false,
      customRate: (json['customRate'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      unavailableReason: json['unavailableReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isFullDay': isFullDay,
      'customRate': customRate,
      'isAvailable': isAvailable,
      'unavailableReason': unavailableReason,
    };
  }

  /// Create full day slot
  factory TimeSlot.fullDay({double? customRate}) {
    return TimeSlot(
      startTime: "00:00",
      endTime: "23:59",
      isFullDay: true,
      customRate: customRate,
    );
  }

  /// Create morning slot (6 AM - 12 PM)
  factory TimeSlot.morning({double? customRate}) {
    return TimeSlot(
      startTime: "06:00",
      endTime: "12:00",
      customRate: customRate,
    );
  }

  /// Create afternoon slot (12 PM - 6 PM)
  factory TimeSlot.afternoon({double? customRate}) {
    return TimeSlot(
      startTime: "12:00",
      endTime: "18:00",
      customRate: customRate,
    );
  }

  /// Create evening slot (6 PM - 12 AM)
  factory TimeSlot.evening({double? customRate}) {
    return TimeSlot(
      startTime: "18:00",
      endTime: "24:00",
      customRate: customRate,
    );
  }

  /// Get duration in hours
  int getDurationInHours() {
    if (isFullDay) return 24;

    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (end.isBefore(start)) {
      // Handle overnight slots
      final nextDay = DateTime(end.year, end.month, end.day + 1, end.hour, end.minute);
      return nextDay.difference(start).inHours;
    }

    return end.difference(start).inHours;
  }

  /// Get duration in minutes
  int getDurationInMinutes() {
    if (isFullDay) return 24 * 60;

    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (end.isBefore(start)) {
      // Handle overnight slots
      final nextDay = DateTime(end.year, end.month, end.day + 1, end.hour, end.minute);
      return nextDay.difference(start).inMinutes;
    }

    return end.difference(start).inMinutes;
  }

  /// Check if time slot overlaps with another
  bool overlapsWith(TimeSlot other) {
    if (isFullDay || other.isFullDay) return true;

    final thisStart = _parseTime(startTime);
    final thisEnd = _parseTime(endTime);
    final otherStart = _parseTime(other.startTime);
    final otherEnd = _parseTime(other.endTime);

    return thisStart.isBefore(otherEnd) && otherStart.isBefore(thisEnd);
  }

  /// Check if time slot contains a specific time
  bool containsTime(String time) {
    if (isFullDay) return true;

    final checkTime = _parseTime(time);
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (end.isBefore(start)) {
      // Handle overnight slots
      return checkTime.isAfter(start) || checkTime.isBefore(end);
    }

    return checkTime.isAfter(start) && checkTime.isBefore(end);
  }

  /// Get formatted display text
  String getDisplayText({String languageCode = 'en'}) {
    if (isFullDay) {
      return languageCode == 'ar' ? 'اليوم كامل' : 'Full Day';
    }

    final start = _formatTimeForDisplay(startTime, languageCode);
    final end = _formatTimeForDisplay(endTime, languageCode);

    return '$start - $end';
  }

  /// Get time period name
  String getPeriodName({String languageCode = 'en'}) {
    if (isFullDay) {
      return languageCode == 'ar' ? 'اليوم كامل' : 'Full Day';
    }

    final startHour = int.parse(startTime.split(':')[0]);

    if (startHour >= 6 && startHour < 12) {
      return languageCode == 'ar' ? 'الصباح' : 'Morning';
    } else if (startHour >= 12 && startHour < 18) {
      return languageCode == 'ar' ? 'بعد الظهر' : 'Afternoon';
    } else {
      return languageCode == 'ar' ? 'المساء' : 'Evening';
    }
  }

  /// Make slot unavailable
  TimeSlot makeUnavailable(String reason) {
    return TimeSlot(
      startTime: startTime,
      endTime: endTime,
      isFullDay: isFullDay,
      customRate: customRate,
      isAvailable: false,
      unavailableReason: reason,
    );
  }

  /// Make slot available
  TimeSlot makeAvailable() {
    return TimeSlot(
      startTime: startTime,
      endTime: endTime,
      isFullDay: isFullDay,
      customRate: customRate,
      isAvailable: true,
      unavailableReason: null,
    );
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTimeForDisplay(String time, String languageCode) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (languageCode == 'ar') {
      // Arabic time format
      final period = hour >= 12 ? 'م' : 'ص';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${minute.toString().padLeft(2, '0')}:${displayHour.toString().padLeft(2, '0')} $period';
    } else {
      // English 12-hour format
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isFullDay == isFullDay;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, isFullDay);

  @override
  String toString() => getDisplayText();
}

/// Time slot with ID for database storage
class TimeSlotWithId extends TimeSlot {
  final String id;

  TimeSlotWithId({
    required this.id,
    required super.startTime,
    required super.endTime,
    super.isFullDay,
    super.customRate,
    super.isAvailable,
    super.unavailableReason,
  });

  factory TimeSlotWithId.fromJson(Map<String, dynamic> json) {
    final startTimeError = Validators.validateTimeFormat(json['startTime'], 'Start time');
    final endTimeError = Validators.validateTimeFormat(json['endTime'], 'End time');
    
    if (startTimeError != null) {
      throw ArgumentError(startTimeError);
    }
    if (endTimeError != null) {
      throw ArgumentError(endTimeError);
    }
    
    return TimeSlotWithId(
      id: json['id'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isFullDay: json['isFullDay'] as bool? ?? false,
      customRate: (json['customRate'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      unavailableReason: json['unavailableReason'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['id'] = id;
    return baseJson;
  }

  /// Create from base TimeSlot
  factory TimeSlotWithId.fromTimeSlot(String id, TimeSlot timeSlot) {
    return TimeSlotWithId(
      id: id,
      startTime: timeSlot.startTime,
      endTime: timeSlot.endTime,
      isFullDay: timeSlot.isFullDay,
      customRate: timeSlot.customRate,
      isAvailable: timeSlot.isAvailable,
      unavailableReason: timeSlot.unavailableReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlotWithId && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Predefined time slots helper
class PredefinedTimeSlots {
  static List<TimeSlot> getDefaultDailySlots() {
    return [
      TimeSlot.fullDay(),
    ];
  }

  static List<TimeSlot> getDefaultHourlySlots() {
    return [
      TimeSlot.morning(),
      TimeSlot.afternoon(),
      TimeSlot.evening(),
    ];
  }

  static List<TimeSlot> getWeddingTimeSlots() {
    return [
      TimeSlot.fullDay(),
      TimeSlot(startTime: "16:00", endTime: "24:00"), // 4 PM - 12 AM
      TimeSlot(startTime: "18:00", endTime: "24:00"), // 6 PM - 12 AM
      TimeSlot(startTime: "20:00", endTime: "24:00"), // 8 PM - 12 AM
    ];
  }

  static List<TimeSlot> getCorporateTimeSlots() {
    return [
      TimeSlot(startTime: "08:00", endTime: "17:00"), // 8 AM - 5 PM
      TimeSlot(startTime: "09:00", endTime: "17:00"), // 9 AM - 5 PM
      TimeSlot(startTime: "08:00", endTime: "12:00"), // 8 AM - 12 PM
      TimeSlot(startTime: "13:00", endTime: "17:00"), // 1 PM - 5 PM
    ];
  }

  static List<TimeSlot> getConferenceTimeSlots() {
    return [
      TimeSlot.fullDay(),
      TimeSlot(startTime: "08:00", endTime: "17:00"), // 8 AM - 5 PM
      TimeSlot(startTime: "09:00", endTime: "16:00"), // 9 AM - 4 PM
    ];
  }

  static List<TimeSlot> getTimeSlotsForEventType(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return getWeddingTimeSlots();
      case 'corporate':
        return getCorporateTimeSlots();
      case 'conference':
        return getConferenceTimeSlots();
      default:
        return getDefaultHourlySlots();
    }
  }
}
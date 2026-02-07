import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationSettings {
  final bool dailyReminder;
  final String dailyReminderTime; // Format HH:mm
  final bool budgetAlerts;
  final double budgetThreshold; // Pourcentage
  final bool transactionNotifications;
  final bool weeklyReport;
  final String weeklyReportDay; // Lundi, Mardi, etc.

  NotificationSettings({
    this.dailyReminder = false,
    this.dailyReminderTime = '20:00',
    this.budgetAlerts = true,
    this.budgetThreshold = 80.0,
    this.transactionNotifications = true,
    this.weeklyReport = false,
    this.weeklyReportDay = 'Lundi',
  });

  NotificationSettings copyWith({
    bool? dailyReminder,
    String? dailyReminderTime,
    bool? budgetAlerts,
    double? budgetThreshold,
    bool? transactionNotifications,
    bool? weeklyReport,
    String? weeklyReportDay,
  }) {
    return NotificationSettings(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      budgetThreshold: budgetThreshold ?? this.budgetThreshold,
      transactionNotifications: transactionNotifications ?? this.transactionNotifications,
      weeklyReport: weeklyReport ?? this.weeklyReport,
      weeklyReportDay: weeklyReportDay ?? this.weeklyReportDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyReminder': dailyReminder,
      'dailyReminderTime': dailyReminderTime,
      'budgetAlerts': budgetAlerts,
      'budgetThreshold': budgetThreshold,
      'transactionNotifications': transactionNotifications,
      'weeklyReport': weeklyReport,
      'weeklyReportDay': weeklyReportDay,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailyReminder: json['dailyReminder'] ?? false,
      dailyReminderTime: json['dailyReminderTime'] ?? '20:00',
      budgetAlerts: json['budgetAlerts'] ?? true,
      budgetThreshold: json['budgetThreshold'] ?? 80.0,
      transactionNotifications: json['transactionNotifications'] ?? true,
      weeklyReport: json['weeklyReport'] ?? false,
      weeklyReportDay: json['weeklyReportDay'] ?? 'Lundi',
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationSettings> {
  static const String _settingsKey = 'notification_settings';

  NotificationNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = Hive.box('settings');
    final data = box.get(_settingsKey);

    if (data != null) {
      state = NotificationSettings.fromJson(Map<String, dynamic>.from(data));
    }
  }

  Future<void> _saveSettings() async {
    final box = Hive.box('settings');
    await box.put(_settingsKey, state.toJson());
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    state = settings;
    await _saveSettings();
  }

  Future<void> toggleDailyReminder(bool value) async {
    state = state.copyWith(dailyReminder: value);
    await _saveSettings();
  }

  Future<void> setDailyReminderTime(String time) async {
    state = state.copyWith(dailyReminderTime: time);
    await _saveSettings();
  }

  Future<void> toggleBudgetAlerts(bool value) async {
    state = state.copyWith(budgetAlerts: value);
    await _saveSettings();
  }

  Future<void> setBudgetThreshold(double value) async {
    state = state.copyWith(budgetThreshold: value);
    await _saveSettings();
  }

  Future<void> toggleTransactionNotifications(bool value) async {
    state = state.copyWith(transactionNotifications: value);
    await _saveSettings();
  }

  Future<void> toggleWeeklyReport(bool value) async {
    state = state.copyWith(weeklyReport: value);
    await _saveSettings();
  }

  Future<void> setWeeklyReportDay(String day) async {
    state = state.copyWith(weeklyReportDay: day);
    await _saveSettings();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationSettings>(
      (ref) => NotificationNotifier(),
);
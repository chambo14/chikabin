import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gérez vos préférences de notification',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 24),
        
            // Rappel quotidien
            _buildSectionTitle('Rappels', isDark),
            const SizedBox(height: 12),
        
            _buildSwitchCard(
              context,
              icon: Icons.alarm,
              title: 'Rappel quotidien',
              subtitle: 'Recevoir un rappel pour enregistrer vos dépenses',
              value: settings.dailyReminder,
              onChanged: (value) => notifier.toggleDailyReminder(value),
              isDark: isDark,
            ),
        
            if (settings.dailyReminder)
              _buildTimeSelector(
                context,
                time: settings.dailyReminderTime,
                onTimeSelected: (time) => notifier.setDailyReminderTime(time),
                isDark: isDark,
              ),
        
            const SizedBox(height: 12),
        
            _buildSwitchCard(
              context,
              icon: Icons.calendar_today,
              title: 'Rapport hebdomadaire',
              subtitle: 'Recevoir un résumé de vos finances chaque semaine',
              value: settings.weeklyReport,
              onChanged: (value) => notifier.toggleWeeklyReport(value),
              isDark: isDark,
            ),
        
            if (settings.weeklyReport)
              _buildDaySelector(
                context,
                selectedDay: settings.weeklyReportDay,
                onDaySelected: (day) => notifier.setWeeklyReportDay(day),
                isDark: isDark,
              ),
        
            const SizedBox(height: 24),
        
            // Alertes
            _buildSectionTitle('Alertes', isDark),
            const SizedBox(height: 12),
        
            _buildSwitchCard(
              context,
              icon: Icons.warning_amber_rounded,
              title: 'Alertes de budget',
              subtitle: 'Être notifié quand vous approchez de votre limite',
              value: settings.budgetAlerts,
              onChanged: (value) => notifier.toggleBudgetAlerts(value),
              isDark: isDark,
            ),
        
            if (settings.budgetAlerts)
              _buildThresholdSlider(
                context,
                threshold: settings.budgetThreshold,
                onChanged: (value) => notifier.setBudgetThreshold(value),
                isDark: isDark,
              ),
        
            const SizedBox(height: 12),
        
            _buildSwitchCard(
              context,
              icon: Icons.receipt_long,
              title: 'Confirmations de transactions',
              subtitle: 'Recevoir une notification après chaque transaction',
              value: settings.transactionNotifications,
              onChanged: (value) => notifier.toggleTransactionNotifications(value),
              isDark: isDark,
            ),
        
            const SizedBox(height: 32),
        
            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Les notifications vous aident à rester informé de vos finances et à maintenir de bonnes habitudes budgétaires.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.grey[800],
      ),
    );
  }

  Widget _buildSwitchCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required Function(bool) onChanged,
        required bool isDark,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
      BuildContext context, {
        required String time,
        required Function(String) onTimeSelected,
        required bool isDark,
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            'Heure du rappel',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: int.parse(time.split(':')[0]),
                  minute: int.parse(time.split(':')[1]),
                ),
              );
              if (picked != null) {
                final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                onTimeSelected(formattedTime);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(
      BuildContext context, {
        required String selectedDay,
        required Function(String) onDaySelected,
        required bool isDark,
      }) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Text(
                'Jour du rapport',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days.map((day) {
              final isSelected = day == selectedDay;
              return InkWell(
                onTap: () => onDaySelected(day),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.grey[800] : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    day.substring(0, 3),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSlider(
      BuildContext context, {
        required double threshold,
        required Function(double) onChanged,
        required bool isDark,
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seuil d\'alerte',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${threshold.toInt()}%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: threshold,
            min: 50,
            max: 100,
            divisions: 10,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '50%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '100%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
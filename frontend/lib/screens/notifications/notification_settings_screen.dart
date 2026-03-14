import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // SMS toggles
  bool _smsPatientFollowup = true;
  bool _smsVisitReminder = true;
  bool _smsHighRiskAlert = true;

  // App toggles
  bool _appDailySummary = true;
  bool _appAssignmentUpdates = true;
  bool _appSystemAlerts = true;

  String _reminderFrequency = '1 day before';
  String _preferredTime = '8:00 AM';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.charcoalText,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.mutedGrey,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [Tab(text: 'Settings'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSettingsTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SMS Section
          Row(children: [
            const Icon(Icons.sms, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('SMS Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          _toggleCard('Patient Follow-up Reminders', 'Send SMS to patients for scheduled follow-up',
            _smsPatientFollowup, (v) => setState(() => _smsPatientFollowup = v)),
          _toggleCard('Visit Reminder to Students', 'Notify students about pending visits',
            _smsVisitReminder, (v) => setState(() => _smsVisitReminder = v)),
          _toggleCard('High Risk Alert SMS', 'Immediate SMS for critical health findings',
            _smsHighRiskAlert, (v) => setState(() => _smsHighRiskAlert = v)),

          // SMS Template Preview
          Card(
            child: ExpansionTile(
              title: const Text('SMS Template', style: TextStyle(fontSize: 14)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.softGrey, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'Dear [Name], your health follow-up visit is scheduled on [Date]. '
                      'Please be available at home. — Village Health Team',
                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.mutedGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Notifications Section
          Row(children: [
            const Icon(Icons.notifications, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('App Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          _toggleCard('Daily Visit Summary', 'End of day visit summary',
            _appDailySummary, (v) => setState(() => _appDailySummary = v)),
          _toggleCard('Assignment Updates', 'New house assignment notifications',
            _appAssignmentUpdates, (v) => setState(() => _appAssignmentUpdates = v)),
          _toggleCard('System Alerts', 'System-level notifications',
            _appSystemAlerts, (v) => setState(() => _appSystemAlerts = v)),
          const SizedBox(height: 12),

          // Reminder Frequency
          Card(child: ListTile(
            title: const Text('Reminder Frequency'),
            trailing: DropdownButton<String>(
              value: _reminderFrequency,
              items: ['Same day', '1 day before', '2 days before']
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
                .toList(),
              onChanged: (v) => setState(() => _reminderFrequency = v!),
              underline: const SizedBox(),
            ),
          )),
          const SizedBox(height: 12),

          // Preferred Time
          Card(child: ListTile(
            title: const Text('Preferred Notification Time'),
            trailing: Text(_preferredTime, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500)),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
              if (time != null) setState(() => _preferredTime = time.format(context));
            },
          )),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _notificationItem(Icons.assignment, 'New visit assigned: House #H-089', '2 min ago', AppTheme.primaryBlue),
        _notificationItem(Icons.sms, 'SMS sent to Ram Kumar', '1 hour ago', AppTheme.mutedGrey),
        _notificationItem(Icons.warning, 'High risk alert: House #H-042', '3 hours ago', AppTheme.cautionAmber),
        _notificationItem(Icons.check_circle, 'Visit completed: House #H-012', '5 hours ago', AppTheme.normalGreen),
        _notificationItem(Icons.people, 'New assignment: 5 houses added', 'Yesterday', AppTheme.primaryBlue),
      ],
    );
  }

  Widget _toggleCard(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.normalGreen,
      ),
    );
  }

  Widget _notificationItem(IconData icon, String text, String time, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(text, style: const TextStyle(fontSize: 14)),
        trailing: Text(time, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
      ),
    );
  }

  void _saveSettings() async {
    try {
      await ApiService.updateNotificationPreferences({
        'smsPatientFollowup': _smsPatientFollowup,
        'smsVisitReminder': _smsVisitReminder,
        'smsHighRiskAlert': _smsHighRiskAlert,
        'appDailySummary': _appDailySummary,
        'appAssignmentUpdates': _appAssignmentUpdates,
        'appSystemAlerts': _appSystemAlerts,
        'reminderFrequency': _reminderFrequency == 'Same day' ? 'same_day' : _reminderFrequency == '1 day before' ? '1_day_before' : '2_days_before',
        'preferredTime': _preferredTime,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved!'), backgroundColor: AppTheme.normalGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings'), backgroundColor: AppTheme.alertRed),
        );
      }
    }
  }
}

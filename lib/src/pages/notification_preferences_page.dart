import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _emailEnabled = true;
  bool _inAppEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your alerts and stay updated on your active investment vehicles.',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildPreferenceTile(
              title: 'Email Notifications',
              subtitle: 'Receive daily summaries and trade alerts via email.',
              value: _emailEnabled,
              onChanged: (val) {
                if (!val && !_inAppEnabled) return; // Cannot turn both off
                setState(() => _emailEnabled = val);
              },
            ),
            const Divider(height: 32),
            _buildPreferenceTile(
              title: 'In-App Notifications',
              subtitle: 'Real-time alerts for wins, losses, and system status.',
              value: _inAppEnabled,
              onChanged: (val) {
                if (!val && !_emailEnabled) return; // Cannot turn both off
                setState(() => _inAppEnabled = val);
              },
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Note: At least one notification method must be active.',
                style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.orange,
      ),
    );
  }
}

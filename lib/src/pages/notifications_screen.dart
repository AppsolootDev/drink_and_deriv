import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'investment_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<int> _clickedIndices = {};

  Color _getIconColor(IconData icon) {
    if (icon == Icons.play_arrow) return Colors.green;
    if (icon == Icons.pause) return Colors.orange;
    if (icon == Icons.stop) return Colors.red;
    if (icon == Icons.warning || icon == Icons.warning_amber_rounded) return const Color(0xFFFBC02D); // Dark Yellow
    return Colors.orange.shade300;
  }

  void _showNotificationDetail(BuildContext context, AppNotification note, int index) {
    setState(() {
      _clickedIndices.add(index);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(note.icon, color: _getIconColor(note.icon)),
            const SizedBox(width: 12),
            Expanded(child: Text(note.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text(
              'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(note.time)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Clear All',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Notifications'),
                  content: const Text('Are you sure you want to delete all notifications?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                    TextButton(
                      onPressed: () {
                        investmentManager.clearNotifications();
                        Navigator.pop(context);
                      },
                      child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: investmentManager,
        builder: (context, child) {
          final notifications = investmentManager.notifications;
          
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No new notifications.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final note = notifications[index];
              final isClicked = _clickedIndices.contains(index);
              final iconColor = _getIconColor(note.icon);
              final notificationNumber = notifications.length - index;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: isClicked ? Colors.orange.shade50 : Colors.white,
                child: ListTile(
                  onTap: () => _showNotificationDetail(context, note, index),
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.1),
                        child: Icon(note.icon, color: iconColor),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Text(
                          '#$notificationNumber',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    note.title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isClicked ? Colors.orange.shade900 : Colors.black87,
                    )
                  ),
                  subtitle: Text(
                    note.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9), // 9px description
                  ),
                  trailing: const Icon(Icons.info_outline, size: 20, color: Color(0xFFBA8858)), // Info icon instead of arrow
                ),
              );
            },
          );
        },
      ),
    );
  }
}

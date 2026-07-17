import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:whisker/providers/cat_provider.dart';
import 'package:whisker/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _remindersEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  late Box _settingsBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox('appSettingsBox');
    setState(() {
      _remindersEnabled = _settingsBox.get('reminderEnabled', defaultValue: false);
      final hour = _settingsBox.get('reminderHour', defaultValue: 18);
      final minute = _settingsBox.get('reminderMinute', defaultValue: 0);
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB5A7),
              onPrimary: Color(0xFF4A3E3D),
              surface: Color(0xFFFFF9F8),
              onSurface: Color(0xFF4A3E3D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      if (_remindersEnabled) {
        await NotificationService().scheduleDailyNotification(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }
  }

  Future<void> _toggleReminders(bool value) async {
    setState(() {
      _remindersEnabled = value;
    });
    if (value) {
      // Request permission and schedule
      final granted = await NotificationService().requestPermission();
      if (granted) {
        await NotificationService().scheduleDailyNotification(
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
      } else {
        // If denied, we still toggle on in UI but print warning or let it fail softly
        setState(() {
          _remindersEnabled = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permissions are disabled in settings.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      await NotificationService().disableNotification();
    }
  }

  void _showRenameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9F8),
        title: const Text(
          'Rename Your Cat',
          style: TextStyle(color: Color(0xFF4A3E3D), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new name...',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFB5A7)),
            ),
          ),
          style: const TextStyle(color: Color(0xFF4A3E3D)),
          maxLength: 15,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(catProvider.notifier).updateName(controller.text.trim());
              }
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(catProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF9F8),
              Color(0xFFFCD5CE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Cat Profile Section
            _buildSectionHeader('Cat Profile'),
            Card(
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                title: const Text(
                  'Cat Name',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A3E3D)),
                ),
                subtitle: Text(
                  catState.name,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.edit, color: Color(0xFFFFB5A7)),
                onTap: () => _showRenameDialog(context, catState.name),
              ),
            ),
            const SizedBox(height: 24),

            // Reminders Section
            _buildSectionHeader('Daily Reminders'),
            Card(
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Enable Reminder',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A3E3D)),
                    ),
                    subtitle: const Text(
                      'Get nudges to check in on Whisker',
                      style: TextStyle(fontSize: 12),
                    ),
                    activeTrackColor: const Color(0xFFFFB5A7),
                    value: _remindersEnabled,
                    onChanged: _toggleReminders,
                  ),
                  if (_remindersEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text(
                        'Reminder Time',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A3E3D)),
                      ),
                      subtitle: Text(
                        _reminderTime.format(context),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.access_time, color: Color(0xFFFFB5A7)),
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A3E3D),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

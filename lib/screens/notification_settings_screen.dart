import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late Box _settingsBox;
  bool _notifEnabled = true;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _notifEnabled =
        _settingsBox.get('notif_enabled', defaultValue: true) ?? true;
  }

  Future<void> _save() async {
    await _settingsBox.put('notif_enabled', _notifEnabled);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan notifikasi disimpan')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Aktifkan Notifikasi'),
              subtitle:
                  const Text('Misalnya pengingat hutang atau pengeluaran besar'),
              value: _notifEnabled,
              onChanged: (val) {
                setState(() => _notifEnabled = val);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late Box _settingsBox;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _darkMode = _settingsBox.get('dark_mode', defaultValue: false) ?? false;
  }

  Future<void> _save() async {
    await _settingsBox.put('dark_mode', _darkMode);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan disimpan')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Mode Gelap (Dark Mode)'),
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
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

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SecurityCodeScreen extends StatefulWidget {
  const SecurityCodeScreen({super.key});

  @override
  State<SecurityCodeScreen> createState() => _SecurityCodeScreenState();
}

class _SecurityCodeScreenState extends State<SecurityCodeScreen> {
  final TextEditingController _pinCtrl = TextEditingController();
  late Box _settingsBox;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    // kalau sudah ada PIN, tampilkan biar bisa diganti
    final existingPin = _settingsBox.get('pin', defaultValue: '');
    _pinCtrl.text = existingPin ?? '';
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinCtrl.text.trim();

    if (pin.length != 4 || int.tryParse(pin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus 4 digit angka')),
      );
      return;
    }

    await _settingsBox.put('pin', pin);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN tersimpan')),
    );

    Navigator.pop(context); // balik ke Profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Atur PIN 4 digit untuk membuka aplikasi setelah login.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePin,
                child: const Text('Simpan PIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';

// IMPORT SCREEN LAIN
import 'edit_account_screen.dart';
import 'security_code_screen.dart';
import 'notification_settings_screen.dart';
import 'app_settings_screen.dart';
import 'budget_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Box<UserModel> userBox;
  late final Box settingsBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<UserModel>('user');
    settingsBox = Hive.box('settings');
  }

  // ========================= PIN SYSTEM =========================

  String _getPinStatusText() {
    final pin = settingsBox.get('pin');
    return (pin == null || pin == '')
        ? 'Aktifkan PIN'
        : 'Nonaktifkan PIN';
  }

  Future<void> _togglePinStatus() async {
    final pin = settingsBox.get('pin');

    if (pin == null || pin == '') {
      // PIN belum ada → buka screen buat PIN
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SecurityCodeScreen()),
      ).then((_) => setState(() {}));
    } else {
      // PIN ada → hapus PIN
      await settingsBox.put('pin', '');
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil dinonaktifkan')),
      );
    }
  }

  // ========================= PROFIL FOTO =========================

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final currentUser = userBox.get('account');
    if (currentUser != null) {
      final updatedUser =
          currentUser.copyWith(profileImagePath: picked.path);
      await userBox.put('account', updatedUser);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userBox.get('account');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // FOTO PROFIL
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user?.profileImagePath != null &&
                        user!.profileImagePath!.isNotEmpty
                    ? FileImage(File(user.profileImagePath!))
                    : null,
                child: user?.profileImagePath == null ||
                        user!.profileImagePath!.isEmpty
                    ? const Icon(Icons.person, size: 45)
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              user?.name ?? 'Anak Kos',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? 'email@anak-kos.com',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // ========================= MENU LIST =========================

            Expanded(
              child: ListView(
                children: [
                  _ProfileItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Data Akun',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditAccountScreen(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),

                  // 🔥 AKTIFKAN / MATIKAN PIN
                  _ProfileItem(
                    icon: Icons.lock_reset,
                    title: _getPinStatusText(),
                    onTap: _togglePinStatus,
                  ),

                  // GANTI PIN
                  _ProfileItem(
                    icon: Icons.lock_outline,
                    title: 'Ganti PIN',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityCodeScreen(),
                        ),
                      );
                    },
                  ),

                  _ProfileItem(
                    icon: Icons.savings_outlined,
                    title: 'Pengingat Boros',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BudgetScreen(),
                        ),
                      );
                    },
                  ),

                  // NOTIFIKASI
                  _ProfileItem(
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  // PENGATURAN APLIKASI
                  _ProfileItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  // LOGOUT
                  _ProfileItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= UI LIST ITEM =========================

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

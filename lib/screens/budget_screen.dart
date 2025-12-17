import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/budget_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Box<BudgetModel> _budgetBox;

  final _amountCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _budgetBox = Hive.box<BudgetModel>('budget');

    final existing = _budgetBox.get('current');
    if (existing != null) {
      _amountCtrl.text = existing.totalAmount.toString();
      _startDate = existing.startDate;
      _endDate = existing.endDate;
      _isActive = existing.isActive;
    } else {
      final now = DateTime.now();
      _startDate = now;
      _endDate = now.add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final first = DateTime(DateTime.now().year - 1);
    final last = DateTime(DateTime.now().year + 2);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _saveBudget() async {
    final amountText = _amountCtrl.text.trim();

    if (amountText.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal & tanggal harus diisi')),
      );
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal selesai harus setelah tanggal mulai')),
      );
      return;
    }

    final budget = BudgetModel(
      totalAmount: amount,
      startDate: _startDate!,
      endDate: _endDate!,
      isActive: _isActive,
    );

    await _budgetBox.put('current', budget);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anggaran tersimpan')),
    );

    Navigator.pop(context);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}-${date.month}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Boros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Set anggaran supaya uangmu cukup sampai tanggal tertentu.\n'
              'Nanti aplikasi bisa mengingatkan kalau pola pengeluaranmu boros.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total uang yang harus cukup (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 1000000',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mulai dari',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickDate(isStart: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(_formatDate(_startDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sampai tanggal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickDate(isStart: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(_formatDate(_endDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Aktifkan pengingat boros'),
              subtitle: const Text('Kalau dimatikan, anggaran ini diabaikan.'),
              value: _isActive,
              onChanged: (val) {
                setState(() => _isActive = val);
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Simpan Anggaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

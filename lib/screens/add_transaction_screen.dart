import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTx; // ⬅️ null = tambah, ada isi = edit

  const AddTransactionScreen({
    super.key,
    this.existingTx,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isIncome = true;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    // Kalau mode EDIT, isi form dengan data lama
    if (widget.existingTx != null) {
      final tx = widget.existingTx!;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.abs().toString();
      _selectedCategory = tx.category;
      isIncome = tx.amount > 0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final category = _selectedCategory;

    if (title.isEmpty || amountText.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dulu ya')),
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

    // Kalau edit, pakai tanggal lama; kalau tambah, pakai hari ini
    final now = DateTime.now();
    final dateText = widget.existingTx?.date ??
        '${now.day}-${now.month}-${now.year}';

    final tx = TransactionModel(
      title: title,
      date: dateText,
      amount: isIncome ? amount : -amount,
      category: category,
    );

    // KIRIM BALIK KE MAINNAVIGATION
    Navigator.pop(context, tx);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.existingTx != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E9FF),
        elevation: 0,
        title: Text(isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOGGLE INCOME / EXPENSE
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isIncome = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isIncome ? Colors.white : Colors.white70,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome
                                ? const Color(0xFF6C5CE7)
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isIncome = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !isIncome ? Colors.white : Colors.white70,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !isIncome
                                ? const Color(0xFF6C5CE7)
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Judul',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Bayar kos, gaji part-time...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Nominal (Rp)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 250000',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: const [
                DropdownMenuItem(value: 'kos', child: Text('Kos')),
                DropdownMenuItem(value: 'makan', child: Text('Makan')),
                DropdownMenuItem(
                    value: 'ngopi', child: Text('Ngopi / Nongkrong')),
                DropdownMenuItem(value: 'hutang', child: Text('Hutang Teman')),
                DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isEditMode ? 'Simpan Perubahan' : 'Simpan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

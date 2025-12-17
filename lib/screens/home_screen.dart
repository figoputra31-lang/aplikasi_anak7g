import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  // ✅ callback untuk sinkron ke Hive / state di luar
  final void Function(TransactionModel transaction) onDelete;
  final void Function(TransactionModel transaction) onEdit;

  const HomeScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===== STATE FILTER =====
  String _selectedCategory = 'Semua';
  String _selectedDateFilter = 'Semua';

  final List<String> _categories = [
    'Semua',
    'kos',
    'makan',
    'ngopi',
    'hutang',
    'lainnya',
  ];

  final List<String> _dateFilters = [
    'Semua',
    'Hari ini',
    'Minggu ini',
    'Bulan ini',
  ];

  DateTime _parseDate(String text) {
    // format: dd-mm-yyyy
    final parts = text.split('-');
    if (parts.length != 3) {
      return DateTime.now(); // fallback kalau format weird
    }
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 2000;
    return DateTime(year, month, day);
  }

  List<TransactionModel> get _filteredTransactions {
    final now = DateTime.now();

    final filtered = widget.transactions.where((tx) {
      // filter kategori
      if (_selectedCategory != 'Semua' &&
          tx.category != _selectedCategory) {
        return false;
      }

      // filter tanggal
      if (_selectedDateFilter == 'Semua') return true;

      final txDate = _parseDate(tx.date);

      if (_selectedDateFilter == 'Hari ini') {
        return txDate.day == now.day &&
            txDate.month == now.month &&
            txDate.year == now.year;
      }

      if (_selectedDateFilter == 'Minggu ini') {
        final diff = now.difference(txDate).inDays;
        return diff >= 0 && diff <= 7;
      }

      if (_selectedDateFilter == 'Bulan ini') {
        return txDate.month == now.month && txDate.year == now.year;
      }

      return true;
    }).toList();

    // urutan terbaru di atas
    return filtered.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    // HITUNG TOTAL DARI SEMUA TRANSAKSI (tidak ikut filter)
    final int totalIncome = widget.transactions
        .where((t) => t.amount > 0)
        .fold(0, (sum, t) => sum + t.amount);

    final int totalExpense = widget.transactions
        .where((t) => t.amount < 0)
        .fold(0, (sum, t) => sum + t.amount.abs());

    final int balance = totalIncome - totalExpense;

    final List<TransactionModel> reversedFiltered =
        _filteredTransactions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAR ATAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.grid_view_rounded),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.notifications_none),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Home',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _BalanceCard(
              balance: balance,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Transaksi Anak Kos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ========= FILTER BAR =========
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat == 'Semua'
                              ? 'Semua Kategori'
                              : cat[0].toUpperCase() + cat.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDateFilter,
                    items: _dateFilters.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDateFilter = value;
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
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: reversedFiltered.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada transaksi untuk filter ini',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reversedFiltered.length,
                      itemBuilder: (context, index) {
                        final tx = reversedFiltered[index];

                        // ✅ WRAP DENGAN DISMISSIBLE UNTUK SWIPE EDIT / DELETE
                        return Dismissible(
                          key: ValueKey('tx_$index'),
                          // Geser kiri → kanan = EDIT
                          background: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Geser kanan → kiri = DELETE
                          secondaryBackground: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.delete_outline,
                                    color: Colors.red),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction ==
                                DismissDirection.startToEnd) {
                              // 👉 kiri → kanan = EDIT
                              widget.onEdit(tx);
                              // jangan beneran dihapus dari list, cuma buka edit
                              return false;
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              // 👉 kanan → kiri = DELETE
                              final bool? confirmed =
                                  await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title:
                                        const Text('Hapus Transaksi?'),
                                    content: Text(
                                        'Yakin mau hapus "${tx.title}" ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          'Hapus',
                                          style: TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed == true) {
                                widget.onDelete(
                                    tx); // sinkron ke Hive + state di luar
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Transaksi dihapus'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return true;
                              }
                              return false;
                            }
                            return false;
                          },
                          child: _TransactionItem(transaction: tx),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= KARTU SALDO =======

class _BalanceCard extends StatelessWidget {
  final int balance;
  final int totalIncome;
  final int totalExpense;

  const _BalanceCard({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  String _formatRupiah(int value) {
    // simpel: tanpa titik, yang penting terbaca
    return 'Rp $value';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFFFD79A8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Saldo Anak Kos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BalanceInfo(
                label: 'Pemasukan',
                amount: _formatRupiah(totalIncome),
                icon: Icons.arrow_downward,
              ),
              _BalanceInfo(
                label: 'Pengeluaran',
                amount: _formatRupiah(totalExpense),
                icon: Icons.arrow_upward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceInfo extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;

  const _BalanceInfo({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ======= ITEM TRANSAKSI =======

class _TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionItem({
    required this.transaction,
  });

  // ✅ ikon kategori otomatis
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'kos':
        return Icons.home_filled;
      case 'makan':
        return Icons.restaurant;
      case 'ngopi':
        return Icons.local_cafe_outlined;
      case 'hutang':
        return Icons.person_outline;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            child: Icon(_getIconForCategory(transaction.category)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  transaction.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            (isIncome ? '+ ' : '- ') + 'Rp ${transaction.amount.abs()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

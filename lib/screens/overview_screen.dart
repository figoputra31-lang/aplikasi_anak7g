import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class OverviewScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const OverviewScreen({
    super.key,
    required this.transactions,
  });

  DateTime _parseDate(String text) {
    // format: dd-mm-yyyy
    final parts = text.split('-');
    if (parts.length != 3) return DateTime.now();
    final d = int.tryParse(parts[0]) ?? 1;
    final m = int.tryParse(parts[1]) ?? 1;
    final y = int.tryParse(parts[2]) ?? 2000;
    return DateTime(y, m, d);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // ====== FILTER HANYA BULAN INI ======
    final monthTx = transactions.where((tx) {
      final dt = _parseDate(tx.date);
      return dt.month == now.month && dt.year == now.year;
    }).toList();

    // kalau belum ada data, jangan crash
    if (monthTx.isEmpty) {
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Belum ada data transaksi bulan ini.\n\nCoba tambahkan transaksi dulu ya ✨',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // ====== HITUNG RINGKASAN BULAN INI ======
    final int totalIncome = monthTx
        .where((t) => t.amount > 0)
        .fold(0, (sum, t) => sum + t.amount);

    final int totalExpense = monthTx
        .where((t) => t.amount < 0)
        .fold(0, (sum, t) => sum + t.amount.abs());

    final int balance = totalIncome - totalExpense;

    // ====== HITUNG PENGELUARAN PER KATEGORI ======
    final Map<String, int> expensePerCategory = {};
    for (final tx in monthTx) {
      if (tx.amount < 0) {
        expensePerCategory[tx.category] =
            (expensePerCategory[tx.category] ?? 0) + tx.amount.abs();
      }
    }

    // kalau tidak ada pengeluaran (cuma income), hindari error pie chart
    final bool hasExpense = expensePerCategory.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview Bulan Ini',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _MonthlySummaryCard(
              income: totalIncome,
              expense: totalExpense,
              balance: balance,
            ),

            const SizedBox(height: 24),

            // ====== PIE CHART PENGELUARAN ======
            const Text(
              'Pengeluaran per Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: hasExpense
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: _buildPieSections(expensePerCategory),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _CategoryLegend(
                            expensePerCategory: expensePerCategory,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Belum ada pengeluaran bulan ini 🎉',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            // ====== BAR INCOME VS EXPENSE ======
            const Text(
              'Pemasukan vs Pengeluaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          if (value.toInt() == 0) text = 'Income';
                          if (value.toInt() == 1) text = 'Expense';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalIncome.toDouble(),
                          width: 20,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalExpense.toDouble(),
                          width: 20,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========= PIE SECTIONS =========

  List<PieChartSectionData> _buildPieSections(
    Map<String, int> expensePerCategory,
  ) {
    final total = expensePerCategory.values.fold<int>(0, (s, v) => s + v);

    final List<Color> colors = const [
      Color(0xFF6C5CE7),
      Color(0xFFFD79A8),
      Color(0xFF00B894),
      Color(0xFFFFC312),
      Color(0xFF0984E3),
      Color(0xFFEA2027),
    ];

    int colorIndex = 0;

    return expensePerCategory.entries.map((entry) {
      final percent =
          total == 0 ? 0.0 : (entry.value / total * 100).toDouble();

      final section = PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percent.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        color: colors[colorIndex % colors.length],
      );

      colorIndex++;
      return section;
    }).toList();
  }
}

// ========= KARTU RINGKASAN =========

class _MonthlySummaryCard extends StatelessWidget {
  final int income;
  final int expense;
  final int balance;

  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  String _rp(int v) => 'Rp $v';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF6C5CE7)),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Bulan Ini',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Pemasukan',
                value: _rp(income),
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
              _SummaryItem(
                label: 'Pengeluaran',
                value: _rp(expense),
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
              _SummaryItem(
                label: 'Saldo',
                value: _rp(balance),
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF6C5CE7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ========= LEGEND KATEGORI =========

class _CategoryLegend extends StatelessWidget {
  final Map<String, int> expensePerCategory;

  const _CategoryLegend({
    required this.expensePerCategory,
  });

  String _labelKategori(String key) {
    switch (key) {
      case 'makan':
        return 'Makan';
      case 'kos':
        return 'Kos';
      case 'ngopi':
        return 'Ngopi / Nongkrong';
      case 'hutang':
        return 'Hutang Teman';
      case 'lainnya':
        return 'Lainnya';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = expensePerCategory.values.fold<int>(0, (s, v) => s + v);

    return ListView(
      children: expensePerCategory.entries.map((e) {
        final percent =
            total == 0 ? 0.0 : (e.value / total * 100).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(
                Icons.square,
                size: 14,
                color: Color(0xFF6C5CE7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _labelKategori(e.key),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                'Rp ${e.value}  ',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

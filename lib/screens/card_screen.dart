import 'package:flutter/material.dart';
import '../models/debt_model.dart';

class CardScreen extends StatelessWidget {
  final List<DebtModel> debts;
  final void Function(int index) onTogglePaid;

  const CardScreen({
    super.key,
    required this.debts,
    required this.onTogglePaid,
  });

  @override
  Widget build(BuildContext context) {
    // pisahkan jadi dua grup dengan index aslinya
    final Map<int, DebtModel> friendOwesMe = {};
    final Map<int, DebtModel> iOweFriend = {};

    for (int i = 0; i < debts.length; i++) {
      final d = debts[i];
      if (d.isOwedToMe) {
        friendOwesMe[i] = d;
      } else {
        iOweFriend[i] = d;
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kartu Hutang',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // TEMAN NGUTANG KE KAMU
              const Text(
                'Teman ngutang ke kamu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              if (friendOwesMe.isEmpty)
                const Text(
                  'Belum ada teman yang ngutang ke kamu.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                Column(
                  children: friendOwesMe.entries.map((entry) {
                    final idx = entry.key;
                    final debt = entry.value;
                    return _DebtItem(
                      debt: debt,
                      onTogglePaid: () => onTogglePaid(idx),
                      isOwedToMe: true,
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // KAMU NGUTANG KE TEMAN
              const Text(
                'Kamu ngutang ke teman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              if (iOweFriend.isEmpty)
                const Text(
                  'Belum ada hutang kamu ke teman.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                Column(
                  children: iOweFriend.entries.map((entry) {
                    final idx = entry.key;
                    final debt = entry.value;
                    return _DebtItem(
                      debt: debt,
                      onTogglePaid: () => onTogglePaid(idx),
                      isOwedToMe: false,
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebtItem extends StatelessWidget {
  final DebtModel debt;
  final VoidCallback onTogglePaid;
  final bool isOwedToMe; // true = mereka ngutang ke aku

  const _DebtItem({
    required this.debt,
    required this.onTogglePaid,
    required this.isOwedToMe,
  });

  @override
  Widget build(BuildContext context) {
    final color = debt.isPaid ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            isOwedToMe ? Icons.call_received : Icons.call_made,
          ),
        ),
        title: Text(debt.friendName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rp ${debt.amount}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (debt.note.isNotEmpty)
              Text(
                debt.note,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            Text(
              debt.date,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: onTogglePaid,
          child: Chip(
            label: Text(debt.isPaid ? 'Lunas' : 'Belum'),
            backgroundColor: color.withOpacity(0.1),
            labelStyle: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

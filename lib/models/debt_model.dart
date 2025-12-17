import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 2) // GANTI 2 kalau typeId kamu dulu beda
class DebtModel {
  @HiveField(0)
  final String friendName;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final String note;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final bool isPaid;

  /// true  = teman ngutang ke KAMU
  /// false = KAMU ngutang ke teman
  @HiveField(5)
  final bool isOwedToMe;

  DebtModel({
    required this.friendName,
    required this.amount,
    required this.note,
    required this.date,
    this.isPaid = false,
    required this.isOwedToMe,
  });

  DebtModel copyWith({
    String? friendName,
    int? amount,
    String? note,
    String? date,
    bool? isPaid,
    bool? isOwedToMe,
  }) {
    return DebtModel(
      friendName: friendName ?? this.friendName,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
      isOwedToMe: isOwedToMe ?? this.isOwedToMe,
    );
  }
}

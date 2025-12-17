import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final String category;

  TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
  });
}

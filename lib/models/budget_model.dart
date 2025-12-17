import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 4) // pastikan 4 belum dipakai model lain
class BudgetModel {
  @HiveField(0)
  final int totalAmount; // total uang yang harus cukup

  @HiveField(1)
  final DateTime startDate; // mulai dari kapan

  @HiveField(2)
  final DateTime endDate; // sampai kapan

  @HiveField(3)
  final bool isActive; // fitur pengingat aktif / tidak

  BudgetModel({
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  BudgetModel copyWith({
    int? totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return BudgetModel(
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

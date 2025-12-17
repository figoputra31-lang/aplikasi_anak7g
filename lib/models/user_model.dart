import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String? profileImagePath; // ⬅️ TAMBAHAN

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.profileImagePath,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? profileImagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

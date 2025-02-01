enum UserRole { regular, moderator, admin }

class UserModel {
  final String uid;
  final String username;
  final String phoneNumber;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.username,
    required this.phoneNumber,
    this.role = UserRole.regular,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'role': role.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      phoneNumber: map['phoneNumber'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == map['role'],
        orElse: () => UserRole.regular,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

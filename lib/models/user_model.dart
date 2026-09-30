class UserModel {
  final int id;
  final String email;
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}

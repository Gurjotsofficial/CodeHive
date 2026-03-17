class UserModel {
  final String id;
  final String name;
  final String email;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) { // what does this factory  do
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']).toString(),
    );
  }

}
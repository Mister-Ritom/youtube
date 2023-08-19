class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }
}

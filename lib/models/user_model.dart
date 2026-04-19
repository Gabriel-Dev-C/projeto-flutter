class User {
  final int? id;
  final String name;
  final String email;
  final String password;

  User(
      {this.id,
      required this.name,
      required this.email,
      required this.password});

  // Converte para Map (o SQL só entende Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Transforma o que vem do banco de volta em um objeto User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'] ?? '',
      password: map['password'],
    );
  }
}

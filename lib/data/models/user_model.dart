class User {
  final String id;
  final String name;
  final String email;
  final String currency;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? currency,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

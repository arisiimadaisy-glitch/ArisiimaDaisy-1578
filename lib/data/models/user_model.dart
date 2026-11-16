import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String id;
  final String name;
  final String email;
  final String currency;
  final DateTime createdAt;
  final String? profilePictureUrl;
  final String authProvider;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.createdAt,
    this.profilePictureUrl,
    this.authProvider = 'email',
    this.lastLogin,
  });

  /// Create User from Firebase User object
  factory User.fromFirebaseUser(
    firebase_auth.User fbUser,
    String authProvider,
  ) {
    return User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      name: fbUser.displayName ?? 'User',
      profilePictureUrl: fbUser.photoURL,
      authProvider: authProvider,
      currency: 'USD',
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'authProvider': authProvider,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String,
      currency: json['currency'] as String? ?? 'USD',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      authProvider: json['authProvider'] as String? ?? 'email',
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? currency,
    DateTime? createdAt,
    String? profilePictureUrl,
    String? authProvider,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      authProvider: authProvider ?? this.authProvider,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

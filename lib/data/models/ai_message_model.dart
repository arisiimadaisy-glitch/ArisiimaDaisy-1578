class AIMessage {
  final String id;
  final String userId;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  AIMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  AIMessage copyWith({
    String? id,
    String? userId,
    String? message,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return AIMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

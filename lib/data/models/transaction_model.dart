enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String description;
  final String? receiptPath;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.description,
    this.receiptPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'description': description,
      'receiptPath': receiptPath,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String,
      description: json['description'] as String,
      receiptPath: json['receiptPath'] as String?,
    );
  }

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? description,
    String? receiptPath,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }
}

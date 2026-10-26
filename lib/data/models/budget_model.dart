enum BudgetPeriod { weekly, monthly, custom }

class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final double limit;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.limit,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'limit': limit,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      limit: (json['limit'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Budget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? limit,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

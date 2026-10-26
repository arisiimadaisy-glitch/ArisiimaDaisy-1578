enum CategoryType { income, expense }

class Category {
  final String id;
  final String? userId;
  final String name;
  final CategoryType type;
  final String icon;
  final int color;
  final bool isDefault;

  Category({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      icon: json['icon'] as String,
      color: json['color'] as int,
      isDefault: json['isDefault'] as bool,
    );
  }

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    CategoryType? type,
    String? icon,
    int? color,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

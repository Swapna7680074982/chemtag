class Brand {
  final String id;
  final String name;
  final String category;
  final String description;

  Brand({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
      };
}

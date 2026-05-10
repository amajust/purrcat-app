class CatalogItem {
  final String id;
  final String name; // Practitioner Name, Room Type Name, Package Name
  final double price; // Price of the item (0 for Dokter)
  final String description; // Specialization, Facilities, Package Description/What's Included
  final Map<String, dynamic> extra; // Extra fields (sipNumber for Dokter, capacity for Pet Hotel, etc.)

  CatalogItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.extra = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'extra': extra,
    };
  }

  factory CatalogItem.fromMap(Map<String, dynamic> map) {
    return CatalogItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      extra: map['extra'] as Map<String, dynamic>? ?? const {},
    );
  }

  CatalogItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    Map<String, dynamic>? extra,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      extra: extra ?? this.extra,
    );
  }
}

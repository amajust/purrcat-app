enum ListingType { product, pet }

enum StatusBadge { vaccinated, premiumBreeder, healthCertified, topRated }

class MarketplaceItem {
  final String id;
  final ListingType type;
  final String name;
  final String breed; // e.g. "Maine Coon", "Persian"
  final int price;
  final String imageUrl;
  final String category; // "Kittens", "Toys", "Food", "Accessories"
  final String sellerName; // breeder or shop
  final double rating;
  final int reviewCount;
  final StatusBadge? statusBadge;
  final String? age; // "3 MONTHS OLD"
  final bool isFavorite;

  const MarketplaceItem({
    required this.id,
    this.type = ListingType.product,
    required this.name,
    required this.breed,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerName,
    required this.rating,
    required this.reviewCount,
    this.statusBadge,
    this.age,
    this.isFavorite = false,
  });

  MarketplaceItem copyWith({bool? isFavorite}) {
    return MarketplaceItem(
      id: id,
      type: type,
      name: name,
      breed: breed,
      price: price,
      imageUrl: imageUrl,
      category: category,
      sellerName: sellerName,
      rating: rating,
      reviewCount: reviewCount,
      statusBadge: statusBadge,
      age: age,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory MarketplaceItem.fromFirestore(String docId, Map<String, dynamic> data) {
    return MarketplaceItem(
      id: docId,
      type: data['type'] == 'pet' ? ListingType.pet : ListingType.product,
      name: (data['name'] as String?) ?? '',
      breed: (data['breed'] as String?) ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      imageUrl: (data['imageUrl'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'Toys',
      sellerName: (data['sellerName'] as String?) ?? 'Unknown',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      statusBadge: _parseStatusBadge(data['statusBadge']),
      age: data['age'] as String?,
    );
  }

  static StatusBadge? _parseStatusBadge(dynamic value) {
    if (value == null) return null;
    try {
      return StatusBadge.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}

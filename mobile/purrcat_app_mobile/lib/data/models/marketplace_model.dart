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
}

import 'package:flutter/material.dart';

import '../models/feed_model.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  // Mock data for demonstration
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Premium Cat Food',
      description: 'Makanan kucing berkualitas tinggi dengan nutrisi lengkap',
      price: 150000,
      imageUrl: '',
      category: 'Food',
      sellerId: 'seller1',
      sellerName: 'Pet Shop Jakarta',
      stock: 50,
      rating: 4.8,
      reviewCount: 124,
    ),
    Product(
      id: '2',
      name: 'Cat Scratching Post',
      description: 'Tempat garuk kucing dengan desain modern',
      price: 250000,
      imageUrl: '',
      category: 'Equipment',
      sellerId: 'seller2',
      sellerName: 'Cat Supplies Store',
      stock: 30,
      rating: 4.5,
      reviewCount: 89,
    ),
    Product(
      id: '3',
      name: 'Cat Litter Premium',
      description: 'Pasir kucing wangi dan mudah dibersihkan',
      price: 75000,
      imageUrl: '',
      category: 'Hygiene',
      sellerId: 'seller3',
      sellerName: 'Clean Pet Shop',
      stock: 100,
      rating: 4.7,
      reviewCount: 201,
    ),
    Product(
      id: '4',
      name: 'Cat Toy Set',
      description: 'Mainan kucing lucu untuk stimulasi bermain',
      price: 85000,
      imageUrl: '',
      category: 'Toys',
      sellerId: 'seller4',
      sellerName: 'Fun Pets',
      stock: 75,
      rating: 4.6,
      reviewCount: 156,
    ),
    Product(
      id: '5',
      name: 'Cat Bed Cozy',
      description: 'Tempat tidur kucing yang nyaman dan empuk',
      price: 180000,
      imageUrl: '',
      category: 'Equipment',
      sellerId: 'seller5',
      sellerName: 'Cozy Pets',
      stock: 25,
      rating: 4.9,
      reviewCount: 78,
    ),
    Product(
      id: '6',
      name: 'Vitamin Cat',
      description: 'Suplemen vitamin untuk kucing sehat',
      price: 120000,
      imageUrl: '',
      category: 'Health',
      sellerId: 'seller6',
      sellerName: 'Pet Health Store',
      stock: 60,
      rating: 4.4,
      reviewCount: 92,
    ),
  ];

  final List<String> _categories = [
    'All',
    'Food',
    'Equipment',
    'Hygiene',
    'Toys',
    'Health',
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo/Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFA03A57),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Marketplace',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Category Chips
          Container(
            height: 50,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFFA03A57),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          // Divider
          const Divider(height: 1, color: Colors.grey),
          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFA03A57),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA03A57).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add product
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(
                Icons.pets,
                size: 40,
                color: Color(0xFFA03A57),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Color(0xFFA03A57),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // Name
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount})',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Price
                Text(
                  'Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFA03A57),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

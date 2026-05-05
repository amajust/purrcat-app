import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../ui/core/theme.dart';
import '../../../../ui/shared/app_logo.dart';
import '../../../../data/models/marketplace_model.dart';
import '../../../../data/services/firestore_service.dart';
import '../../../../ui/shared/login_modal.dart';
import '../../../../ui/shared/report_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ═══════════════════════════════════════════════════════════════
// Mock data — cat-focused per spec
// ═══════════════════════════════════════════════════════════════

const List<CategoryFilter> _categoryFilters = [
  CategoryFilter(icon: Icons.grid_view_rounded, label: 'All'),
  CategoryFilter(icon: Icons.favorite_border, label: 'Favorites'),
  CategoryFilter(icon: Icons.pets, label: 'Kittens'),
  CategoryFilter(icon: Icons.toys, label: 'Toys'),
  CategoryFilter(icon: Icons.restaurant, label: 'Food'),
  CategoryFilter(icon: Icons.health_and_safety, label: 'Health'),
  CategoryFilter(icon: Icons.checkroom, label: 'Accessories'),
];

final List<MarketplaceItem> _mockItems = [
  MarketplaceItem(
    id: '1',
    type: ListingType.pet,
    name: 'Maine Coon',
    breed: 'Maine Coon',
    price: 4500000,
    imageUrl: 'https://images.unsplash.com/photo-1606214174585-fe31582dc6ee?w=400',
    category: 'Kittens',
    sellerName: 'Royal Kittens Manor',
    rating: 4.9,
    reviewCount: 87,
    statusBadge: StatusBadge.premiumBreeder,
    age: '3 MONTHS OLD',
  ),
  MarketplaceItem(
    id: '2',
    type: ListingType.product,
    name: 'Feather Wand Toy',
    breed: 'Toy',
    price: 45000,
    imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400',
    category: 'Toys',
    sellerName: 'PurrPlay Store',
    rating: 4.7,
    reviewCount: 234,
    statusBadge: StatusBadge.topRated,
  ),
  MarketplaceItem(
    id: '3',
    type: ListingType.pet,
    name: 'Persian Kitten',
    breed: 'Persian',
    price: 3800000,
    imageUrl: 'https://images.unsplash.com/photo-1571566882372-1598d88abd90?w=400',
    category: 'Kittens',
    sellerName: 'Persian Paradise',
    rating: 4.8,
    reviewCount: 56,
    statusBadge: StatusBadge.vaccinated,
    age: '2 MONTHS OLD',
  ),
  MarketplaceItem(
    id: '4',
    type: ListingType.product,
    name: 'Premium Salmon Treats',
    breed: 'Food',
    price: 85000,
    imageUrl: 'https://images.unsplash.com/photo-1583511655896-05754b09f52f?w=400',
    category: 'Food',
    sellerName: 'WhiskerBites Co.',
    rating: 4.6,
    reviewCount: 412,
  ),
  MarketplaceItem(
    id: '5',
    type: ListingType.pet,
    name: 'British Shorthair',
    breed: 'British Shorthair',
    price: 5200000,
    imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400',
    category: 'Kittens',
    sellerName: 'Blue Haven Cattery',
    rating: 4.9,
    reviewCount: 128,
    statusBadge: StatusBadge.premiumBreeder,
    age: '4 MONTHS OLD',
  ),
  MarketplaceItem(
    id: '6',
    type: ListingType.product,
    name: 'Catnip Mice Set',
    breed: 'Toy',
    price: 35000,
    imageUrl: 'https://images.unsplash.com/photo-1543852786-1cf6624b9987?w=400',
    category: 'Toys',
    sellerName: 'PurrPlay Store',
    rating: 4.5,
    reviewCount: 189,
  ),
  MarketplaceItem(
    id: '7',
    type: ListingType.product,
    name: 'Organic Catnip',
    breed: 'Health',
    price: 55000,
    imageUrl: 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=400',
    category: 'Health',
    sellerName: 'GreenPaw Naturals',
    rating: 4.8,
    reviewCount: 76,
    statusBadge: StatusBadge.healthCertified,
  ),
  MarketplaceItem(
    id: '8',
    type: ListingType.product,
    name: 'Cozy Cat Bed',
    breed: 'Accessory',
    price: 175000,
    imageUrl: 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400',
    category: 'Accessories',
    sellerName: 'SnugglePaws',
    rating: 4.6,
    reviewCount: 301,
  ),
];

// ═══════════════════════════════════════════════════════════════
// Models
// ═══════════════════════════════════════════════════════════════

class CategoryFilter {
  final IconData icon;
  final String label;
  const CategoryFilter({required this.icon, required this.label});
}

// ═══════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'All';
  List<MarketplaceItem> _allItems = [];
  List<MarketplaceItem> _filteredItems = [];
  Set<String> _favoriteIds = {};
  StreamSubscription<List<MarketplaceItem>>? _listingsSub;
  StreamSubscription<Set<String>>? _favSub;

  @override
  void initState() {
    super.initState();
    _allItems = List.from(_mockItems);
    _filteredItems = List.from(_mockItems);
    _listingsSub = FirestoreService()
        .getMarketplaceListings()
        .listen((firestoreItems) {
      if (!mounted) return;
      setState(() {
        final firestoreIds = firestoreItems.map((e) => e.id).toSet();
        final merged = [
          ...firestoreItems,
          ..._mockItems.where((m) => !firestoreIds.contains(m.id)),
        ];
        _allItems = merged;
        _applyFilter();
      });
    }, onError: (error) {
      debugPrint('Marketplace stream error (using mock data): $error');
    });

    // Subscribe to favorites
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _favSub = FirestoreService().getFavoriteIds(uid).listen((ids) {
        if (!mounted) return;
        setState(() => _favoriteIds = ids);
        _applyFilter();
      });
    }
  }

  @override
  void dispose() {
    _listingsSub?.cancel();
    _favSub?.cancel();
    super.dispose();
  }

  void _applyFilter() {
    if (_selectedCategory == 'All') {
      _filteredItems = List.from(_allItems);
    } else if (_selectedCategory == 'Favorites') {
      _filteredItems =
          _allItems.where((i) => _favoriteIds.contains(i.id)).toList();
    } else {
      _filteredItems =
          _allItems.where((i) => i.category == _selectedCategory).toList();
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilter();
    });
  }

  void _handleToggleFavorite(MarketplaceItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const LoginModal(),
      );
      return;
    }
    await FirestoreService().toggleMarketplaceFavorite(
      itemId: item.id,
      userId: user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildHeroBanner(),
          _buildCategoryChips(),
          _buildProductGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: scaffoldBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 4,
      title: const AppLogo(),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: headingColor, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: headingColor, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero Banner ──────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFF07E96), Color(0xFFE8547A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Cat image — right side, faded into gradient
              Positioned(
                right: -20,
                bottom: 0,
                child: Opacity(
                  opacity: 0.35,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=300',
                    width: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // Text content — left side
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 28, right: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUMMER COLLECTION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Premium Treats & Playtime Essentials',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // "Explore Now" button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Explore Now',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: brandPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Chips ───────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(top: 16, bottom: 4),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categoryFilters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = _categoryFilters[index];
            final isSelected = _selectedCategory == cat.label;
            return GestureDetector(
              onTap: () => _onCategorySelected(cat.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? brandPink : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : bodyColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : headingColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Product Grid ─────────────────────────────────────────────

  Widget _buildProductGrid() {
    if (_filteredItems.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No items in this category yet',
                  style: GoogleFonts.inter(
                      fontSize: 15, color: bodyColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ProductCard(
            item: _filteredItems[index],
            isFavorite: _favoriteIds.contains(_filteredItems[index].id),
            onToggleFavorite: () => _handleToggleFavorite(_filteredItems[index]),
          ),
          childCount: _filteredItems.length,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Product Card
// ═══════════════════════════════════════════════════════════════

class _ProductCard extends StatelessWidget {
  final MarketplaceItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ProductCard({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlays
          _buildImageSection(context),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main image
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(color: Colors.grey.shade300),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.pets, size: 32, color: brandPink.withOpacity(0.4)),
              ),
            ),
            // Report button — top left
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => showReportModal(
                  context,
                  itemId: item.id,
                  itemType: 'marketplace',
                  itemPreview: item.name,
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: bodyColor,
                  ),
                ),
              ),
            ),
            // Favorite button — top right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onToggleFavorite,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isFavorite ? brandPink : bodyColor,
                  ),
                ),
              ),
            ),
            // Status badge — bottom left
            if (item.statusBadge != null)
              Positioned(
                left: 0,
                bottom: 0,
                child: _buildStatusBadge(item.statusBadge!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StatusBadge badge) {
    final (color, label) = switch (badge) {
      StatusBadge.vaccinated =>
        (const Color(0xFF4CAF50), 'VACCINATED'),
      StatusBadge.premiumBreeder =>
        (const Color(0xFF8B2252), 'PREMIUM BREEDER'),
      StatusBadge.healthCertified =>
        (const Color(0xFF2196F3), 'HEALTH CERTIFIED'),
      StatusBadge.topRated =>
        (const Color(0xFFF57C00), 'TOP RATED'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final priceFmt = _formatPrice(item.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Price row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: headingColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              priceFmt,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: brandPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Breeder / shop name with verified check
        Row(
          children: [
            const Icon(Icons.verified, size: 14, color: Color(0xFF2196F3)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.sellerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: bodyColor,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),

        // Bottom row: star rating + age / health
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
            const SizedBox(width: 3),
            Text(
              item.rating.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: headingColor,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              '(${item.reviewCount})',
              style: GoogleFonts.inter(fontSize: 10, color: bodyColor),
            ),
            const Spacer(),
            if (item.age != null)
              Text(
                item.age!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: bodyColor,
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return 'Rp${(price / 1000000).toStringAsFixed(1)}M';
    }
    if (price >= 1000) {
      return 'Rp${(price / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp$price';
  }
}

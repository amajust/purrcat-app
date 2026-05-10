import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/providers/cat_providers.dart';
import '../../../../data/models/cat_model.dart';
import '../../../../ui/core/theme.dart';
import '../../../../ui/shared/post_card.dart';

class CatDetailScreen extends ConsumerWidget {
  final String catId;
  final String? ownerId;

  const CatDetailScreen({
    super.key,
    required this.catId,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(catDetailProvider(ownerId != null && ownerId!.isNotEmpty ? "$ownerId|$catId" : catId));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: catAsync.when(
        data: (cat) {
          if (cat == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Cat Not Found'),
                backgroundColor: backgroundColor,
                elevation: 0,
              ),
              body: const Center(
                child: Text('The requested cat record could not be found.'),
              ),
            );
          }
          return _buildCatDetailBody(context, ref, cat);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: brandPink),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            backgroundColor: backgroundColor,
            elevation: 0,
          ),
          body: Center(
            child: Text('Error loading cat: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Widget _buildCatDetailBody(BuildContext context, WidgetRef ref, CatModel cat) {
    final galleryImagesAsync = ref.watch(catGalleryImagesProvider(catId));
    final relatedPostsAsync = ref.watch(catRelatedPostsProvider(catId));

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Custom Slivers for beautiful parallax effect
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: backgroundColor,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: headingColor),
                  onPressed: () => context.pop(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Main Image
                    CachedNetworkImage(
                      imageUrl: cat.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error_outline, size: 40),
                      ),
                    ),
                    // Gradient Overlay
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black26,
                            Colors.transparent,
                            Colors.black54,
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Cat name and Breed inside flexible bar bottom
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                cat.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (cat.isPedigreeVerified) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Verified Pedigree',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            cat.breed,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Tiles Row
                    Row(
                      children: [
                        _buildInfoTile(
                          icon: Icons.transgender_rounded,
                          label: 'Gender',
                          value: cat.gender,
                          color: cat.gender.toLowerCase() == 'male' ? Colors.blue : Colors.pink,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoTile(
                          icon: Icons.cake_outlined,
                          label: 'Age',
                          value: cat.age,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoTile(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: cat.category,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description Section
                    if (cat.description.isNotEmpty) ...[
                      Text(
                        'About ${cat.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: bodyColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Lineage Tree
                    Row(
                      children: [
                        const Icon(Icons.hub_outlined, color: brandPink),
                        const SizedBox(width: 8),
                        Text(
                          'Silsilah (Lineage Tree)',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildParentCard(
                          label: 'SIRE (FATHER)',
                          name: cat.sireName,
                          parentId: cat.sireId,
                          icon: Icons.male_rounded,
                          color: Colors.blue,
                          context: context,
                        ),
                        const SizedBox(width: 12),
                        _buildParentCard(
                          label: 'DAM (MOTHER)',
                          name: cat.damName,
                          parentId: cat.damId,
                          icon: Icons.female_rounded,
                          color: Colors.pink,
                          context: context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorColor: brandPink,
                  labelColor: brandPink,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Gallery'),
                    Tab(text: 'Related Posts'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            // Gallery Tab
            galleryImagesAsync.isEmpty
                ? const Center(child: Text('No photos in gallery yet.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: galleryImagesAsync.length,
                    itemBuilder: (context, index) {
                      final imageUrl = galleryImagesAsync[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () => _showFullscreenImage(context, imageUrl),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),

            // Related Posts Tab
            relatedPostsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('No related posts featuring this cat.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: posts[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: brandPink)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCard({
    required String label,
    required String name,
    required String parentId,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final bool isClickable = parentId.isNotEmpty;
    return Expanded(
      child: GestureDetector(
        onTap: isClickable ? () => context.push('/cat-detail/$parentId') : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isClickable ? color.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isClickable ? color.withOpacity(0.3) : Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              if (isClickable) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'View Pedigree',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios, size: 8, color: color),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 6),
                Text(
                  'Not Registered',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

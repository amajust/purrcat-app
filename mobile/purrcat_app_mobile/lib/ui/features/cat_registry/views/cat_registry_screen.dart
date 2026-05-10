import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/cat_model.dart';
import '../../../core/theme.dart';

class CatRegistryScreen extends StatelessWidget {
  const CatRegistryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final catsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cats');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Cats Showcase',
          style: TextStyle(color: headingColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: headingColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: brandPink, size: 28),
            onPressed: () => context.push('/cats/add'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: catsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brandPink));
          }

          final docs = snapshot.data?.docs ?? [];
          final cats = docs.map((doc) => CatModel.fromFirestore(doc.id, doc.data())).toList();

          if (cats.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return _buildCatCard(context, cat, catsCollection);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: brandPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => context.push('/cats/add'),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brandPink.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: brandPink, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Showcase Your Cats!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: headingColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'Register your cats to create a pedigree portfolio, showcase them on your profile, and apply for certified pedigree badges.',
              textAlign: TextAlign.center,
              style: TextStyle(color: bodyColor, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/cats/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Cat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatCard(
    BuildContext context,
    CatModel cat,
    CollectionReference<Map<String, dynamic>> ref,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cat Profile Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: cat.imageUrl.isNotEmpty
                      ? Image.network(
                          cat.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackImage(),
                        )
                      : _buildFallbackImage(),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: headingColor,
                              ),
                            ),
                          ),
                          // Tier 3 Verified Pedigree Ribbon Badge!
                          if (cat.isPedigreeVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF0F5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF8BBD0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium, size: 14, color: Colors.pink[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pedigree',
                                    style: TextStyle(
                                      color: Colors.pink[400],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Pending cert',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.breed,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: brandPink, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${cat.age}',
                        style: const TextStyle(color: bodyColor, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: bodyColor.withOpacity(0.9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Toggle verified pedigree (Demo purposes)
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Verify Pedigree Certificate (Demo Toggle)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      activeColor: Colors.pink[400],
                      value: cat.isPedigreeVerified,
                      onChanged: (val) async {
                        await ref.doc(cat.id).update({'isPedigreeVerified': val});
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Registration'),
                        content: Text('Are you sure you want to delete ${cat.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.doc(cat.id).delete();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 80,
      height: 80,
      color: brandPink.withOpacity(0.1),
      child: const Icon(Icons.pets, color: brandPink, size: 32),
    );
  }
}

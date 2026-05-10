import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/view_models/auth_provider.dart';
import '../../../../data/models/cat_model.dart';
import '../../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    final userDocStream = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
    final catsStream = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('cats').snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() ?? {};
        final isVerified = userData['isVerified'] ?? false;
        final verificationType = userData['verificationType'];
        final businessName = userData['businessName'];
        final verificationStatus = userData['verificationStatus'] ?? 'none';

        // Override display name if verified cattery business name exists
        final displayName = (isVerified && verificationType == 'cattery' && businessName != null && businessName.toString().isNotEmpty)
            ? businessName.toString()
            : (userData['displayName'] ?? user.displayName ?? 'No Name');

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: headingColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar & Name Card
                _buildHeaderCard(user, displayName, isVerified, verificationType),
                const SizedBox(height: 24),

                // Verification Center Card Menu (Tiers 1 & 2 Badge Gate)
                _buildVerificationCard(context, verificationStatus, isVerified, verificationType),
                const SizedBox(height: 24),

                // My Cats Showcase (Tier 3 Pedigree Cat Portfolio)
                _buildCatsShowcaseSection(context, catsStream),
                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                  'Are you sure you want to sign out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await auth.logout();
                              if (context.mounted) {
                                context.go('/');
                              }
                            }
                          },
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      auth.isLoading ? 'Signing out...' : 'Sign Out',
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(dynamic user, String displayName, bool isVerified, dynamic verificationType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: brandPink,
            child: user.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user.photoURL!,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    _initials(displayName),
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified && verificationType == 'cattery') ...[
                const SizedBox(width: 6),
                const Tooltip(
                  message: 'Verified Cattery (Tier 2)',
                  child: Icon(Icons.stars, color: Color(0xFFFFB300), size: 20),
                ),
              ] else if (isVerified && verificationType == 'member') ...[
                const SizedBox(width: 6),
                const Tooltip(
                  message: 'Verified Member (Tier 1)',
                  child: Icon(Icons.verified, color: Color(0xFF2196F3), size: 20),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, String status, bool isVerified, dynamic type) {
    Color cardColor = Colors.white;
    Color iconBgColor = brandPink.withOpacity(0.08);
    Color iconColor = brandPink;
    IconData icon = Icons.shield_outlined;
    String statusText = 'Get Verified';
    String descText = 'Upload KTP or NIB license to unlock blue & gold trust badges.';

    if (isVerified) {
      if (type == 'cattery') {
        cardColor = const Color(0xFFFFFDF0);
        iconBgColor = const Color(0xFFFFB300).withOpacity(0.12);
        iconColor = const Color(0xFFFFB300);
        icon = Icons.stars;
        statusText = 'Tier 2 Cattery Badge Active';
        descText = 'Gold Verified Badge displayed publicly on cattery listings.';
      } else {
        cardColor = const Color(0xFFF0F7FF);
        iconBgColor = const Color(0xFF2196F3).withOpacity(0.12);
        iconColor = const Color(0xFF2196F3);
        icon = Icons.verified;
        statusText = 'Tier 1 Member Badge Active';
        descText = 'Blue Verified Badge displayed next to user name.';
      }
    } else if (status == 'pending') {
      cardColor = const Color(0xFFFFF9E6);
      iconBgColor = Colors.orange.withOpacity(0.12);
      iconColor = Colors.orange;
      icon = Icons.hourglass_empty;
      statusText = 'Verification Review Pending';
      descText = 'Our moderators are currently reviewing your documents.';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isVerified ? iconColor.withOpacity(0.3) : Colors.grey.shade200),
      ),
      color: cardColor,
      child: InkWell(
        onTap: () => context.push('/profile/verifications'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: headingColor),
                    ),
                    const SizedBox(height: 4),
                    Text(descText, style: const TextStyle(fontSize: 12, color: bodyColor)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatsShowcaseSection(BuildContext context, Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Cats Showcase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/cats'),
              child: const Row(
                children: [
                  Text('Manage', style: TextStyle(color: brandPink, fontWeight: FontWeight.bold)),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 16, color: brandPink),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: brandPink)));
            }

            final docs = snapshot.data?.docs ?? [];
            final cats = docs.map((doc) => CatModel.fromFirestore(doc.id, doc.data())).toList();

            if (cats.isEmpty) {
              return _buildCatsEmptyState(context);
            }

            return SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length + 1,
                itemBuilder: (context, index) {
                  if (index == cats.length) {
                    return _buildAddCatShortcut(context);
                  }

                  final cat = cats[index];
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: brandPink.withOpacity(0.08),
                              backgroundImage: cat.imageUrl.isNotEmpty ? NetworkImage(cat.imageUrl) : null,
                              child: cat.imageUrl.isEmpty ? const Icon(Icons.pets, color: brandPink, size: 24) : null,
                            ),
                            if (cat.isPedigreeVerified)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.verified, size: 14, color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: headingColor),
                        ),
                        Text(
                          cat.breed,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: bodyColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCatsEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: brandPink.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.pets, color: brandPink, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('No cats registered yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: headingColor)),
                  const SizedBox(height: 2),
                  Text('Showcase your registered pedigrees here.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/cats/add'),
              child: const Text('Add Cat', style: TextStyle(color: brandPink, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCatShortcut(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/cats/add'),
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[100],
              child: const Icon(Icons.add, color: Colors.grey, size: 28),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Cat',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: bodyColor),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

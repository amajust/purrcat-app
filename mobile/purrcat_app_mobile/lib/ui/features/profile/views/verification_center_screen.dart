import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../add_service/widgets/kyc_upload_card.dart';
import '../../../core/theme.dart';

class VerificationCenterScreen extends StatefulWidget {
  const VerificationCenterScreen({super.key});

  @override
  State<VerificationCenterScreen> createState() => _VerificationCenterScreenState();
}

class _VerificationCenterScreenState extends State<VerificationCenterScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String _selectedType = 'member'; // 'member' or 'cattery'
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _documentIdCtrl = TextEditingController();
  File? _selectedDocFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl.text = _user?.displayName ?? '';
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _documentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    if (_user == null) return;
    if (_selectedDocFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your identity or business document.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Upload document to private path in Firebase Storage
      final fileExtension = _selectedDocFile!.path.split('.').last;
      final storageRef = _storage.ref('private_verifications/${_user.uid}/document.$fileExtension');
      await storageRef.putFile(_selectedDocFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      // 2. Write verification request fields to user profile
      final userDoc = _firestore.collection('users').doc(_user.uid);
      await userDoc.set({
        'verificationStatus': 'pending',
        'verificationType': _selectedType,
        'businessName': _selectedType == 'cattery' ? _businessNameCtrl.text.trim() : null,
        'fullName': _selectedType == 'member' ? _fullNameCtrl.text.trim() : null,
        'documentId': _documentIdCtrl.text.trim(),
        'documentUrl': downloadUrl,
        'isVerified': false, // Requires approval (or demo approval)
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted successfully! Under review.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _instantApprove() async {
    if (_user == null) return;
    try {
      final userDoc = _firestore.collection('users').doc(_user.uid);
      final doc = await userDoc.get();
      final data = doc.data() ?? {};
      final type = data['verificationType'] ?? 'member';
      final bName = data['businessName'];

      await userDoc.set({
        'verificationStatus': 'approved',
        'isVerified': true,
        'displayName': type == 'cattery' && bName != null ? bName : _user.displayName,
      }, SetOptions(merge: true));

      // Also trigger a user display name change in Firebase Auth if needed
      if (type == 'cattery' && bName != null) {
        await _user.updateDisplayName(bName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Verification Instantly Approved! Badge unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approval Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _resetVerification() async {
    if (_user == null) return;
    try {
      await _firestore.collection('users').doc(_user.uid).set({
        'verificationStatus': 'none',
        'isVerified': false,
        'verificationType': null,
        'businessName': null,
        'fullName': null,
        'documentId': null,
        'documentUrl': null,
      }, SetOptions(merge: true));

      // Restore original name to Auth if cattery was cleared
      // (For simple demo purposes, we can restore from current auth user's display name or generic)
      
      if (mounted) {
        setState(() {
          _selectedDocFile = null;
          _documentIdCtrl.clear();
          _businessNameCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification reset successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Verification Center', style: TextStyle(color: headingColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: headingColor),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('users').doc(_user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brandPink));
          }

          final userData = snapshot.data?.data() ?? {};
          final status = userData['verificationStatus'] ?? 'none';
          final type = userData['verificationType'] ?? 'member';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(status, type, userData),
                const SizedBox(height: 24),

                if (status == 'none') ...[
                  _buildTypeSelector(),
                  const SizedBox(height: 24),
                  _buildForm(),
                ] else if (status == 'pending') ...[
                  _buildPendingActions(),
                ] else if (status == 'approved') ...[
                  _buildApprovedActions(type),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(String status, String type, Map<String, dynamic> userData) {
    Color cardColor;
    IconData icon;
    String title;
    String subtitle;

    if (status == 'approved') {
      cardColor = type == 'cattery' ? const Color(0xFFFFFDF0) : const Color(0xFFF0F7FF);
      icon = Icons.verified;
      title = type == 'cattery' ? 'Verified Cattery Listing' : 'Verified Member Account';
      subtitle = type == 'cattery'
          ? 'Gold Badge Active — Business Name overrides profile header.'
          : 'Blue Badge Active — Official breeder/owner verified status.';
    } else if (status == 'pending') {
      cardColor = const Color(0xFFFFF9E6);
      icon = Icons.hourglass_empty;
      title = 'Verification Under Review';
      subtitle = 'We are currently validating your identity document and details.';
    } else {
      cardColor = Colors.white;
      icon = Icons.shield_outlined;
      title = 'Account Verification';
      subtitle = 'Submit KYC verification to earn your trusted membership badge.';
    }

    final isGold = status == 'approved' && type == 'cattery';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGold
              ? const Color(0xFFFFE082)
              : (status == 'approved'
                  ? const Color(0xFFB3D7FF)
                  : (status == 'pending' ? const Color(0xFFFFE0B2) : Colors.grey[200]!)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGold
                  ? const Color(0xFFFFB300).withOpacity(0.12)
                  : (status == 'approved'
                      ? const Color(0xFF2196F3).withOpacity(0.12)
                      : (status == 'pending' ? Colors.orange.withOpacity(0.12) : brandPink.withOpacity(0.12))),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isGold
                  ? const Color(0xFFFFB300)
                  : (status == 'approved'
                      ? const Color(0xFF2196F3)
                      : (status == 'pending' ? Colors.orange : brandPink)),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: headingColor),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: bodyColor.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Verification Tier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'member';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedType == 'member' ? const Color(0xFFF0F7FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == 'member' ? const Color(0xFF2196F3) : Colors.grey[200]!,
                      width: _selectedType == 'member' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF2196F3), size: 28),
                      const SizedBox(height: 8),
                      const Text('Verified Member', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tier 1 • Blue Badge', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'cattery';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedType == 'cattery' ? const Color(0xFFFFFDF0) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == 'cattery' ? const Color(0xFFFFB300) : Colors.grey[200]!,
                      width: _selectedType == 'cattery' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFFFB300), size: 28),
                      const SizedBox(height: 8),
                      const Text('Verified Cattery', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tier 2 • Gold Badge', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    final isCattery = _selectedType == 'cattery';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCattery) ...[
            const Text('Business Display Name (Cattery Name)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _businessNameCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Royal Bengal Cattery',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Business name is required for Verified Catteries.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('NIB (Nomor Induk Berusaha)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _documentIdCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. NIB-12345678',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'NIB number is required.';
                }
                return null;
              },
            ),
          ] else ...[
            const Text('Full Legal Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter your full legal name',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Legal name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('KTP (ID Card Number)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _documentIdCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. 3201234567890001',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'KTP number is required.';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),

          KycUploadCard(
            title: isCattery ? 'Cattery License Document (NIB)' : 'Identity Card Document (KTP)',
            subtitle: isCattery
                ? 'Upload your business NIB document. EXIF metadata is stripped automatically.'
                : 'Upload a clear photo of your KTP card. EXIF metadata is stripped automatically.',
            initialFile: _selectedDocFile,
            onFileSelected: (file) {
              setState(() {
                _selectedDocFile = file;
              });
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCattery ? const Color(0xFFFFB300) : const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isUploading ? null : _submitVerification,
              child: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Your registration document is encrypted and has been securely uploaded to storage rules under private_verifications/ paths.',
            textAlign: TextAlign.center,
            style: TextStyle(color: bodyColor, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '✨ DEV & DEMO SHORTCUTS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _instantApprove,
            icon: const Icon(Icons.flash_on),
            label: const Text('Speed Up Review (Instant Approval)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _resetVerification,
            child: const Text('Cancel Request & Reset'),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedActions(String type) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: type == 'cattery' ? const Color(0xFFFFFDF0) : const Color(0xFFF0F7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == 'cattery' ? Icons.stars : Icons.verified,
              color: type == 'cattery' ? const Color(0xFFFFB300) : const Color(0xFF2196F3),
              size: 64,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          type == 'cattery'
              ? 'Gold Badged Cattery'
              : 'Blue Badged Breeder / Owner',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 48),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '🧪 DEV & TESTING UTILITIES',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.redAccent),
              foregroundColor: Colors.redAccent,
            ),
            onPressed: _resetVerification,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Verification Status to Test Again', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

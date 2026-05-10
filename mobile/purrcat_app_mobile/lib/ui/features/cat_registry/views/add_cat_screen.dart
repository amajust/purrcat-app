import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import '../../add_service/widgets/kyc_upload_card.dart';
import '../../../core/theme.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedGender = 'Male';
  final _categoryCtrl = TextEditingController();
  final _sireNameCtrl = TextEditingController();
  final _sireIdCtrl = TextEditingController();
  final _damNameCtrl = TextEditingController();
  final _damIdCtrl = TextEditingController();

  File? _profileImageFile;
  File? _pedigreeCertFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _sireNameCtrl.dispose();
    _sireIdCtrl.dispose();
    _damNameCtrl.dispose();
    _damIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_profileImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile photo for your cat.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final docId = FirebaseFirestore.instance.collection('dummy').doc().id;
      final storage = FirebaseStorage.instance;

      // 1. Upload profile image to Firebase Storage
      final profileRef = storage.ref('cats/${user.uid}/$docId/profile.jpg');
      await profileRef.putFile(_profileImageFile!);
      final imageUrl = await profileRef.getDownloadURL();

      // 2. Upload pedigree certificate if provided
      String pedigreeUrl = '';
      if (_pedigreeCertFile != null) {
        final certRef = storage.ref('cats/${user.uid}/$docId/pedigree.jpg');
        await certRef.putFile(_pedigreeCertFile!);
        pedigreeUrl = await certRef.getDownloadURL();
      }

      // 3. Save to Firestore under users/{uid}/cats and root 'cats' collection
      final catData = {
        'id': docId,
        'name': _nameCtrl.text.trim(),
        'breed': _breedCtrl.text.trim(),
        'age': _ageCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'imageUrl': imageUrl,
        'pedigreeCertUrl': pedigreeUrl,
        'isPedigreeVerified': false, // Initially unverified until admin approves
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'gender': _selectedGender,
        'category': _categoryCtrl.text.trim().isEmpty ? 'Pedigree' : _categoryCtrl.text.trim(),
        'sireId': _sireIdCtrl.text.trim(),
        'sireName': _sireNameCtrl.text.trim().isEmpty ? 'Unknown Sire' : _sireNameCtrl.text.trim(),
        'damId': _damIdCtrl.text.trim(),
        'damName': _damNameCtrl.text.trim().isEmpty ? 'Unknown Dam' : _damNameCtrl.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cats')
          .doc(docId)
          .set(catData);

      await FirebaseFirestore.instance
          .collection('cats')
          .doc(docId)
          .set(catData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cat registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save cat details: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Register New Cat',
          style: TextStyle(color: headingColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: headingColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cat profile photo
              KycUploadCard(
                title: 'Cat Profile Photo',
                subtitle: 'Choose a beautiful close-up of your pet.',
                initialFile: _profileImageFile,
                onFileSelected: (file) {
                  setState(() {
                    _profileImageFile = file;
                  });
                },
              ),
              const SizedBox(height: 24),

              const Text('Cat Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Luna',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Cat name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Breed', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _breedCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Bengal, British Shorthair',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Breed description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Age / Birthday', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. 1 Year 2 Months',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Age is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('About Luna (Description)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe their personality, color, patterns...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedGender = val;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Shorthair, Longhair, Premium Pedigree',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Lineage (Silsilah) Section Header
              const Text(
                'Lineage Information (Silsilah)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add parent details. Linking registered cat IDs will make them clickable in the Lineage tree!',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Sire (Father) Information
              const Text('Sire (Father) Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sireNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Grand Champion Romeo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Sire (Father) Cat ID (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sireIdCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter registered cat ID to link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Dam (Mother) Information
              const Text('Dam (Mother) Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _damNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Duchess Juliet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Dam (Mother) Cat ID (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _damIdCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter registered cat ID to link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Pedigree certificate upload (optional)
              KycUploadCard(
                title: 'Pedigree Certificate (Optional)',
                subtitle: 'Upload registration document to obtain Tier 3 badge.',
                initialFile: _pedigreeCertFile,
                onFileSelected: (file) {
                  setState(() {
                    _pedigreeCertFile = file;
                  });
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveCat,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Register Cat',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

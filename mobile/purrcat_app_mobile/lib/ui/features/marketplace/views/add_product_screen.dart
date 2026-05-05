import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/services/firestore_service.dart';
import '../../../../data/models/marketplace_model.dart';
import '../../../../ui/core/theme.dart';
import '../../../../ui/shared/login_modal.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _picker = ImagePicker();

  ListingType _type = ListingType.product;
  String _category = 'Toys';
  StatusBadge? _statusBadge;
  File? _image;
  bool _isSaving = false;

  static const _categories = ['Kittens', 'Toys', 'Food', 'Health', 'Accessories'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _priceCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final img = await _picker.pickImage(source: source);
    if (img != null && mounted) {
      setState(() => _image = File(img.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a product image')),
      );
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const LoginModal(),
      );
      return;
    }

    setState(() => _isSaving = true);

    final price = int.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final item = MarketplaceItem(
      id: '',
      type: _type,
      name: _nameCtrl.text.trim(),
      breed: _breedCtrl.text.trim(),
      price: price,
      imageUrl: '',
      category: _category,
      sellerName: FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown',
      rating: 0,
      reviewCount: 0,
      statusBadge: _statusBadge,
      age: _type == ListingType.pet ? _ageCtrl.text.trim() : null,
    );

    try {
      await FirestoreService().addMarketplaceListing(item: item, image: _image);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product listed successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text('Add Listing', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Picker ──────────────────────────
              _buildImagePicker(),
              const SizedBox(height: 24),

              // ── Listing Type ──────────────────────────
              _buildTypeToggle(),
              const SizedBox(height: 20),

              // ── Name ──────────────────────────────────
              _buildTextField(_nameCtrl, 'Product / Pet Name', Icons.pets),
              const SizedBox(height: 16),

              // ── Category ──────────────────────────────
              _buildCategoryDropdown(),
              const SizedBox(height: 16),

              // ── Breed ─────────────────────────────────
              _buildTextField(_breedCtrl, 'Breed (e.g. Maine Coon)', Icons.pets_outlined),
              const SizedBox(height: 16),

              // ── Price ─────────────────────────────────
              _buildTextField(
                _priceCtrl,
                'Price (Rp)',
                Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // ── Age (pet only) ────────────────────────
              if (_type == ListingType.pet) ...[
                _buildTextField(_ageCtrl, 'Age (e.g. 3 MONTHS OLD)', Icons.calendar_today),
                const SizedBox(height: 16),
              ],

              // ── Status Badge ──────────────────────────
              _buildStatusBadgeDropdown(),
              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'List Product',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Add product image',
                    style: GoogleFonts.inter(color: bodyColor, fontSize: 14),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Text('Listing Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        SegmentedButton<ListingType>(
          segments: const [
            ButtonSegment(value: ListingType.product, label: Text('Product'), icon: Icon(Icons.inventory_2, size: 16)),
            ButtonSegment(value: ListingType.pet, label: Text('Pet'), icon: Icon(Icons.pets, size: 16)),
          ],
          selected: {_type},
          onSelectionChanged: (v) => setState(() => _type = v.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((s) {
              if (s.contains(WidgetState.selected)) return brandPink;
              return Colors.white;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: bodyColor, fontSize: 14),
        prefixIcon: Icon(icon, color: bodyColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        hintText: 'Category',
        prefixIcon: const Icon(Icons.category, color: bodyColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _category = v);
      },
    );
  }

  Widget _buildStatusBadgeDropdown() {
    return DropdownButtonFormField<StatusBadge?>(
      value: _statusBadge,
      decoration: InputDecoration(
        hintText: 'Status Badge (optional)',
        prefixIcon: const Icon(Icons.verified, color: bodyColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('None')),
        DropdownMenuItem(value: StatusBadge.vaccinated, child: Text('Vaccinated')),
        DropdownMenuItem(value: StatusBadge.premiumBreeder, child: Text('Premium Breeder')),
        DropdownMenuItem(value: StatusBadge.healthCertified, child: Text('Health Certified')),
        DropdownMenuItem(value: StatusBadge.topRated, child: Text('Top Rated')),
      ],
      onChanged: (v) => setState(() => _statusBadge = v),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/services/firestore_service.dart';
import '../../../../data/models/feed_model.dart';
import '../../../../ui/core/theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final List<XFile> _images = [];
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;
  int _maxImages = 5;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMaxImages();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadMaxImages() async {
    final max = await FirestoreService().getMaxImagesPerPost();
    if (mounted) {
      setState(() => _maxImages = max);
    }
  }

  Future<void> _openCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      setState(() {
        _images.add(image);
        _selectedImageIndex = _images.length - 1;
      });
    }
  }

  Future<void> _openGallery() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty && mounted) {
      setState(() {
        final remaining = _maxImages - _images.length;
        final toAdd = images.take(remaining).toList();
        _images.addAll(toAdd);
        if (_images.isNotEmpty) {
          _selectedImageIndex = _images.length - 1;
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_selectedImageIndex >= _images.length) {
        _selectedImageIndex = _images.isNotEmpty ? _images.length - 1 : 0;
      }
    });
  }

  Future<void> _post() async {
    if (_images.isEmpty) return;
    setState(() => _isPosting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Must be authenticated to post');

      final post = Post(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userAvatar: user.photoURL ?? '',
        content: _captionController.text.trim(),
        createdAt: DateTime.now(),
      );

      final imageFiles = _images.map((x) => File(x.path)).toList();
      await FirestoreService().createPost(post: post, images: imageFiles);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_images.isNotEmpty)
            TextButton(
              onPressed: _isPosting ? null : _post,
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: brandPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
        ],
      ),
      body: _images.isEmpty ? _buildImagePicker() : _buildEditor(),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Take a photo or choose from gallery',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionChip(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: _openCamera,
              ),
              const SizedBox(width: 16),
              _ActionChip(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: _openGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        // Horizontal scrollable image strip
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _images.length + (_images.length < _maxImages ? 1 : 0),
            itemBuilder: (context, index) {
              // "Add more" button
              if (index == _images.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _openGallery,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: brandPink,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: brandPink,
                        size: 32,
                      ),
                    ),
                  ),
                );
              }

              // Thumbnail with remove overlay
              final isSelected = index == _selectedImageIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? brandPink
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_images[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // X button to remove
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Large preview of selected image
        if (_images.isNotEmpty && _selectedImageIndex < _images.length)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: DecorationImage(
                image: FileImage(File(_images[_selectedImageIndex].path)),
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Caption input
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _captionController,
            autofocus: true,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Write a caption...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: brandPink),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: brandPink,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

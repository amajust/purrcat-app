import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class CreatePostScreen extends StatefulWidget {
  /// Pass the image file to preview. If null, opens camera immediately.
  final XFile? initialImage;

  const CreatePostScreen({super.key, this.initialImage});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
    if (_image == null) {
      _openCamera();
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      setState(() => _image = image);
    } else if (mounted) {
      context.pop();
    }
  }

  Future<void> _openGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _image = image);
    }
  }

  Future<void> _post() async {
    if (_image == null) return;
    setState(() => _isPosting = true);

    // TODO: Upload image to Firebase Storage / Cloudflare R2
    // For now, just pass the data back
    final postData = {
      'imagePath': _image!.path,
      'caption': _captionController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() => _isPosting = false);
    if (mounted) {
      context.pop(postData);
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
          if (_image != null)
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
                        color: Color(0xFFA03A57),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
        ],
      ),
      body: _image == null
          ? _buildImagePicker()
          : _buildPreview(),
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

  Widget _buildPreview() {
    return Column(
      children: [
        // Image preview — full width, fixed height
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width, // square
          decoration: BoxDecoration(
            color: Colors.grey[200],
            image: DecorationImage(
              image: FileImage(File(_image!.path)),
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
                borderSide: BorderSide(color: Color(0xFFA03A57)),
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
          color: const Color(0xFFA03A57),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/theme.dart';

class KycUploadCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final File? initialFile;
  final ValueChanged<File> onFileSelected;

  const KycUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.initialFile,
    required this.onFileSelected,
  });

  @override
  State<KycUploadCard> createState() => _KycUploadCardState();
}

class _KycUploadCardState extends State<KycUploadCard> {
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedFile = file;
      });
      widget.onFileSelected(file);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: brandPink),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: brandPink),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(widget.subtitle, style: const TextStyle(color: bodyColor, fontSize: 14)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showPickerOptions,
          child: DottedBorder(
            color: brandPink,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              height: 140, // Increased height slightly for better proportions
              width: double.infinity,
              padding: const EdgeInsets.all(16), // Added padding
              decoration: BoxDecoration(
                color: brandPink.withValues(alpha: 0.05), // Lighter background
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedFile!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, color: brandPink, size: 48), // Refined icon
                        SizedBox(height: 12), // Adjusted vertical spacing
                        Text(
                          'Tap to upload',
                          style: TextStyle(
                            color: brandPink,
                            fontWeight: FontWeight.w600, // Slightly lighter weight
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

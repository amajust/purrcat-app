import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/services/firestore_service.dart';
import '../core/theme.dart';
import 'login_modal.dart';

/// Shared report bottom sheet for feed posts & marketplace listings.
///
/// Shows a list of predefined reasons + optional free-text description,
/// then writes to Firestore `reports` collection.
class ReportModal extends StatefulWidget {
  final String itemId;
  final String itemType; // 'feed' or 'marketplace'
  final String? itemPreview; // snippet for context (e.g. post content or item name)

  const ReportModal({
    super.key,
    required this.itemId,
    required this.itemType,
    this.itemPreview,
  });

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  static const _reasons = [
    'Spam or misleading',
    'Inappropriate content',
    'Scam or fraud',
    'Harassment or hate speech',
    'Fake listing / impersonation',
    'Other',
  ];

  String? _selectedReason;
  final _descController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Shouldn't happen — caller gates on auth.
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => _submitting = true);

    await FirestoreService().reportContent(
      itemId: widget.itemId,
      itemType: widget.itemType,
      reporterId: user.uid,
      reason: _selectedReason!,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      itemPreview: widget.itemPreview,
    );

    if (mounted) {
      setState(() => _submitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report submitted. Thank you.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: brandPink,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Report ${widget.itemType == 'feed' ? 'Post' : 'Listing'}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Let us know why you\'re reporting this content.',
            style: GoogleFonts.inter(fontSize: 14, color: bodyColor),
          ),

          if (widget.itemPreview != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.itemPreview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: headingColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Reason chips
          ...List.generate(_reasons.length, (i) {
            final reason = _reasons[i];
            final isSelected = _selectedReason == reason;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedReason = reason),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? brandPink.withValues(alpha: 0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? brandPink : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: isSelected ? brandPink : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        reason,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: headingColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Description field
          TextField(
            controller: _descController,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Additional details (optional)',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: brandPink),
              ),
              counterStyle: GoogleFonts.inter(fontSize: 11, color: bodyColor),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: headingColor),
          ),

          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedReason != null && !_submitting)
                  ? _submit
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Report',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Convenience function to show the report modal bottom sheet.
void showReportModal(
  BuildContext context, {
  required String itemId,
  required String itemType,
  String? itemPreview,
}) {
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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReportModal(
      itemId: itemId,
      itemType: itemType,
      itemPreview: itemPreview,
    ),
  );
}

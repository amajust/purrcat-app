import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/add_service_provider.dart';
import 'kyc_upload_card.dart';
import '../../../core/theme.dart';

class StepIdentity extends StatelessWidget {
  const StepIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddServiceProvider>();

    if (provider.isVerified) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('Identity Verified', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Your account is verified. You can proceed.', textAlign: TextAlign.center, style: TextStyle(color: bodyColor)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: brandPink,
              child: Text('1', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 12),
            Text('Identity & Entity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Business Display Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: provider.nameController,
          decoration: const InputDecoration(
            hintText: 'e.g. Dr. Paws Clinic',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Entity Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () => provider.setEntityType('individual'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'individual',
                    groupValue: provider.entityType,
                    onChanged: (value) => provider.setEntityType(value!),
                    activeColor: brandPink,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  const Text('Individual', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(width: 32),
            InkWell(
              onTap: () => provider.setEntityType('business'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'business',
                    groupValue: provider.entityType,
                    onChanged: (value) => provider.setEntityType(value!),
                    activeColor: brandPink,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  const Text('Business', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        KycUploadCard(
          title: 'Identity Document (KTP)',
          subtitle: 'Upload a clear photo of your ID card.',
          initialFile: provider.ktpFile,
          onFileSelected: provider.setKtpFile,
        ),
        if (provider.entityType == 'business') ...[
          const SizedBox(height: 24),
          KycUploadCard(
            title: 'Business License (NIB)',
            subtitle: 'Upload a clear photo of your business registration.',
            initialFile: provider.nibFile,
            onFileSelected: provider.setNibFile,
          ),
        ]
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/add_service_provider.dart';
import '../../../core/theme.dart';

class StepFinancials extends StatelessWidget {
  const StepFinancials({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddServiceProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('This account will be used to transfer your earnings.', style: TextStyle(color: bodyColor, fontSize: 12)),
        const SizedBox(height: 16),
        const Text('Bank Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: provider.bankNameController,
          decoration: const InputDecoration(
            hintText: 'e.g. BCA, Mandiri, BNI',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Account Number', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: provider.accountNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          'Must match your Business Display Name or KYC Name exactly.',
          style: TextStyle(color: brandPink, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: provider.accountHolderController,
          decoration: const InputDecoration(
            hintText: 'Name as it appears on the bank account',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border.all(color: Colors.amber.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Platform Fee Agreement', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Purrfect does not charge a subscription fee. Instead, a 5% platform fee is deducted from each successful transaction.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: provider.agreedToFee,
                onChanged: (val) => provider.setAgreedToFee(val ?? false),
                title: const Text('I agree to the 5% platform fee.'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: brandPink,
              )
            ],
          ),
        ),
      ],
    );
  }
}

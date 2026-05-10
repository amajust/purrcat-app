import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/add_service_provider.dart';
import '../widgets/step_identity.dart';
import '../widgets/step_service_info.dart';
import '../widgets/step_location.dart';
import '../widgets/step_availability.dart';
import '../widgets/step_financials.dart';
import '../../../core/theme.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddServiceProvider>(
      create: (_) => AddServiceProvider(),
      child: const _AddServiceBody(),
    );
  }
}

class _AddServiceBody extends StatelessWidget {
  const _AddServiceBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddServiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Service', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scaffoldBg,
      ),
      backgroundColor: scaffoldBg,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: brandPink))
          : Stepper(
              type: StepperType.vertical,
              currentStep: provider.currentStep,
              onStepContinue: provider.nextStep,
              onStepCancel: provider.previousStep,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(provider.currentStep == 4 ? 'Submit Listing' : 'Continue'),
                        ),
                      ),
                      if (provider.currentStep > 0) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: brandPink,
                              side: const BorderSide(color: brandPink),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Identity & Entity'),
                  content: const StepIdentity(),
                  isActive: provider.currentStep >= 0,
                  state: provider.currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Service Information'),
                  content: const StepServiceInfo(),
                  isActive: provider.currentStep >= 1,
                  state: provider.currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Location'),
                  content: const StepLocation(),
                  isActive: provider.currentStep >= 2,
                  state: provider.currentStep > 2 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Availability'),
                  content: const StepAvailability(),
                  isActive: provider.currentStep >= 3,
                  state: provider.currentStep > 3 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Financials'),
                  content: const StepFinancials(),
                  isActive: provider.currentStep >= 4,
                  state: provider.currentStep > 4 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
      bottomNavigationBar: provider.errorMessage != null
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}

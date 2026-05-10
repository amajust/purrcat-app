import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/add_service_provider.dart';

class StepAvailability extends StatelessWidget {
  const StepAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddServiceProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operating Hours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        ...provider.operatingHours.entries.map((entry) {
          final day = entry.key;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(day[0].toUpperCase() + day.substring(1)),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: entry.value['open'],
                    decoration: const InputDecoration(hintText: 'e.g. 09:00', isDense: true),
                    onChanged: (val) => provider.updateOperatingHour(day, 'open', val),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('-'),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: entry.value['close'],
                    decoration: const InputDecoration(hintText: 'e.g. 17:00', isDense: true),
                    onChanged: (val) => provider.updateOperatingHour(day, 'close', val),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        const Text('Slot Duration (Minutes)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: provider.slotDuration,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 15, child: Text('15 Minutes')),
            DropdownMenuItem(value: 30, child: Text('30 Minutes')),
            DropdownMenuItem(value: 60, child: Text('1 Hour')),
            DropdownMenuItem(value: 120, child: Text('2 Hours')),
          ],
          onChanged: (val) {
            if (val != null) provider.setSlotDuration(val);
          },
        ),
        const SizedBox(height: 16),
        const Text('Max Capacity per Slot', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: provider.maxCapacity.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (val) {
            final cap = int.tryParse(val);
            if (cap != null) provider.setMaxCapacity(cap);
          },
        ),
      ],
    );
  }
}

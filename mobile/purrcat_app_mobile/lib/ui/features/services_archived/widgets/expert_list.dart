import 'package:flutter/material.dart';
import '../../../../data/services/mock_services_data.dart';
import 'expert_card.dart';

class ExpertList extends StatelessWidget {
  const ExpertList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: mockExperts
          .map((expert) => ExpertCard(expert: expert))
          .toList(),
    );
  }
}

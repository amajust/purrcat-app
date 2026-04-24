import 'package:flutter_test/flutter_test.dart';

import 'package:purrcat_app_mobile/main.dart';

void main() {
  testWidgets('PurrCat App renders placeholder text', (WidgetTester tester) async {
    await tester.pumpWidget(const PurrCatApp());

    expect(find.text('PurrCat App'), findsOneWidget);
  });
}

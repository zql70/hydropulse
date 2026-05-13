import 'package:flutter_test/flutter_test.dart';
import 'package:hydropulse/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HydroPulseApp());
    expect(find.text('水动力'), findsOneWidget);
  });
}

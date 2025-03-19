import 'package:flutter_test/flutter_test.dart';
import 'package:livwell/main.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LivWellApp());
  });
}

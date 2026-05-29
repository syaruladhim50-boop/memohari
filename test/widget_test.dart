import 'package:flutter_test/flutter_test.dart';
import 'package:memohari/main.dart';

void main() {
  testWidgets('App starts and displays Genesis Notes splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MemoHariApp());

    // Verify that the splash screen text 'GENESIS' is displayed.
    expect(find.text('GENESIS'), findsOneWidget);

    // Allow the transition timer to fire and navigate to the main screen.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}

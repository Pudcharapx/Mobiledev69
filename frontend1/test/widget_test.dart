import 'package:flutter_test/flutter_test.dart';
import 'package:frontend1/main.dart';

void main() {
  testWidgets('shows the JWT sign-in screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Backend1App());
    expect(find.text('Frontend 1 · JWT'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

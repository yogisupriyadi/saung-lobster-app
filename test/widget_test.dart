import 'package:flutter_test/flutter_test.dart';
import 'package:saunglobster/main.dart';

void main() {
  testWidgets('Aplikasi SaungLobster berhasil dimuat',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SaungLobsterApp());
    expect(find.text('SAUNG LOBSTER'), findsOneWidget);
  });
}
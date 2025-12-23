import 'package:flutter_test/flutter_test.dart';

import 'package:first_app_flutter/main.dart';

void main() {
  testWidgets('Proverava osnovni tekst na ekranu', (WidgetTester tester) async {
    // Pokrećemo aplikaciju
    //await tester.pumpWidget(const MyApp());

    // Proveravamo da li se tekst prikazuje
    expect(find.text('Dobrodošla u First App Flutter!'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet/widgets/message_view.dart';

/// Test de widget : [MessageView] est le bloc "titre + explication + bouton"
/// des états vide et erreur. On le monte seul dans un MaterialApp, on lit les
/// textes affichés, puis on appuie sur le bouton pour vérifier le callback.
void main() {
  testWidgets('MessageView affiche ses textes et réagit au bouton', (
    tester,
  ) async {
    var appuis = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageView(
            title: 'Nothing saved yet.',
            message: 'Generate an itinerary and tap Save.',
            buttonLabel: 'Search a country',
            onPressed: () => appuis++,
          ),
        ),
      ),
    );

    expect(find.text('Nothing saved yet.'), findsOneWidget);
    expect(find.text('Generate an itinerary and tap Save.'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Search a country'));
    await tester.pump();

    expect(appuis, 1);
  });
}

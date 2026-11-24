// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cv_flutter_michee/main.dart';

void main() {
  testWidgets('L’application démarre sur la page de connexion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('Affiche les champs obligatoires', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Identifiant'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('L’identifiant est obligatoire.'), findsOneWidget);
    expect(find.text('Le mot de passe est obligatoire.'), findsOneWidget);
  });

  testWidgets('Refuse les identifiants incorrects', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'invalide');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrect');
    await tester.tap(find.text('Se connecter'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
    expect(find.text('Bienvenue'), findsOneWidget);
  });

  testWidgets('Redirige vers le CV avec les bons identifiants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'michee');
    await tester.enterText(find.byType(TextFormField).at(1), 'cv2026');
    await tester.tap(find.text('Se connecter'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Michee Luanda'), findsOneWidget);
  });
}

import 'dart:convert';

import 'package:cv_flutter_michee/core/api/api_service.dart';
import 'package:cv_flutter_michee/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

http.Response _jsonResponse(Map<String, dynamic> body, int statusCode) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  testWidgets('La connexion envoie les identifiants à l’API', (
    WidgetTester tester,
  ) async {
    http.Request? sentRequest;
    await tester.pumpWidget(
      MyApp(
        apiService: ApiService(
          client: MockClient((request) async {
            sentRequest = request;
            return _jsonResponse({
              'success': true,
              'message': 'Connexion réussie',
            }, 200);
          }),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(sentRequest?.method, 'POST');
    expect(sentRequest?.url.path, endsWith('/accounts/login'));
    expect(jsonDecode(sentRequest!.body), {
      'email': 'user@example.com',
      'password': 'secret',
    });
    expect(find.text('Michee Luanda'), findsOneWidget);
  });

  testWidgets('Refuse un login rejeté par l’API', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        apiService: ApiService(
          client: MockClient(
            (_) async => _jsonResponse({
              'success': false,
              'message': 'Unauthorized',
            }, 401),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrect');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(
      find.text('Adresse e-mail ou mot de passe incorrect.'),
      findsOneWidget,
    );
    expect(find.text('Michee Luanda'), findsNothing);
  });

  testWidgets('Crée un compte via l’endpoint d’inscription', (
    WidgetTester tester,
  ) async {
    http.Request? sentRequest;
    await tester.pumpWidget(
      MyApp(
        apiService: ApiService(
          client: MockClient((request) async {
            sentRequest = request;
            return _jsonResponse({
              'success': true,
              'message': 'Compte créé',
            }, 201);
          }),
        ),
      ),
    );

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(sentRequest?.method, 'POST');
    expect(sentRequest?.url.path, endsWith('/accounts/register'));
    expect(
      find.text('Compte créé. Vous pouvez maintenant vous connecter.'),
      findsOneWidget,
    );
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('Affiche les erreurs de connexion au serveur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        apiService: ApiService(
          client: MockClient((_) async {
            throw http.ClientException('offline');
          }),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de joindre le serveur : offline'),
      findsOneWidget,
    );
    expect(find.text('Michee Luanda'), findsNothing);
  });

  testWidgets('La déconnexion revient à la page de connexion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        apiService: ApiService(
          client: MockClient(
            (_) async => _jsonResponse({'success': true}, 200),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}

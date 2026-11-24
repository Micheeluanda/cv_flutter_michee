import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_flutter_michee/core/api/api_service.dart';
import 'package:cv_flutter_michee/features/family/family_page.dart';
import 'package:cv_flutter_michee/features/family/family_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

typedef _RequestHandler = Future<http.Response> Function(
  http.BaseRequest request,
  List<int> body,
);

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this.handler);

  final _RequestHandler handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().toBytes();
    final response = await handler(request, body);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

http.Response _jsonResponse(Map<String, dynamic> body, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

String _header(http.BaseRequest request, String name) {
  return request.headers.entries
      .firstWhere((entry) => entry.key.toLowerCase() == name.toLowerCase())
      .value;
}

bool _containsBytes(List<int> bytes, List<int> sequence) {
  for (var start = 0; start <= bytes.length - sequence.length; start++) {
    var matches = true;
    for (var offset = 0; offset < sequence.length; offset++) {
      if (bytes[start + offset] != sequence[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}

Map<String, dynamic> _memberJson() => {
  'id': 7,
  'nom': 'Mubogo',
  'postnom': 'Riziki',
  'prenom': 'Riziki',
  'lieu_naissance': 'Goma',
  'date_naissance': '1998-05-12',
  'parente': 'Mère',
  'image_url': '',
};

Map<String, String> _fields() => {
  'nom': 'Mubogo',
  'postnom': 'Riziki',
  'prenom': 'Riziki',
  'lieu_naissance': 'Goma',
  'date_naissance': '1998-05-12',
  'parente': 'Mère',
};

void main() {
  test(
    'Charge et convertit la collection depuis GET /famille-membres',
    () async {
      final repository = FamilyRepository(
        apiService: ApiService(
          client: _RecordingClient((request, _) async {
            expect(request.method, 'GET');
            expect(request.url.path, endsWith('/famille-membres'));
            return _jsonResponse({
              'success': true,
              'data': [_memberJson()],
            });
          }),
        ),
      );

      final members = await repository.fetchMembers();

      expect(members, hasLength(1));
      expect(members.single.id, 7);
      expect(members.single.lieuNaissance, 'Goma');
      expect(members.single.imageUrl, '');
    },
  );

  test('Charge un membre par son identifiant', () async {
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient((request, _) async {
          expect(request.method, 'GET');
          expect(request.url.path, endsWith('/famille-membres/7'));
          return _jsonResponse({'success': true, 'data': _memberJson()});
        }),
      ),
    );

    expect((await repository.fetchMember(7)).parente, 'Mère');
  });

  test('Crée un membre en JSON sans photo', () async {
    final fields = _fields();
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient((request, body) async {
          expect(request.method, 'POST');
          expect(request.url.path, endsWith('/famille-membres'));
          expect(
            _header(request, 'content-type'),
            contains('application/json'),
          );
          expect(jsonDecode(utf8.decode(body)), fields);
          return _jsonResponse({'success': true});
        }),
      ),
    );

    await repository.createMember(fields);
  });

  test('Crée un membre avec une photo multipart', () async {
    final fields = _fields();
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient((request, body) async {
          expect(request, isA<http.MultipartRequest>());
          expect(request.method, 'POST');
          expect(request.url.path, endsWith('/famille-membres'));
          expect(
            _header(request, 'content-type'),
            contains('multipart/form-data'),
          );
          final bodyText = String.fromCharCodes(body);
          expect(bodyText, contains('name="image"; filename="portrait.jpg"'));
          for (final entry in fields.entries) {
            expect(bodyText, contains('name="${entry.key}"'));
            expect(_containsBytes(body, utf8.encode(entry.value)), isTrue);
          }
          return _jsonResponse({'success': true});
        }),
      ),
    );

    await repository.createMember(
      fields,
      photoBytes: Uint8List.fromList([1, 2, 3]),
      photoName: 'portrait.jpg',
    );
  });

  test('Modifie un membre en JSON avec PUT sans photo', () async {
    final fields = _fields();
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient((request, body) async {
          expect(request.method, 'PUT');
          expect(request.url.path, endsWith('/famille-membres/7'));
          expect(jsonDecode(utf8.decode(body)), fields);
          return _jsonResponse({'success': true});
        }),
      ),
    );

    await repository.updateMember(7, fields);
  });

  test('Modifie un membre avec POST multipart si la photo change', () async {
    final fields = _fields();
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient((request, body) async {
          expect(request, isA<http.MultipartRequest>());
          expect(request.method, 'POST');
          expect(request.url.path, endsWith('/famille-membres/7'));
          expect(
            String.fromCharCodes(body),
            contains('name="image"; filename="updated.jpg"'),
          );
          return _jsonResponse({'success': true});
        }),
      ),
    );

    await repository.updateMember(
      7,
      fields,
      photoBytes: Uint8List.fromList([4, 5, 6]),
      photoName: 'updated.jpg',
    );
  });

  test('Supprime un membre via DELETE', () async {
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient((request, _) async {
          expect(request.method, 'DELETE');
          expect(request.url.path, endsWith('/famille-membres/7'));
          return _jsonResponse({'success': true});
        }),
      ),
    );

    await repository.deleteMember(7);
  });

  testWidgets('Affiche les membres reçus depuis l’API', (tester) async {
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient(
          (_, _) async => _jsonResponse({
            'success': true,
            'data': [_memberJson()],
          }),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: FamilyPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riziki Riziki Mubogo'), findsOneWidget);
    expect(find.text('Nom :'), findsOneWidget);
    expect(find.text('Mubogo'), findsOneWidget);
    expect(find.text('Postnom :'), findsOneWidget);
    expect(find.text('Prénom :'), findsOneWidget);
    expect(find.text('Date de naissance :'), findsOneWidget);
    expect(find.text('Lieu de naissance :'), findsOneWidget);
    expect(find.text('12/05/1998'), findsOneWidget);
    expect(find.text('Ajouter un membre'), findsOneWidget);
  });

  testWidgets('Affiche un état vide sans membres', (tester) async {
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient(
          (_, _) async => _jsonResponse({'success': true, 'data': []}),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: FamilyPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun membre enregistré'), findsOneWidget);
    expect(find.text('Ajouter un membre'), findsOneWidget);
  });

  testWidgets('Valide les champs obligatoires du formulaire', (tester) async {
    final repository = FamilyRepository(
      apiService: ApiService(
        client: _RecordingClient(
          (_, _) async => _jsonResponse({'success': true, 'data': []}),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: FamilyPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter').last);
    await tester.pumpAndSettle();

    expect(find.text('Ce champ est obligatoire.'), findsNWidgets(6));
  });
}

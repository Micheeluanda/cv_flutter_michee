import 'dart:typed_data';

import '../../core/api/api_exception.dart';
import '../../core/api/api_service.dart';
import '../../models/famille_membre.dart';

class FamilyRepository {
  FamilyRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Uri resolveImageUrl(String imageUrl) {
    final parsed = Uri.tryParse(imageUrl);
    if (parsed == null) {
      throw ApiException('Adresse de photo invalide reçue du serveur.');
    }
    final apiUrl = _apiService.uri('');
    if (parsed.hasScheme) {
      if ((parsed.host == 'localhost' || parsed.host == '127.0.0.1') &&
          apiUrl.host == '10.0.2.2') {
        return parsed.replace(host: apiUrl.host);
      }
      return parsed;
    }
    if (parsed.hasAuthority) return parsed.replace(scheme: apiUrl.scheme);
    return _apiService.uri(imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
  }

  Future<List<FamilleMembre>> fetchMembers() async {
    final response = await _apiService.get('/famille-membres');
    final data = response['data'];
    final members = data is List
        ? data
        : data is Map && data['data'] is List
        ? data['data'] as List
        : null;

    if (members == null) {
      throw ApiException('Format de la liste des membres invalide.');
    }

    return members.map(_memberFromJson).toList(growable: false);
  }

  Future<FamilleMembre> fetchMember(int id) async {
    final response = await _apiService.get('/famille-membres/$id');
    var data = response['data'];
    if (data is Map && data['data'] is Map) {
      data = data['data'];
    }
    return _memberFromJson(data);
  }

  Future<void> createMember(
    Map<String, String> fields, {
    Uint8List? photoBytes,
    String? photoName,
  }) async {
    if (photoBytes != null || photoName != null) {
      if (photoBytes == null || photoName == null) {
        throw ArgumentError('Les données et le nom de la photo sont requis.');
      }
      await _apiService.postMultipart(
        '/famille-membres',
        fields: fields,
        fileBytes: photoBytes,
        fileName: photoName,
      );
      return;
    }
    await _apiService.postJson('/famille-membres', fields);
  }

  Future<void> updateMember(
    int id,
    Map<String, String> fields, {
    Uint8List? photoBytes,
    String? photoName,
  }) async {
    if (photoBytes != null || photoName != null) {
      if (photoBytes == null || photoName == null) {
        throw ArgumentError('Les données et le nom de la photo sont requis.');
      }
      await _apiService.postMultipart(
        '/famille-membres/$id',
        fields: fields,
        fileBytes: photoBytes,
        fileName: photoName,
      );
      return;
    }
    await _apiService.putJson('/famille-membres/$id', fields);
  }

  Future<void> deleteMember(int id) async {
    await _apiService.delete('/famille-membres/$id');
  }

  FamilleMembre _memberFromJson(dynamic value) {
    if (value is! Map) {
      throw ApiException('Données de membre invalides reçues du serveur.');
    }
    final json = Map<String, dynamic>.from(value);
    final id = int.tryParse(json['id']?.toString() ?? '');
    if (id == null || id < 1) {
      throw ApiException('Identifiant de membre invalide reçu du serveur.');
    }
    return FamilleMembre.fromJson(json);
  }
}

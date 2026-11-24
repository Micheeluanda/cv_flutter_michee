import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _client.get(
        uri(path),
        headers: const {'Accept': 'application/json'},
      );
      return _decodeResponse(response);
    } on http.ClientException catch (error) {
      throw ApiException('Impossible de joindre le serveur : ${error.message}');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Erreur réseau inattendue.');
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
        uri(path),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    } on http.ClientException catch (error) {
      throw ApiException('Impossible de joindre le serveur : ${error.message}');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Erreur réseau inattendue.');
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.put(
        uri(path),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    } on http.ClientException catch (error) {
      throw ApiException('Impossible de joindre le serveur : ${error.message}');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Erreur réseau inattendue.');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required Uint8List fileBytes,
    required String fileName,
    String fileField = 'image',
  }) async {
    try {
      final request = http.MultipartRequest('POST', uri(path))
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(fields)
        ..files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
          ),
        );
      final streamedResponse = await _client.send(request);
      return _decodeResponse(await http.Response.fromStream(streamedResponse));
    } on http.ClientException catch (error) {
      throw ApiException('Impossible de joindre le serveur : ${error.message}');
    } on ApiException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _client.delete(
        uri(path),
        headers: const {'Accept': 'application/json'},
      );
      return _decodeResponse(response);
    } on http.ClientException catch (error) {
      throw ApiException('Impossible de joindre le serveur : ${error.message}');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Erreur réseau inattendue.');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Réponse invalide reçue du serveur.',
        statusCode: response.statusCode,
      );
    }

    final success = decoded['success'] == true;
    if (success && (response.statusCode >= 200 && response.statusCode < 300)) {
      return decoded;
    }

    final rawErrors = decoded['errors'];
    final errors = rawErrors is Map
        ? Map<String, dynamic>.from(rawErrors)
        : <String, dynamic>{};

    throw ApiException(
      decoded['message']?.toString() ?? 'La requête a échoué.',
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  void close() => _client.close();
}

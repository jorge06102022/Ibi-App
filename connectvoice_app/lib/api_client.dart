import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl; // ej: http://192.168.1.10:8000  (sin / final)

  ApiClient(String rawBaseUrl)
      : baseUrl = rawBaseUrl.endsWith('/')
            ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
            : rawBaseUrl;

  String get wsBaseUrl {
    if (baseUrl.startsWith('https://')) {
      return 'wss://${baseUrl.substring(8)}';
    }
    return 'ws://${baseUrl.substring(7)}';
  }

  Future<List<Room>> getRooms() async {
    final r = await http.get(Uri.parse('$baseUrl/api/rooms/'))
        .timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) throw ApiException('No se pudo cargar salas (${r.statusCode})');
    final data = jsonDecode(utf8.decode(r.bodyBytes));
    return (data['rooms'] as List).map((e) => Room.fromJson(e)).toList();
  }

  Future<Room> createRoom(String name) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/rooms/create/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    ).timeout(const Duration(seconds: 10));
    final data = jsonDecode(utf8.decode(r.bodyBytes));
    if (data['ok'] != true) throw ApiException(data['error'] ?? 'Error al crear sala');
    return Room(slug: data['slug'], displayName: data['display_name'], messageCount: 0, lastActivity: '');
  }

  Future<void> deleteRoom(String slug) async {
    final r = await http.post(Uri.parse('$baseUrl/api/rooms/$slug/delete/'))
        .timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) throw ApiException('No se pudo eliminar la sala');
  }

  Future<void> clearRoom(String slug) async {
    await http.post(Uri.parse('$baseUrl/api/rooms/$slug/clear/'))
        .timeout(const Duration(seconds: 10));
  }

  Future<List<ChatMessage>> getMessages(String slug, {String? sessionId}) async {
    final r = await http.get(Uri.parse('$baseUrl/api/rooms/$slug/messages/'))
        .timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) throw ApiException('No se pudo cargar el historial');
    final data = jsonDecode(utf8.decode(r.bodyBytes));
    return (data['messages'] as List)
        .map((m) => ChatMessage(
              senderName: m['sender_name'],
              senderColor: m['sender_color'],
              content: m['content'],
              messageType: m['message_type'],
              timestamp: m['timestamp'],
            ))
        .toList();
  }
}

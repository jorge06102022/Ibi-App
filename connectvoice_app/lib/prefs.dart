import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Prefs {
  static const _kServerUrl = 'server_url';
  static const _kName = 'sender_name';
  static const _kColor = 'sender_color';
  static const _kSessionId = 'session_id';
  static const _kVoiceGender = 'voice_gender';
  static const _kVoiceSpeed = 'voice_speed';
  static const _kVoiceVolume = 'voice_volume';
  static const _kSignMode = 'sign_mode';

  static const colors = [
    '#00D4FF', '#7C3AED', '#10B981', '#F59E0B',
    '#EF4444', '#EC4899', '#3B82F6', '#F97316',
  ];

  final SharedPreferences _p;
  Prefs._(this._p);

  static Future<Prefs> load() async => Prefs._(await SharedPreferences.getInstance());

  String? get serverUrl => _p.getString(_kServerUrl);
  Future<void> setServerUrl(String v) => _p.setString(_kServerUrl, v);
  Future<void> clearServerUrl() => _p.remove(_kServerUrl);

  String get senderName => _p.getString(_kName) ?? 'Anónimo';
  Future<void> setSenderName(String v) => _p.setString(_kName, v);

  String get senderColor => _p.getString(_kColor) ?? colors[0];
  Future<void> setSenderColor(String v) => _p.setString(_kColor, v);

  String get sessionId {
    var id = _p.getString(_kSessionId);
    if (id == null) {
      id = const Uuid().v4();
      _p.setString(_kSessionId, id);
    }
    return id;
  }

  String get voiceGender => _p.getString(_kVoiceGender) ?? 'female';
  Future<void> setVoiceGender(String v) => _p.setString(_kVoiceGender, v);

  double get voiceSpeed => _p.getDouble(_kVoiceSpeed) ?? 1.0;
  Future<void> setVoiceSpeed(double v) => _p.setDouble(_kVoiceSpeed, v);

  double get voiceVolume => _p.getDouble(_kVoiceVolume) ?? 1.0;
  Future<void> setVoiceVolume(double v) => _p.setDouble(_kVoiceVolume, v);

  bool get signMode => _p.getBool(_kSignMode) ?? false;
  Future<void> setSignMode(bool v) => _p.setBool(_kSignMode, v);
}

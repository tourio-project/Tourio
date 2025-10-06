
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Change this ONLY if you move the FastAPI port.
/// iOS Simulator can hit your Mac on 127.0.0.1.
const String _recBase = 'http://127.0.0.1:8130';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Shape of the preferences your backend expects at /recommend
class AiPrefs {
  final List<String> moods;
  final int budget; // total trip budget in JD
  final List<String> interests;
  final int days;
  final int options; // suggestions per day
  final String? city;

  AiPrefs({
    required this.moods,
    required this.budget,
    required this.interests,
    required this.days,
    required this.options,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'moods': moods,
        'budget': budget,
        'interests': interests,
        'days': days,
        'options': options,
      };
}

/// Generic JSON type alias
typedef Json = Map<String, dynamic>;

/// Parsed response from /recommend
class RecommendationResponse {
  final List<List<Json>> rec;
  final String? weatherUsed;

  RecommendationResponse({required this.rec, this.weatherUsed});

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['rec'] as List? ?? const [];
    final list = <List<Json>>[];
    for (final day in raw) {
      final items = <Json>[];
      for (final item in (day as List? ?? const [])) {
        items.add(Map<String, dynamic>.from(item as Map));
      }
      list.add(items);
    }
    return RecommendationResponse(
      rec: list,
      weatherUsed: json['weather_used'] as String?,
    );
  }
}

class ApiService {
  static const _timeout = Duration(seconds: 20);

  static Uri _u(String path) => Uri.parse('$_recBase$path');

  /// Quick health check
  static Future<bool> ping() async {
    final r = await http.get(_u('/ping')).timeout(_timeout);
    return r.statusCode == 200;
  }

  /// Call FastAPI recommender
  static Future<RecommendationResponse> getRecommendations(
      AiPrefs prefs) async {
    final r = await http
        .post(
          _u('/recommend'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(prefs.toJson()),
        )
        .timeout(_timeout);

    if (r.statusCode != 200) {
      // surface backend error message if present
      try {
        final body = jsonDecode(r.body);
        final detail =
            body is Map ? (body['detail']?.toString() ?? r.body) : r.body;
        throw ApiException(detail, statusCode: r.statusCode);
      } catch (_) {
        throw ApiException('HTTP ${r.statusCode}: ${r.body}',
            statusCode: r.statusCode);
      }
    }

    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return RecommendationResponse.fromJson(data);
  }
}

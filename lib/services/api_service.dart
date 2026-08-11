import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tse_user.dart';
import '../models/chemist.dart';
import '../models/stockist.dart';
import '../models/brand.dart';
import '../models/product.dart';
import '../models/dcr_submission.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://services.heterohcl.com/chemist-app';

  String? _accessToken;
  String? _refreshToken;
  TseUser? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  TseUser? get currentUser => _currentUser;

  final String _deviceId = '123-56';
  final String _deviceName = 'Samsung Galaxy A55';
  final String _platform = 'ANDROID';
  final String _osVersion = 'Android 15';
  final String _appVersion = '1.0.0';

  String get deviceId => _deviceId;
  String get deviceName => _deviceName;
  String get platform => _platform;
  String get osVersion => _osVersion;
  String get appVersion => _appVersion;

  // Set credentials in-memory (useful if retrieved from local storage in future)
  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  // Clear in-memory state on logout
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }

  // Header helper for requests
  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Base HTTP Request wrapper with auto-token-refresh retry
  Future<http.Response> _sendRequest(String method, String urlPath, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$urlPath');
    final headers = _getHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;

    http.Response response;
    
    // Perform initial request
    if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: encodedBody);
    } else {
      response = await http.get(uri, headers: headers);
    }

    // Check if token expired (401) and we have a refresh token
    if (response.statusCode == 401 && _refreshToken != null) {
      final refreshSuccess = await refreshSessionToken();
      if (refreshSuccess) {
        // Re-get headers with the updated access token
        final retryHeaders = _getHeaders();
        // Retry the request once
        if (method == 'POST') {
          response = await http.post(uri, headers: retryHeaders, body: encodedBody);
        } else {
          response = await http.get(uri, headers: retryHeaders);
        }
      }
    }

    return response;
  }

  // LOGIN API: POST /api/auth/login
  Future<TseUser> login(String employeeId, String password) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final payload = {
      'employeeId': employeeId.trim(),
      'password': password.trim(),
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'platform': _platform,
      'osVersion': _osVersion,
      'appVersion': _appVersion,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final dataMap = data['data'];
        _accessToken = dataMap['accessToken'];
        _refreshToken = dataMap['refreshToken'];
        
        final profileMap = dataMap['profile'];
        _currentUser = TseUser.fromJson(profileMap);
        return _currentUser!;
      } else {
        throw Exception(data['message'] ?? 'Login failed.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // REFRESH TOKEN API: POST /api/auth/refresh
  Future<bool> refreshSessionToken() async {
    if (_refreshToken == null) return false;

    final uri = Uri.parse('$baseUrl/api/auth/refresh');
    final payload = {
      'refreshToken': _refreshToken,
      'deviceId': _deviceId,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final dataMap = data['data'];
          _accessToken = dataMap['accessToken'];
          _refreshToken = dataMap['refreshToken'];
          return true;
        }
      }
    } catch (_) {
      // Ignore exception and return false to trigger login screen transition
    }

    clearTokens();
    return false;
  }

  // PROFILE API: GET /api/auth/profile
  Future<TseUser> getProfile() async {
    final response = await _sendRequest('GET', '/api/auth/profile');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final profileMap = data['data']['profile'];
        _currentUser = TseUser.fromJson(profileMap);
        return _currentUser!;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch profile.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // LOGOUT API: POST /api/auth/logout
  Future<bool> logout() async {
    final tokenToInvalidate = _refreshToken;
    clearTokens();

    if (tokenToInvalidate == null) return true;

    try {
      final response = await _sendRequest(
        'POST',
        '/api/auth/logout',
        body: {'refreshToken': tokenToInvalidate},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
    } catch (_) {
      // Ignore network errors on logout
    }

    return true;
  }

  // CHEMISTS LIST API: GET /api/master/chemists
  Future<List<Chemist>> getMappedChemists(String tseEmployeeId) async {
    final response = await _sendRequest('GET', '/api/master/chemists');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final list = data['data']['chemists'] as List;
        return list.map((c) => Chemist.fromJson(c)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch chemists.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // STOCKISTS LIST API: GET /api/master/stockists
  Future<List<Stockist>> getStockistsForUser(String tseEmployeeId) async {
    final response = await _sendRequest('GET', '/api/master/stockists');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final list = data['data']['stockists'] as List;
        return list.map((s) => Stockist.fromJson(s)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch stockists.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // PRODUCTS LIST API: GET /api/master/products
  Future<List<Product>> getProductsForUser(String tseEmployeeId) async {
    final response = await _sendRequest('GET', '/api/master/products');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final list = data['data']['products'] as List;
        return list.map((p) => Product.fromJson(p)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch products.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // For compatibility/fallback (returns empty or fetches dynamically in provider)
  Future<List<Brand>> getBrands() async {
    return [];
  }

  // SUBMIT STOCKS API: POST /api/stocks/submit
  Future<bool> submitDcrReport(DcrSubmission submission) async {
    final payload = {
      'chemistCode': submission.chemist.id,
      'stockistSapIds': submission.selectedStockists.map((s) => s.id).toList(),
      'items': submission.items.map((i) => {
        'materialCode': i.productId,
        'quantity': i.quantity,
      }).toList(),
      'latitude': submission.latitude,
      'longitude': submission.longitude,
    };

    final response = await _sendRequest(
      'POST',
      '/api/stocks/submit',
      body: payload,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['status'] == true;
    } else {
      throw Exception('Server error during DCR submission: ${response.statusCode}');
    }
  }

  // SUBMITTED STOCKS API: GET /api/stocks/submitted
  Future<List<DcrSubmission>> getDcrHistory() async {
    final response = await _sendRequest('GET', '/api/stocks/submitted');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final records = data['data']['records'] as List;
        return records.map((r) => DcrSubmission.fromJson(r)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch DCR history.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}

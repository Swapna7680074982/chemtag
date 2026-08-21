// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  // Callback when session expires
  void Function()? onSessionExpired;

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
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('current_user');
    } catch (_) {}
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

  Future<http.Response> _executeWithTimeout(Future<http.Response> Function() requestFn) async {
    try {
      return await requestFn().timeout(const Duration(seconds: 15));
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Connection timed out. Please check your internet connection or try again.');
      }
      final errStr = e.toString();
      if (errStr.contains('SocketException') || errStr.contains('HandshakeException')) {
        throw Exception('Server is unreachable. Please check your internet connection.');
      }
      if (errStr.contains('ClientException')) {
        throw Exception('Network connection error. Please try again.');
      }
      rethrow;
    }
  }

  // Base HTTP Request wrapper with auto-token-refresh retry
  Future<http.Response> _sendRequest(String method, String urlPath, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$urlPath');
    final headers = _getHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;

    http.Response response;
    
    // Perform initial request
    if (method == 'POST') {
      response = await _executeWithTimeout(() => http.post(uri, headers: headers, body: encodedBody));
    } else {
      response = await _executeWithTimeout(() => http.get(uri, headers: headers));
    }

    print('API Request ($method $urlPath) Response Status: ${response.statusCode}');
    print('API Request ($method $urlPath) Response Body: ${response.body}');

    // Check if token expired (401)
    if (response.statusCode == 401) {
      bool refreshSuccess = false;
      if (_refreshToken != null) {
        refreshSuccess = await refreshSessionToken();
      }
      if (refreshSuccess) {
        // Re-get headers with the updated access token
        final retryHeaders = _getHeaders();
        // Retry the request once
        if (method == 'POST') {
          response = await _executeWithTimeout(() => http.post(uri, headers: retryHeaders, body: encodedBody));
        } else {
          response = await _executeWithTimeout(() => http.get(uri, headers: retryHeaders));
        }
        print('API Retry Request ($method $urlPath) Response Status: ${response.statusCode}');
        print('API Retry Request ($method $urlPath) Response Body: ${response.body}');
      } else {
        // Clear tokens and trigger session expired callback
        await clearTokens();
        onSessionExpired?.call();
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

    final response = await _executeWithTimeout(() => http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ));

    print('Login Response Status: ${response.statusCode}');
    print('Login Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final dataMap = data['data'];
        _accessToken = dataMap['accessToken'];
        _refreshToken = dataMap['refreshToken'];
        
        final profileMap = dataMap['profile'];
        _currentUser = TseUser.fromJson(profileMap);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _accessToken!);
          await prefs.setString('refresh_token', _refreshToken!);
          await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
        } catch (_) {}

        return _currentUser!;
      } else {
        throw Exception(data['message'] ?? 'Login failed.');
      }
    } else {
      throw Exception(_getErrorMessage(response));
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
      final response = await _executeWithTimeout(() => http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ));

      print('Refresh Token Response Status: ${response.statusCode}');
      print('Refresh Token Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final dataMap = data['data'];
          _accessToken = dataMap['accessToken'];
          _refreshToken = dataMap['refreshToken'];

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', _accessToken!);
            await prefs.setString('refresh_token', _refreshToken!);
          } catch (_) {}

          return true;
        }
      }
    } catch (_) {
      // Ignore exception and return false to trigger login screen transition
    }

    await clearTokens();
    return false;
  }

  // AUTO LOGIN VERIFICATION
  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAccessToken = prefs.getString('access_token');
      final cachedRefreshToken = prefs.getString('refresh_token');
      final cachedUserJson = prefs.getString('current_user');

      if (cachedRefreshToken == null) {
        return false;
      }

      _accessToken = cachedAccessToken;
      _refreshToken = cachedRefreshToken;

      if (cachedUserJson != null) {
        try {
          _currentUser = TseUser.fromJson(jsonDecode(cachedUserJson));
        } catch (_) {}
      }

      // Verify session via profile API.
      // If access token is expired, _sendRequest automatically tries to refresh it.
      final profile = await getProfile();
      _currentUser = profile;
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
      return true;
    } catch (_) {
      // If refreshing/verifying fails, check if tokens were cleared (expired).
      if (_refreshToken == null) {
        return false;
      }
      // If we still have the refresh token (meaning it was a connection/network error),
      // we allow access in offline-mode using cached user details.
      if (_currentUser != null) {
        return true;
      }
      return false;
    }
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
      throw Exception(_getErrorMessage(response));
    }
  }

  // LOGOUT API: POST /api/auth/logout
  Future<bool> logout() async {
    final tokenToInvalidate = _refreshToken;
    await clearTokens();

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
  Future<List<Chemist>> getMappedChemists(String tseEmployeeId, {String? search}) async {
    final path = search != null && search.trim().isNotEmpty
        ? '/api/master/chemists?search=${Uri.encodeComponent(search.trim())}'
        : '/api/master/chemists';
    final response = await _sendRequest('GET', path);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final list = data['data']['chemists'] as List;
        return list.map((c) => Chemist.fromJson(c)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch chemists.');
      }
    } else {
      throw Exception(_getErrorMessage(response));
    }
  }

  // STOCKISTS LIST API: GET /api/master/stockists
  Future<List<Stockist>> getStockistsForUser(String tseEmployeeId, {String? search}) async {
    final path = search != null && search.trim().isNotEmpty
        ? '/api/master/stockists?search=${Uri.encodeComponent(search.trim())}'
        : '/api/master/stockists';
    final response = await _sendRequest('GET', path);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final list = data['data']['stockists'] as List;
        return list.map((s) => Stockist.fromJson(s)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch stockists.');
      }
    } else {
      throw Exception(_getErrorMessage(response));
    }
  }

  // PRODUCTS LIST API: GET /api/master/products
  Future<List<Product>> getProductsForUser(String tseEmployeeId, {String? search}) async {
    final path = search != null && search.trim().isNotEmpty
        ? '/api/master/products?search=${Uri.encodeComponent(search.trim())}'
        : '/api/master/products';
    final response = await _sendRequest('GET', path);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final list = data['data']['products'] as List;
        return list.map((p) => Product.fromJson(p)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch products.');
      }
    } else {
      throw Exception(_getErrorMessage(response));
    }
  }

  // For compatibility/fallback (returns empty or fetches dynamically in provider)
  Future<List<Brand>> getBrands() async {
    return [];
  }

  // SUBMIT STOCKS API: POST /api/stocks/submit
  Future<bool> submitDcrReport(DcrSubmission submission) async {
    final List<Map<String, dynamic>> stockistsPayload = [];
    for (final stockist in submission.selectedStockists) {
      final products = submission.items
          .where((item) => item.stockistId == stockist.id)
          .map((item) => {
                'materialCode': item.productId,
                'quantity': item.quantity,
              })
          .toList();
      
      if (products.isNotEmpty) {
        stockistsPayload.add({
          'stockistSapId': stockist.id,
          'products': products,
        });
      }
    }

    final payload = {
      'chemistCode': submission.chemist.id,
      'stockists': stockistsPayload,
      'latitude': submission.latitude,
      'longitude': submission.longitude,
      'gpsAccuracyMeters': submission.accuracyMeters,
      'locationCapturedAt': _formatDateTimeWithOffset(submission.submittedAt),
      'remarks': submission.notes,
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
      throw Exception(_getErrorMessage(response, defaultMessage: 'Server error during DCR submission'));
    }
  }

  String _formatDateTimeWithOffset(DateTime dt) {
    if (dt.isUtc) {
      return dt.toIso8601String();
    }
    final offset = dt.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    final base = dt.toIso8601String().split('.').first;
    return '$base$sign$hours:$minutes';
  }


  // SUBMITTED STOCKS API: POST /api/stocks/submitted
  Future<List<DcrSubmission>> getDcrHistory() async {
    final response = await _sendRequest('POST', '/api/stocks/submitted', body: {});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final records = data['data']['records'] as List;
        return records.map((r) => DcrSubmission.fromJson(r)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch DCR history.');
      }
    } else {
      throw Exception(_getErrorMessage(response));
    }
  }

  String _getErrorMessage(http.Response response, {String defaultMessage = 'Server error'}) {
    try {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          if (data['message'] != null) {
            return data['message'].toString();
          }
          if (data['error'] != null) {
            return data['error'].toString();
          }
        }
      }
    } catch (_) {}
    return '$defaultMessage: ${response.statusCode}';
  }
}

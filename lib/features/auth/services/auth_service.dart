import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Initialize the AuthService and check if the user is signed in.
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  // Your app's client info
  // FIXME: Update the CI/CD to inject these values securely.
  final String _iOSClientId = const String.fromEnvironment('IOS_CLIENT_ID');
  final String _iOSRedirectUrl = const String.fromEnvironment(
    'IOS_REDIRECT_URL',
  );
  final String _androidClientId = const String.fromEnvironment(
    'ANDROID_CLIENT_ID',
  );
  final String _androidRedirectUrl = const String.fromEnvironment(
    'ANDROID_REDIRECT_URL',
  );
  final String _discoveryUrl =
      'https://accounts.google.com/.well-known/openid-configuration';
  final List<String> _scopes = [
    'openid',
    'email',
    'profile',
    'https://www.googleapis.com/auth/gmail.readonly',
  ];

  // Storage keys
  final String _kAccessToken = 'google_access_token';
  final String _kRefreshToken = 'google_refresh_token';
  final String _kIdToken = 'google_id_token';
  final String _kTokenExpiry = 'google_token_expiry';

  Future<AuthService> init() async {
    _isSignedIn = await checkAccessToken();
    // Any async initialization if needed
    return this;
  }

  /// Returns true if access token exists.
  Future<bool> checkAccessToken() async {
    final accessToken = await _secureStorage.read(key: _kAccessToken);
    return accessToken != null;
  }

  /// Authorize the user and save tokens securely
  Future<bool> signInWithGoogle() async {
    late final AuthorizationTokenRequest request;
    if (Platform.isIOS) {
      request = AuthorizationTokenRequest(
        _iOSClientId,
        _iOSRedirectUrl,
        discoveryUrl: _discoveryUrl,
        scopes: _scopes,
      );
    } else {
      request = AuthorizationTokenRequest(
        _androidClientId,
        _androidRedirectUrl,
        discoveryUrl: _discoveryUrl,
        scopes: _scopes,
      );
    }
    try {
      final result = await _appAuth.authorizeAndExchangeCode(request);
      await _secureStorage.write(key: _kAccessToken, value: result.accessToken);
      await _secureStorage.write(
        key: _kRefreshToken,
        value: result.refreshToken,
      );
      await _secureStorage.write(key: _kIdToken, value: result.idToken);
      await _secureStorage.write(
        key: _kTokenExpiry,
        value: result.accessTokenExpirationDateTime?.toIso8601String(),
      );
      return true;
    } on FlutterAppAuthUserCancelledException catch (_) {
      log('User cancelled the sign-in process.');
      return false;
    } catch (e) {
      log('Google Sign-In Error: $e');
      return false;
    }
  }

  /// Get the stored access token (auto-refresh if expired)
  Future<String?> getAccessToken() async {
    String? accessToken = await _secureStorage.read(key: _kAccessToken);
    String? refreshToken = await _secureStorage.read(key: _kRefreshToken);
    // Return null if tokens are missing.
    if (accessToken == null || refreshToken == null) {
      return null;
    }
    // Refresh token if it's close to expiry.
    final expiryStr = await _secureStorage.read(key: _kTokenExpiry);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)))) {
        accessToken = await _refreshAccessToken(refreshToken);
      }
    }
    return accessToken;
  }

  /// Refresh the access token using refresh_token
  Future<String?> _refreshAccessToken(String refreshToken) async {
    late final Map<String, dynamic> body;
    if (Platform.isIOS) {
      body = {
        'client_id': _iOSClientId,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };
    } else {
      body = {
        'client_id': _androidClientId,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };
    }
    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        await _secureStorage.write(key: _kAccessToken, value: newAccessToken);
        return newAccessToken;
      } else {
        log('Failed to refresh token: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Token refresh error: $e');
      return null;
    }
  }

  /// Get user profile info (optional)
  /// FIXME: Based on result design the response model.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      log('Failed to fetch user info: ${response.body}');
      return null;
    }
  }

  /// Logout and clear all stored tokens
  Future<void> signOut() async {
    late final EndSessionRequest request;
    if (Platform.isIOS) {
      request = EndSessionRequest(
        idTokenHint: await _secureStorage.read(key: _kIdToken),
        postLogoutRedirectUrl: _iOSRedirectUrl,
        discoveryUrl: _discoveryUrl,
      );
    } else {
      request = EndSessionRequest(
        idTokenHint: await _secureStorage.read(key: _kIdToken),
        postLogoutRedirectUrl: _androidRedirectUrl,
        discoveryUrl: _discoveryUrl,
      );
    }
    await _appAuth.endSession(request);
    await _secureStorage.deleteAll();
  }
}

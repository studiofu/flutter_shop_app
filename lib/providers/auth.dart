import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_execption.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  final String webkey = 'AIzaSyDOWMeAeCvsMv51GU-N3iMLcZv3ilIqZkQ';

  bool get isAuth {
    if (_expiryDate != null && _token != null) {
      if (_expiryDate!.isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  String get token {
    if (_expiryDate != null && _token != null) {
      if (_expiryDate!.isAfter(DateTime.now())) {
        return _token!;
      }
    }
    return '';
  }

  String get userId {
    if (_userId != null) {
      return _userId!;
    } else {
      return '';
    }
  }

  Future<void> signup(String email, String password) async {
    // https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=[API_KEY]
    // https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
    // AIzaSyDOWMeAeCvsMv51GU-N3iMLcZv3ilIqZkQ

    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${webkey}';

    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      print(jsonDecode(response.body));

      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpExeception(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    print('try auto login');
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print('no user prefs');
      return false;
    }
    print('has user data');
    print(prefs.getString('userData') as String);
    final extractedUserData = jsonDecode(prefs.getString('userData') as String);
    print('.....');
    print('user prefers: $extractedUserData');
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      print('expired....');
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    print('token... $_token');

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> login(String email, String password) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${webkey}';

    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      print(jsonDecode(response.body));

      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpExeception(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));

      _autoLogout();
      notifyListeners();

      // store login session
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  void logout() async {
    _expiryDate = null;
    _token = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }

    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry ?? 1),
      () {
        logout();
      },
    );
  }
}

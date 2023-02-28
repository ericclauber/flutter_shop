import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/stode.dart';
import 'package:shop/exception/auth_exception.dart';

const idTokenKey = "idToken";
const emailKey = "email";
const uidKey = "localId";
const expiresInKey = "expiresIn";

class Auth with ChangeNotifier {
  String? _token;
  String? _email;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    final isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    return _token != null && isValid;
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get userId {
    return isAuth ? _userId : null;
  }

  Future<void> _authenticate(
      String email, String password, String authType) async {
    final _url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$authType?key=AIzaSyAFHF2yWlZDh8rZ7imdIHLVUmmuReG_QlA";

    final response = await http.post(
      Uri.parse(_url),
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    final body = jsonDecode(response.body);
    if (body["error"] != null) {
      throw AuthException(body["error"]["message"]);
    } else {
      _token = body[idTokenKey];
      _email = body[emailKey];
      _userId = body[uidKey];
      _expiryDate =
          DateTime.now().add(Duration(seconds: int.parse(body[expiresInKey])));

      Store.saveMap("userData", {
        "token": _token,
        "email": _email,
        "userId": _userId,
        "expiredDate": _expiryDate!.toIso8601String()
      });

      _autoLogout();
      notifyListeners();
    }
    print(jsonDecode(response.body));
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) return;

    final userData = await Store.getMap("userData");
    if (userData.isEmpty) return;

    final expiredDate = DateTime.parse(userData["expiredDate"]);
    if (expiredDate.isBefore(DateTime.now())) return;

    _token = userData["token"];
    _email = userData["email"];
    _userId = userData["userId"];
    _expiryDate = expiredDate;

    _autoLogout();
    notifyListeners();
  }

  void logout() {
    _token = null;
    _email = null;
    _userId = null;
    _expiryDate = null;
    _clearLogoutTimer();
    Store.remove("userData").then((value) {
      notifyListeners();
    });
  }

  void _clearLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  void _autoLogout() {
    _clearLogoutTimer();
    final expiredToken = _expiryDate?.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: expiredToken ?? 0), logout);
  }
}

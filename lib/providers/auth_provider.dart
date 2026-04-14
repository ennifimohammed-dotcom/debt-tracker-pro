import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _authenticated = false;
  bool _hasPin = false;
  bool _lockEnabled = true;
  String _currency = 'درهم';

  bool get authenticated => _authenticated;
  bool get hasPin => _hasPin;
  bool get lockEnabled => _lockEnabled;
  String get currency => _currency;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _hasPin = p.getString('pin') != null;
    _lockEnabled = p.getBool('lock_enabled') ?? true;
    _currency = p.getString('currency') ?? 'درهم';
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('pin', pin);
    _hasPin = true;
    _authenticated = true;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    final stored = p.getString('pin');
    if (stored == pin) {
      _authenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> removePin() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('pin');
    _hasPin = false;
    notifyListeners();
  }

  Future<void> setLockEnabled(bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('lock_enabled', val);
    _lockEnabled = val;
    if (!val) _authenticated = true;
    notifyListeners();
  }

  Future<void> setCurrency(String val) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('currency', val);
    _currency = val;
    notifyListeners();
  }

  void skipAuth() {
    _authenticated = true;
    notifyListeners();
  }

  void lock() {
    _authenticated = false;
    notifyListeners();
  }
}

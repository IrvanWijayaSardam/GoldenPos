import 'package:flutter/foundation.dart';

class Profile with ChangeNotifier {
  final String name;
  final String email;
  final String password;
  final String profile;
  final String telp;
  final String pin;
  final String jk;


  Profile({
    required this.name,
    required this.email,
    required this.password,
    required this.profile,
    required this.telp,
    required this.pin,
    required this.jk
  });
}

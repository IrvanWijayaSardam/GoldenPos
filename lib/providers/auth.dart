import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './profile.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class Auth with ChangeNotifier {
  late String _jwtToken;
  late int _id;
  late String _name;
  late String _email;
  late String _profile;
  late String _telp;
  late String _pin;
  late String _jk;

  bool _isAuthenticated = false;

  bool get isAuth {
    return _isAuthenticated;
  }

  String get jwtToken {
    if (_jwtToken != null) {
      return _jwtToken;
    }
    return "";
  }

  String get name {
    if (_name != null) {
      return _name;
    }
    return "";
  }

  set name(String name) {
    _name = name;
  }

  String get profile {
    if (_profile != null) {
      return _profile;
    }
    return "";
  }

  set profile(String profile) {
    _profile = profile;
  }

  String get pin {
    if (_pin != null) {
      return _pin;
    }
    return "";
  }

  set pin(String pin) {
    _pin = pin;
  }

  String get jk {
    if (_jk != null) {
      return _jk;
    }
    return "";
  }

  set jk(String jk) {
    _jk = jk;
  }

  String get email {
    if (_email != null) {
      return _email;
    }
    return "";
  }

  set email(String email) {
    _email = email;
  }

  String get telp {
    if (_telp != null) {
      return _telp;
    }
    return "";
  }

  set telp(String telp) {
    _telp = telp;
  }

  int get userId {
    if (_id != null) {
      return _id;
    }
    return 0;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwtToken')) {
      return false;
    }
    _jwtToken = prefs.getString('jwtToken')!;
    _id = prefs.getInt('id')!;
    _name = prefs.getString('name')!;
    _email = prefs.getString('email')!;
    _profile = prefs.getString('profile')!;
    _telp = prefs.getString('telp')!;
    _pin = prefs.getString('pin')!;
    _jk = prefs.getString('jk')!;

    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<void> _authenticate(String email, String password) async {
    final url = Uri.parse('https://test.goldenmom.id/api/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
      final responseData = json.decode(response.body);
      print(json.decode(response.body));
      
        _id = responseData["user"]["id"];
        _name = responseData["user"]["name"];
        _email = responseData["user"]["email"];
        _jwtToken = responseData["access_token"];

        _isAuthenticated = true;

        // Save the user session using shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('jwtToken', _jwtToken);
        prefs.setInt('id', _id);
        prefs.setString('name', _name);
        prefs.setString('email', _email);

      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> logout() async {
    // Perform logout logic
    _isAuthenticated = false;
    notifyListeners();

    // Clear shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _createAccount(String name, String email, String password) async {
    final url = Uri.parse('https://test.goldenmom.id/api/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': name,
            'email': email,
            'password': password,
          },
        ),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _id = responseData["user"]["id"];
        _name = responseData["user"]["name"];
        _email = responseData["user"]["email"];
        _jwtToken = responseData["access_token"];

        _isAuthenticated = true;

        // Save the user session using shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('jwtToken', _jwtToken);
        prefs.setInt('id', _id);
        prefs.setString('name', _name);
        prefs.setString('email', _email);

        print(json.decode(response.body));
        notifyListeners();
      } else {
        // Check if the error response contains 'errors' field
        if (responseData['errors'] != null) {
          throw HttpException(responseData['errors'].toString());
        } else {
          throw HttpException('An error occurred. Please try again later.');
        }
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> _updateAccount(Profile newProfile) async {
    final url = Uri.parse('https://cashflow-production-f95f.up.railway.app/api/user/profile');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken
        },
        body: json.encode(
          {
            'name': newProfile.name,
            'email': newProfile.email,
            'password': newProfile.password,
            'profile': newProfile.profile,
            'telp': newProfile.telp,
            'pin': newProfile.pin,
            'jk': newProfile.jk,
          },
        ),
      );

      final responseData = json.decode(response.body);
      print(responseData);

      if (response.statusCode == 200) {
        _id = responseData["data"]["id"];
        _name = responseData["data"]["name"];
        _email = responseData["data"]["email"];
        _profile = responseData["data"]["profile"];
        _telp = responseData["data"]["telp"];
        _pin = responseData["data"]["pin"];
        _jk = responseData["data"]["jk"];

        // Save the user session using shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('jwtToken', _jwtToken);
        prefs.setInt('id', _id);
        prefs.setString('name', _name);
        prefs.setString('email', _email);
        prefs.setString('profile', _profile);
        prefs.setString('telp', _telp);
        prefs.setString('pin', _pin);
        prefs.setString('jk', _jk);

        print(json.decode(response.body));
        notifyListeners();
      } else {
        // Check if the error response contains 'errors' field
        if (responseData['errors'] != null) {
          print(responseData['errors']);
          throw HttpException(responseData['errors'].toString());
        } else {
          print(responseData['errors']);
          throw HttpException('An error occurred. Please try again later.');
        }
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> _uploadProfilePicture(File file) async {
    final url = Uri.parse('https://cashflow-production-f95f.up.railway.app/api/user/picture');
    try {
      final request = http.MultipartRequest('POST', url);

      request.headers['Content-Type'] = 'application/json';
      request.headers['Authorization'] = jwtToken;

      // Attach the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType:
            MediaType('image', 'jpeg'), // Adjust the content type as needed
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print(responseData);

      if (response.statusCode == 200) {
        // Handle the successful response
        final data = json.decode(responseData);
        final prefs = await SharedPreferences.getInstance();
        _profile = data['data'].toString();

        prefs.setString('profile', _profile);

        print(data);
        notifyListeners();
      } else {
        // Handle the error response
        final errorData = json.decode(responseData);

        if (errorData['errors'] != null) {
          print(errorData['errors']);
          throw HttpException(errorData['errors'].toString());
        } else {
          print(errorData['errors']);
          throw HttpException('An error occurred. Please try again later.');
        }
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password);
  }

  Future<void> signup(String name, String email, String password) async {
    return _createAccount(name, email, password);
  }

  Future<void> update(Profile newProfile) async {
    return _updateAccount(newProfile);
  }

  Future<void> updateProfilePicture(File file) async {
    return _uploadProfilePicture(file);
  }
}

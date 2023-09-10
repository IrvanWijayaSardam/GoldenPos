import 'dart:convert';

import 'package:GoldenPos/providers/Order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../models/http_exception.dart';

class Customers with ChangeNotifier {
  List<Customer> _items = [];
  String _selectedCustomer = "";
  final String jwtToken;
  String _nextPageUrl = '';
  bool _hasMorePages = true;

  Customers(this.jwtToken, this._items);

  List<Customer> get items {
    return [..._items];
  }

  String get selectedCustomer {
    return _selectedCustomer;
  }

  void setSelectedCustomer(String customerName) {
    _selectedCustomer = customerName;
    notifyListeners();
  }

  Customer findById(int id) {
    return _items.firstWhere((trx) => trx.id == id);
  }

  Future<void> fetchAndSetCustomer() async {
    try {
      if (!_hasMorePages) {
        // Tidak ada page lagi
        return;
      }

      String url = _nextPageUrl.isNotEmpty
          ? _nextPageUrl
          : 'https://test.goldenmom.id/api/customers';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );
      final responseData = json.decode(response.body);
      final List<Customer> loadedCustomer = [];

      final List<dynamic> custData = responseData['data'];
      custData.forEach((cstData) {
        loadedCustomer.add(Customer(
          id: cstData['id'] as int,
          uuid:
              cstData['uuid'] as String, 
          name:
              cstData['name'] as String,
          gender: cstData['gender']
              as String, 
          phone: cstData['phone']
              as String, 
        ));
      });
      if (responseData['next_page_url'] != null) {
        _nextPageUrl = responseData['next_page_url'];
        print('Next Page Url : ${_nextPageUrl}');
      } else {
        print('Max Page');
        _nextPageUrl = "";
        _hasMorePages = false; 
      }

      // masukan order ke list yang sudah ada
      _items.addAll(loadedCustomer);
      notifyListeners();
    } catch (error) {
      print('Error fetching orders: $error');
      throw error;
    }
  }

  Future<void> _createCustomers(
      String name, String gender, String phone) async {
    print('name : $name ' + 'gender : ${gender}' + 'phone : ${phone}');
    final url = Uri.parse('https://test.goldenmom.id/api/customers');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${jwtToken}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'gender': gender,
          'phone': phone,
        },
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 201) {
        final customerID =
            responseData['id'];
        print(json.decode(response.body));
        notifyListeners();
        Fluttertoast.showToast(
          msg: "Customer Created #$customerID", 
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
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

  Future<void> _updateCustomer(
      String id, String name, String gender, String phone) async {
    print('id: $id ' +
        'name : $name ' +
        'gender : ${gender} ' +
        'phone : ${phone} ');
    final url = Uri.parse('https://test.goldenmom.id/api/customers/${id}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${jwtToken}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'gender': gender,
          'phone': phone,
        },
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        final customerID =
            responseData['id']; // Extract the 'id' from the response data
        print(json.decode(response.body));
        notifyListeners();
        // Show a toast message with the order ID
        Fluttertoast.showToast(
          msg: "Customer Updated #$customerID", // Use the extracted order ID
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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

  Future<void> _deleteCustomer(String id) async {
    print('id: $id ');
    final url = Uri.parse('https://test.goldenmom.id/api/customers/${id}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${jwtToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        notifyListeners();
        // Show a toast message with the order ID
        Fluttertoast.showToast(
          msg: "Customer Deleted #$id", // Use the extracted order ID
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> createCustomer(String name, String gender, String phone) async {
    return _createCustomers(name, gender, phone);
  }

  Future<void> updateCustomer(
      String id, String name, String gender, String phone) async {
    return _updateCustomer(id, name, gender, phone);
  }

  Future<void> deleteCustomer(
      String id) async {
    return _deleteCustomer(id);
  }
}

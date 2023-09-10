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
          id: cstData['id'] as int, // Cast to int if 'id' is an integer
          uuid:
              cstData['uuid'] as String, // Cast to String if 'uuid' is a string
          name:
              cstData['name'] as String, // Cast to String if 'code' is a string
          gender: cstData['gender']
              as String, // Cast to String if 'name' is a string
          phone: cstData['phone']
              as String, // Cast to int if 'price' is an integer
        ));
      });
      if (responseData['next_page_url'] != null) {
        _nextPageUrl = responseData['next_page_url'];
        print('Next Page Url : ${_nextPageUrl}');
      } else {
        print('Max Page');
        _nextPageUrl = ""; // Page sudah terload semua
        _hasMorePages = false; // set flag agar tidak load ulang
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
            responseData['id']; // Extract the 'id' from the response data
        print(json.decode(response.body));
        notifyListeners();
        // Show a toast message with the order ID
        Fluttertoast.showToast(
          msg: "Customer Created #$customerID", // Use the extracted order ID
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
/*
  Future<void> _createTransaksi(String transactionType, String date,
      int trxValue, String description, String trxGroup) async {
    final url = Uri.parse('https://cashflow-production-f95f.up.railway.app/api/transaction/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
        body: json.encode(
          {
            'userid': userId,
            'trxtype': transactionType,
            'date': date,
            'trxvalue': trxValue,
            'description': description,
            'trxgroup': trxGroup,
          },
        ),
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 201) {
        print(json.decode(response.body));
        final newTransaction = Transaction(id: responseData['data']['id'], userId: userId, transactionType: transactionType, date: date, transactionValue: trxValue, description: description, transactionGroup: trxGroup);
        _items.add(newTransaction);
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

  Future<void> _updateTransaction(int id, Transaction newTransaction) async {
    final trxIndex = _items.indexWhere((prod) => prod.id == id);
    if (trxIndex >= 0) {
      final url = Uri.parse('https://cashflow-production-f95f.up.railway.app/api/transaction/');
      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken,
          },
          body: json.encode(
            {
              'id': newTransaction.id,
              'userid': newTransaction.userId,
              'trxtype': newTransaction.transactionType,
              'date': newTransaction.date,
              'trxvalue': newTransaction.transactionValue,
              'description': newTransaction.description,
              'trxgroup': newTransaction.transactionGroup,
            },
          ),
        );
        _items[trxIndex] = newTransaction;
        final responseData = json.decode(response.body);
        if (response.statusCode == 200) {
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
      notifyListeners();
    } else {
      print('....');
    }
  }

  Future<void> _deleteTransactions(int id) async {
    final url = Uri.parse('https://cashflow-production-f95f.up.railway.app/api/transaction/$id');
    final existingTrxIndex = _items.indexWhere((trx) => trx.id == id);
    var existingTrx = _items[existingTrxIndex];
    _items.removeAt(existingTrxIndex);
    notifyListeners();
    final response = await http.delete(url, headers: {
      'Authorization': jwtToken,
    });
    if (response.statusCode >= 400) {
      _items.insert(existingTrxIndex, existingTrx);
      notifyListeners();
      throw HttpException('Could not delete product');
    } 
    existingTrx = null;
  }


  Future<void> createTransaction(String transactionType, String date,
      int trxValue, String description, String trxGroup) async {
    return _createTransaksi(
        transactionType, date, trxValue, description, trxGroup);
  }

  Future<void> updateTransaction(int id, Transaction) async {
    return _updateTransaction(id, Transaction);
  }

  Future<void> deleteTransaction(int id) async {
    return _deleteTransactions(id);
  }
  */

  Future<void> createCustomer(String name, String gender, String phone) async {
    return _createCustomers(name, gender, phone);
  }
}

import 'dart:convert';

import '../providers/Order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import './product.dart';
import '../models/http_exception.dart';

class Orders with ChangeNotifier {
  List<Order> _items = [];

  final String jwtToken;

  Orders(this.jwtToken, this._items);

  List<Order> get items {
    return [..._items];
  }

  Order findById(int id) {
    return _items.firstWhere((trx) => trx.id == id);
  }

  Future<void> fetchAndSetOrders() async {
  var url = Uri.parse('https://test.goldenmom.id/api/orders');
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );
    final responseData = json.decode(response.body);
    final List<Order> loadedOrders = [];

    final List<dynamic> ordersData = responseData['data'];
    ordersData.forEach((orderData) {
      loadedOrders.add(Order(
        id: orderData['id'] as int,
        qty: orderData['qty'] as int,
        price: orderData['price'] as int,
        total: orderData['total'] as int,
        isPaid: orderData['is_paid'] as int,
        createdAt: orderData['created_at'] as String,
        customer: Customer(
          id: orderData['customer']['id'] as int,
          uuid: orderData['customer']['uuid'] as String,
          name: orderData['customer']['name'] as String,
          gender: orderData['customer']['gender'] as String,
          phone: orderData['customer']['phone'] as String,
        ),
        product: ProductData(
          id: orderData['product']['id'] as int,
          uuid: orderData['product']['uuid'] as String,
          code: orderData['product']['code'] as String,
          name: orderData['product']['name'] as String,
          price: orderData['product']['price'] as int,
        ),
      ));
    });

    _items = loadedOrders;
    notifyListeners();
  } catch (error) {
    print('Error fetching orders: $error');
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
}

import 'dart:convert';

import '../providers/Order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import './product.dart';
import '../models/http_exception.dart';

class Orders with ChangeNotifier {
  List<Order> _items = [];
  String _nextPageUrl = ''; 
  final String jwtToken;
  bool _hasMorePages = true;

  Orders(this.jwtToken, this._items);

  List<Order> get items {
    return [..._items];
  }

  Future<void> fetchAndSetOrders() async {
    try {
      if (!_hasMorePages) {
        // Tidak ada page lagi
        return;
      }

      String url = _nextPageUrl.isNotEmpty
          ? _nextPageUrl
          : 'https://test.goldenmom.id/api/orders';
      final response = await http.get(
        Uri.parse(url),
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

      if (responseData['next_page_url'] != null) {
        _nextPageUrl = responseData['next_page_url'];
        print('Next Page Url : ${_nextPageUrl}');
      } else {
        print('Max Page');
        _nextPageUrl = ""; // Page sudah terload semua
        _hasMorePages = false; // set flag agar tidak load ulang
      }

      // masukan order ke list yang sudah ada
      _items.addAll(loadedOrders);
      notifyListeners();
    } catch (error) {
      print('Error fetching orders: $error');
      throw error;
    }
  }
}

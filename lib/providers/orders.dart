import 'dart:convert';

import '../providers/Order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<void> _createOrders(
      String customerId, String productId, String qty, String price) async {
    print(
        'customer id ${customerId} product id ${productId} qty ${qty} price ${price}');
    final url = Uri.parse('https://test.goldenmom.id/api/orders');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${jwtToken}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer_id': customerId,
          'product_id': productId,
          'qty': qty,
          'price': price,
        },
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 201) {
        final orderId =
            responseData['id']; // Extract the 'id' from the response data
        print(json.decode(response.body));
        notifyListeners();
        // Show a toast message with the order ID
        Fluttertoast.showToast(
          msg:
              "Transaction Success, Order ID #$orderId", // Use the extracted order ID
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

  Future<void> createOrder(
      String customerId, String productId, String qty, String price) async {
    return _createOrders(customerId, productId, qty, price);
  }
}

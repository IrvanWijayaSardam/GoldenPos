import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? _nextPageUrl;
  final String jwtToken;
  bool _isLoading = false;

  Products(this.jwtToken, this._items);

  List<Product> get items {
    return [..._items];
  }

  Product findById(int id) {
    return _items.firstWhere((product) => product.id == id);
  }

  bool get isLoading {
    return _isLoading;
  }

  Future<void> fetchAndSetProducts() async {
    if (_isLoading) {
      return; // Don't fetch if already loading
    }

    try {
      print(_nextPageUrl);
      String url = _nextPageUrl ?? 'https://test.goldenmom.id/api/products';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Product> loadedProducts = [];

        final List<dynamic> productsData = responseData['data'];
        productsData.forEach((productData) {
          loadedProducts.add(
            Product(
              id: productData['id'] as int,
              uuid: productData['uuid'] as String,
              code: productData['code'] as String,
              name: productData['name'] as String,
              price: productData['price'] as int,
            ),
          );
        });

        if (responseData['next_page_url'] != null) {
          _nextPageUrl = responseData['next_page_url'];
        } else {
          _nextPageUrl = null; 
        }

        _items.addAll(loadedProducts);
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      _isLoading = false;
      print('Error fetching products: $error');
      throw error;
    }
  }
}

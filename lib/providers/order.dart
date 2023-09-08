import 'package:flutter/foundation.dart';

class Order with ChangeNotifier {
  final int id;
  final int qty;
  final int price;
  final int total;
  final int isPaid;
  final String createdAt;
  final Customer customer;
  final ProductData product;

  Order({
    required this.id,
    required this.qty,
    required this.price,
    required this.total,
    required this.isPaid,
    required this.createdAt,
    required this.customer,
    required this.product,
  });
}

class Customer {
  final int id;
  final String uuid;
  final String name;
  final String gender;
  final String phone;

  Customer({
    required this.id,
    required this.uuid,
    required this.name,
    required this.gender,
    required this.phone,
  });
}

class ProductData {
  final int id;
  final String uuid;
  final String code;
  final String name;
  final int price;

  ProductData({
    required this.id,
    required this.uuid,
    required this.code,
    required this.name,
    required this.price,
  });
}

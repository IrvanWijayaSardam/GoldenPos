import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final int id;
  final String uuid;
  final String code;
  final String name;
  final int price;

  Product({
    required this.id,
    required this.uuid,
    required this.code,
    required this.name,
    required this.price,
  });
}

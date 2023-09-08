import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../utils/utils.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);

    return GestureDetector(
      onTap: () {
        // Add your desired functionality here
        print('Card tapped!');
      },
      child: Card(
        color: Color.fromARGB(255, 190, 252, 222),
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ],
              ),
              SizedBox(height: 8.0),
              Container(
                    width: 185, // Set the desired width
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  ),
              Container(
                    width: 185, // Set the desired width
                    child: Text(
                      product.price.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

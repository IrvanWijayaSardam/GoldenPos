import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customers.dart';
import '../providers/orders.dart';
import '../utils/utils.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);
    final customersProvider = Provider.of<Customers>(context, listen: false);
    final orderProvider = Provider.of<Orders>(context, listen: false);

    void _showProductDetails() {
      int quantity = 1; 
      String selectedCustomer = ''; 
      String selectedCustomerID = '';

      customersProvider.fetchAndSetCustomer().then((_) {
        showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setState) {
                int totalPrice =
                    product.price * quantity; 

                void _updateTotal(int newQuantity) {
                  setState(() {
                    quantity = newQuantity;
                    totalPrice =
                        product.price * quantity; 
                  });
                }

                return Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        'Product Code: ${product.code}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Price: ${Utils.formatCurrency(product.price)}'),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity:'),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                int newQuantity = int.tryParse(value) ?? 0;
                                _updateTotal(newQuantity);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pilih Pelanggan:'),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedCustomerID.isEmpty
                                  ? customersProvider.items.isNotEmpty
                                      ? customersProvider.items.first.id
                                          .toString()
                                      : null
                                  : selectedCustomerID,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCustomerID =
                                      newValue!; 
                                });
                              },
                              items: customersProvider.items.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer.id
                                      .toString(), 
                                  child: Text(customer.name),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                          'Total: ${Utils.formatCurrency(totalPrice)}'), 

                      ElevatedButton(
                        onPressed: () {
                          orderProvider
                              .createOrder(
                                selectedCustomerID
                                    .toString(), 
                                product.id
                                    .toString(),
                                quantity
                                    .toString(), 
                                totalPrice
                                    .toString(), 
                              )
                              .then((value) => {
                                    Navigator.of(context).pop(),
                                  });
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      });
    }

    return GestureDetector(
      onTap: _showProductDetails,
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
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Spacer(), 
              Container(
                width: double.infinity, 
                child: Text(Utils.formatCurrency(product.price),
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

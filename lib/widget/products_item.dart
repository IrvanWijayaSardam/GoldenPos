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

    // Function to show the product details in a BottomSheet
    void _showProductDetails() {
      int quantity = 1; // Default quantity
      String selectedCustomer = ''; // Default selected customer
      String selectedCustomerID = '';

      // Fetch customer data here before showing the modal
      customersProvider.fetchAndSetCustomer().then((_) {
        showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setState) {
                int totalPrice =
                    product.price * quantity; // Calculate the total price

                void _updateTotal(int newQuantity) {
                  setState(() {
                    quantity = newQuantity;
                    totalPrice =
                        product.price * quantity; // Recalculate the total price
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
                                      newValue!; // Set the selectedCustomerID
                                });
                              },
                              items: customersProvider.items.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer.id
                                      .toString(), // Use the customer ID as the value
                                  child: Text(customer.name),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                          'Total: ${Utils.formatCurrency(totalPrice)}'), // Display the total here

                      ElevatedButton(
                        onPressed: () {
                          orderProvider
                              .createOrder(
                                selectedCustomerID
                                    .toString(), // This might be an int
                                product.id
                                    .toString(), // product.id is cast to String
                                quantity
                                    .toString(), // quantity is cast to String
                                totalPrice
                                    .toString(), // totalPrice is cast to String
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
                // Remove width property to make it match the parent
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Spacer(), // Add Spacer to push the price to the bottom
              Container(
                width: double.infinity, // Set the desired width
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/products.dart';
import '../utils/utils.dart';
import '../providers/product.dart';
import '../providers/order.dart';
import '../providers/customers.dart';

class OrderItem extends StatelessWidget {
  final int orderId;
  final String createdAt;
  final String customerName;
  final int total;
  final int price;
  final int customerId;
  final int qty;
  final int productId;
  final TextEditingController quantityController = TextEditingController();

  OrderItem(this.orderId, this.createdAt, this.customerName, this.total,
      this.price, this.customerId, this.qty, this.productId);

  void _showOrderDetails(BuildContext context) {
    int quantity = 1; // Default quantity
    String selectedCustomerID = ''; // Default selected customer ID
    String selectedProductID = ''; // Default selected product ID

    final orderProvider = Provider.of<Orders>(context, listen: false);
    final customersProvider = Provider.of<Customers>(context, listen: false);
    final productsProvider = Provider.of<Products>(context, listen: false);

    Future.wait([
      customersProvider.fetchAndSetCustomer(),
      productsProvider.fetchAndSetProducts(),
    ]).then((_) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: StatefulBuilder(
              builder: (context, setState) {
                int totalPrice = total; // Calculate the total price

                void _updateTotal(int newQuantity) {
                  setState(() {
                    quantity = newQuantity;
                    totalPrice =
                        price * quantity; // Recalculate the total price
                  });
                }

                return Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$orderId',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        'Created At: $createdAt',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Customer: $customerName',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Price: ${Utils.formatCurrency(price)}'),
                      SizedBox(height: 16.0),
                      SizedBox(height: 16.0),
                      Text('Quantity: ${qty}'),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity:'),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: quantityController,
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
                                  selectedCustomerID = newValue!;
                                });
                              },
                              items: customersProvider.items.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer.id.toString(),
                                  child: Text(customer.name),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Select Product:'),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedProductID.isEmpty
                                  ? productsProvider.items.isNotEmpty
                                      ? productsProvider.items.first.id
                                          .toString()
                                      : null
                                  : selectedProductID,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedProductID = newValue!;
                                });
                              },
                              items: productsProvider.items.map((product) {
                                return DropdownMenuItem<String>(
                                  value: product.id.toString(),
                                  child: Text(product.name),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text('Total: ${Utils.formatCurrency(totalPrice)}'),
                      ElevatedButton(
                        onPressed: () {
                          String finalCustomerID = selectedCustomerID.isEmpty
                              ? customerId.toString()
                              : selectedCustomerID;

                          String finalProductID = selectedProductID.isEmpty
                              ? productId.toString()
                              : selectedProductID;

                          orderProvider
                              .updateOrder(
                            orderId.toString(),
                            finalCustomerID,
                            finalProductID,
                            quantityController.text.toString(),
                            totalPrice.toString(),
                          )
                              .then((value) {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text('Submit'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String finalCustomerID = selectedCustomerID.isEmpty
                              ? customerId.toString()
                              : selectedCustomerID;

                          String finalProductID = selectedProductID.isEmpty
                              ? productId.toString()
                              : selectedProductID;

                          orderProvider
                              .payOrder(
                            orderId.toString(),
                          )
                              .then((value) {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text('Pay'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final customersProvider = Provider.of<Customers>(context, listen: false);

    return Card(
      child: ListTile(
        title: Text('Order #$orderId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$createdAt'),
            Text(
              '$customerName - ${Utils.formatCurrency(total)}',
            ),
          ],
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showOrderDetails(context);
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  // Handle delete action
                },
                color: Theme.of(context).errorColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

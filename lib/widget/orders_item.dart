import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/customers.dart';
import '../utils/utils.dart';

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
    int quantity = qty; // Initialize quantity with the current quantity
    String selectedCustomerID =
        customerId.toString(); // Initialize with the current customer ID
    String selectedProductID =
        productId.toString(); // Initialize with the current product ID

    final orderProvider = Provider.of<Orders>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              int totalPrice = total; // Calculate the total price

              void _updateTotal(int newQuantity) {
                setState(() {
                  quantity = newQuantity;
                  totalPrice = price * quantity; // Recalculate the total price
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
                    Text('Quantity: $quantity'), // Display the current quantity
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
                        Text('Total: ${Utils.formatCurrency(totalPrice)}'),
                        ElevatedButton(
                          onPressed: () {
                            // Calculate the time difference between the current time and createdAt time
                            final DateTime orderCreatedAt =
                                DateTime.parse(createdAt);
                            final DateTime currentTime = DateTime.now();
                            final Duration difference =
                                currentTime.difference(orderCreatedAt);

                            // Check if the difference is less than or equal to 24 hours (86400 seconds)
                            if (difference.inSeconds <= 86400) {
                              // Order can be updated within 24 hours
                              orderProvider
                                  .updateOrder(
                                orderId.toString(),
                                selectedCustomerID,
                                selectedProductID,
                                quantity.toString(),
                                totalPrice.toString(),
                              )
                                  .then((value) {
                                Navigator.of(context).pop();
                              });
                            } else {
                              // Order is older than 24 hours, show a message to the user
                              Fluttertoast.showToast(
                                msg:
                                    "Orders can only be updated within 24 hours of creation.", // Use the extracted order ID
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmAndDeleteOrder(BuildContext context) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final ordersProvider = Provider.of<Orders>(context, listen: false);

    // Calculate the time difference between the current time and createdAt time
    final DateTime orderCreatedAt = DateTime.parse(createdAt);
    final DateTime currentTime = DateTime.now();
    final Duration difference = currentTime.difference(orderCreatedAt);

    // Check if the difference is less than or equal to 24 hours (86400 seconds)
    if (difference.inSeconds <= 86400) {
      // Order can be deleted
      // Show a confirmation dialog before deleting the order
      bool confirmDelete = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this Order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false); // Cancel the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true); // Confirm the deletion
              },
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        // User confirmed the deletion, so proceed to delete the order
        try {
          await ordersProvider.deleteOrder(orderId.toString());
          scaffoldMsg.showSnackBar(
            SnackBar(
              content: Text('Order deleted successfully.'),
            ),
          );
        } catch (error) {
          scaffoldMsg.showSnackBar(
            SnackBar(
              content: Text('Error deleting order: $error'),
            ),
          );
        }
      }
    } else {
      // Order is older than 24 hours, show a message to the user
      scaffoldMsg.showSnackBar(
        SnackBar(
          content:
              Text('Orders can only be deleted within 24 hours of creation.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  _confirmAndDeleteOrder(context);
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

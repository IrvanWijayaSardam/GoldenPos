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
    int quantity = qty;
    String selectedCustomerID = customerId.toString();
    String selectedProductID = productId.toString();

    final orderProvider = Provider.of<Orders>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              int totalPrice = total;

              void _updateTotal(int newQuantity) {
                setState(() {
                  quantity = newQuantity;
                  totalPrice = price * quantity;
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
                    Text('Quantity: $quantity'),
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
                            final DateTime orderCreatedAt =
                                DateTime.parse(createdAt);
                            final DateTime currentTime = DateTime.now();
                            final Duration difference =
                                currentTime.difference(orderCreatedAt);

                            if (difference.inSeconds <= 86400) {
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

    final DateTime orderCreatedAt = DateTime.parse(createdAt);
    final DateTime currentTime = DateTime.now();
    final Duration difference = currentTime.difference(orderCreatedAt);

    if (difference.inSeconds <= 86400) {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this Order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
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

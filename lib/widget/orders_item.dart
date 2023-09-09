import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../utils/utils.dart';

class OrderItem extends StatelessWidget {
  final int orderId;
  final String createdAt;
  final String customerName;
  final int total;

  OrderItem(this.orderId, this.createdAt, this.customerName, this.total);

  @override
  Widget build(BuildContext context) {
    final scaffoldMsg = ScaffoldMessenger.of(context);

    return Card(
      child: ListTile(
        title: Text('Order #$orderId'), // Display Order #ID
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$createdAt'), // Display Created at
            Text('$customerName - ${Utils.formatCurrency(total)}' ), // Display Customer name
          ],
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed("EditTransactionScreen.routeName", arguments: orderId);
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  // try {
                  //   await Provider.of<Orders>(context, listen: false)
                  //       .deleteTransaction(orderId);
                  // } catch (error) {
                  //   scaffoldMsg.showSnackBar(
                  //     SnackBar(
                  //       content: Text(
                  //         'Deleting failed!',
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   );
                  // }
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../utils/utils.dart';

class CustomerItem extends StatelessWidget {
  final int id;
  final String name;
  final String gender;
  final String phone;

  CustomerItem(this.id, this.name, this.gender, this.phone);

  @override
  Widget build(BuildContext context) {
    final scaffoldMsg = ScaffoldMessenger.of(context);

    return Card(
      child: ListTile(
        title: Text('$id'), // Display Order #ID
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name'), // Display Created at
            Text('$gender'), // Display Customer name
            Text('$phone'), // Display Customer name
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
                      .pushNamed("EditTransactionScreen.routeName", arguments: "orderId");
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

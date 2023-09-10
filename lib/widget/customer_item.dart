import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../utils/utils.dart';
import '../screens/customer_form.dart'; // Import your CustomerCreationForm widget

class CustomerItem extends StatelessWidget {
  final int id;
  final String name;
  final String gender;
  final String phone;

  CustomerItem(this.id, this.name, this.gender, this.phone);

  void _showEditCustomerForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // Pass the customer data as arguments to the CustomerForm
        return CustomerCreationForm(
          customerId: id,
          initialName: name,
          initialGender: gender,
          initialPhone: phone,
          isUpdate: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMsg = ScaffoldMessenger.of(context);

    return Card(
      child: ListTile(
        title: Text('$id'), // Display Customer ID
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name'), // Display Customer Name
            Text('$gender'), // Display Gender
            Text('$phone'), // Display Phone
          ],
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditCustomerForm(context);
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  // Handle delete action
                  // ...
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

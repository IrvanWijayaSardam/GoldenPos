import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customers.dart';
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
                  final customersProvider =
                      Provider.of<Customers>(context, listen: false);

                  // Show a confirmation dialog before deleting the customer
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text(
                          'Are you sure you want to delete this customer?'),
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
                    // User confirmed the deletion, so proceed to delete the customer
                    try {
                      await customersProvider.deleteCustomer(id.toString());
                      scaffoldMsg.showSnackBar(
                        SnackBar(
                          content: Text('Customer deleted successfully.'),
                        ),
                      );
                    } catch (error) {
                      scaffoldMsg.showSnackBar(
                        SnackBar(
                          content: Text(
                              'Error deleting customer.' + error.toString()),
                        ),
                      );
                    }
                  }
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

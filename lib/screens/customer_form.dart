import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customers.dart';

class CustomerCreationForm extends StatefulWidget {
  @override
  _CustomerCreationFormState createState() => _CustomerCreationFormState();
}

class _CustomerCreationFormState extends State<CustomerCreationForm> {
  String selectedGender = 'Male'; // Default gender value
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Customer',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            Text('Gender:'),
            Row(
              children: <Widget>[
                Radio(
                  value: 'male',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value.toString();
                    });
                  },
                ),
                Text('Male'),
                Radio(
                  value: 'female',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value.toString();
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final customersProvider = context.read<Customers>();
                final name = nameController.text;
                final phone = phoneController.text;
                customersProvider.createCustomer(name.toString(), selectedGender.toString(), phone.toString());
                Navigator.of(context).pop(); // Close the bottom sheet
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customers.dart';

class CustomerCreationForm extends StatefulWidget {
  final int customerId;
  final String initialName;
  final String initialGender;
  final String initialPhone;
  final bool isUpdate;

  CustomerCreationForm(
      {required this.customerId,
      required this.initialName,
      required this.initialGender,
      required this.initialPhone,
      required this.isUpdate});

  @override
  _CustomerCreationFormState createState() => _CustomerCreationFormState();
}

class _CustomerCreationFormState extends State<CustomerCreationForm> {
  late String selectedGender;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender ?? 'male';
    nameController.text = widget.initialName ?? '';
    phoneController.text = widget.initialPhone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isUpdate ? 'Update Customer' : 'Add Customer',
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
                Text('male'),
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
                if (widget.isUpdate) {
                  customersProvider.updateCustomer(
                    widget.customerId.toString(),
                    name.toString(),
                    selectedGender.toString(),
                    phone.toString(),
                  );
                  Navigator.of(context).pop();
                } else {
                  customersProvider.createCustomer(
                    name.toString(),
                    selectedGender.toString(),
                    phone.toString(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text(widget.isUpdate ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

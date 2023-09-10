import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customers.dart';
import '../widget/customer_item.dart';
import '../widget/app_drawer.dart';
import '../providers/auth.dart';

import 'customer_form.dart'; // Import your CustomerCreationForm widget

class CustomerScreen extends StatefulWidget {
  static const routeName = '/customer-screen';

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshCustomers(BuildContext context) async {
    await Provider.of<Customers>(context, listen: false).fetchAndSetCustomer();
  }

  void _onScroll() {
    // Pagination: Check if scrolled to the bottom
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<Customers>(context, listen: false).fetchAndSetCustomer();
    }
  }

  void _showCustomerCreationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return CustomerCreationForm(); // Show the CustomerCreationForm
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCustomerCreationForm(context); // Show the bottom sheet
            },
          ),
        ],
      ),
      drawer: Consumer<Auth>(
        builder: (ctx, auth, _) => AppDrawer(
          drawerTitle: auth.name ?? '',
        ),
      ),
      body: FutureBuilder(
        future: _refreshCustomers(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => _refreshCustomers(context),
              child: Consumer<Customers>(
                builder: (ctx, trxData, _) {
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      controller:
                          _scrollController, // Attach the scroll controller
                      itemCount: trxData.items.length,
                      itemBuilder: (_, i) {
                        return Column(
                          children: [
                            CustomerItem(
                              trxData.items[i].id,
                              trxData.items[i].name,
                              trxData.items[i].gender,
                              trxData.items[i].phone,
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

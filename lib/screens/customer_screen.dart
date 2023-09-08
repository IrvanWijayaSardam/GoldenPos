
import 'package:GoldenPos/widget/customer_item.dart';

import '../providers/orders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../providers/auth.dart';
import '../widget/orders_item.dart';
import '../providers/customers.dart';


import '../widget/app_drawer.dart';

class CustomerScreen extends StatelessWidget {
  static const routeName = '/customer-screen';

  Future<void> _refreshTransactions(BuildContext context) async {
    await Provider.of<Customers>(context, listen: false)
        .fetchAndSetCustomer();
  }

  @override
  Widget build(BuildContext context) {
    // final trxData = Provider.of<Transactions>(context);
    if (kDebugMode) {
      print('rebuilding...');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed("EditTransactionScreen.routeName");
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
        future: _refreshTransactions(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshTransactions(context),
                    child: Consumer<Customers> (builder: (ctx, trxData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: trxData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            CustomerItem(
                              trxData.items[i].id,
                              trxData.items[i].name,
                              trxData.items[i].gender,
                              trxData.items[i].phone,
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),)
                  ),
      ),
    );
  }
}

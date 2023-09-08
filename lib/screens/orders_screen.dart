import '../providers/orders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../providers/auth.dart';
import '../widget/orders_item.dart';

import '../widget/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/user-order';

  Future<void> _refreshTransactions(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false)
        .fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    // final trxData = Provider.of<Transactions>(context);
    if (kDebugMode) {
      print('rebuilding...');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Transactions'),
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
                    child: Consumer<Orders> (builder: (ctx, trxData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: trxData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            OrderItem(
                              trxData.items[i].id,
                              trxData.items[i].createdAt,
                              trxData.items[i].customer.name,
                              trxData.items[i].total,
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

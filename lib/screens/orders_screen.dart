import '../providers/orders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../providers/auth.dart';
import '../widget/orders_item.dart';
import '../widget/app_drawer.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/user-order';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
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

  Future<void> _refreshTransactions(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  void _onScroll() {
    // Pagination , check apakah scrool sampai bawah
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('rebuilding...');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      drawer: Consumer<Auth>(
        builder: (ctx, auth, _) => AppDrawer(
          drawerTitle: auth.name ?? '',
        ),
      ),
      body: FutureBuilder(
        future: _refreshTransactions(context),
        builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshTransactions(context),
                child: Consumer<Orders>(
                  builder: (ctx, trxData, _) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      controller: _scrollController, 
                      itemCount: trxData.items.length,
                      itemBuilder: (_, i) {
                        return Column(
                          children: [
                            OrderItem(
                              trxData.items[i].id,
                              trxData.items[i].createdAt,
                              trxData.items[i].customer.name,
                              trxData.items[i].total,
                              trxData.items[i].product.price,
                              trxData.items[i].customer.id,
                              trxData.items[i].qty,
                              trxData.items[i].product.id
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/products.dart';
import '../widget/app_drawer.dart';
import '../widget/products_item.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isLoading = false;
  var _isInit = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onScroll() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts();
      } catch (error) {
        _showErrorDialog('Failed to fetch more products: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GoldenPos'),
      ),
      drawer: Consumer<Auth>(
        builder: (ctx, auth, _) => AppDrawer(
          drawerTitle: auth.name ?? '',
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => Provider.of<Products>(context, listen: false)
                  .fetchAndSetProducts(),
              child: Column(
                children: [
                  Expanded(
                    child: ProductsGrid(_scrollController),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProductsGrid extends StatelessWidget {
  final ScrollController scrollController;

  ProductsGrid(this.scrollController);

  @override
  Widget build(BuildContext context) {
    final trxData = Provider.of<Products>(context);
    final products = trxData.items;

    return Visibility(
      visible: products != null && products.isNotEmpty,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: products[i],
          child: ProductItem(),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 4 / 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
      replacement: Center(child: Text('No Products available.')),
    );
  }
}

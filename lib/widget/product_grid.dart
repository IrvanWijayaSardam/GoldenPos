import '../widget/products_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final trxData = Provider.of<Products>(context);
    final products = trxData.items;

    return Visibility(
      visible: products != null && products.isNotEmpty,
      child: GridView.builder(
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

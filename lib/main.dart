
import 'package:GoldenPos/providers/customers.dart';
import 'package:GoldenPos/screens/customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './screens/home_screen.dart';

import '../providers/orders.dart';
import '../providers/products.dart';
import '../screens/orders_screen.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
              auth.jwtToken,
              previousProducts == null ? [] : previousProducts.items),
              create: (ctx) => Products('', [])
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
              auth.jwtToken,
              previousOrders == null ? [] : previousOrders.items),
              create: (ctx) => Orders('', [])
        ),
        ChangeNotifierProxyProvider<Auth, Customers>(
          update: (ctx, auth, previousOrders) => Customers(
              auth.jwtToken,
              previousOrders == null ? [] : previousOrders.items),
              create: (ctx) => Customers('', [])
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GoldenPos',
          theme: ThemeData(
            fontFamily: 'Lato', colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Color.fromARGB(255, 102, 255, 31)),
          ),
          home: auth.isAuth ? HomeScreen() : AuthScreen(),
          routes: {
            HomeScreen.routeName: (ctx) => HomeScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            CustomerScreen.routeName: (ctx) => CustomerScreen()
          },
        ),
      ),
    );
  }
}

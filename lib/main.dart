import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './screens/home_screen.dart';

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
        
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CashFlow',
          theme: ThemeData(
            fontFamily: 'Lato', colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Color.fromARGB(255, 102, 255, 31)),
          ),
          home: auth.isAuth ? HomeScreen() : AuthScreen(),
          routes: {
            HomeScreen.routeName: (ctx) => HomeScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen()
          },
        ),
      ),
    );
  }
}

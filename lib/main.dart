import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:portfolioapp_dsc/Model/portfolio.dart';
import 'package:portfolioapp_dsc/Screens/RegisterScreen.dart';

import 'package:provider/provider.dart';

import 'Model/user.dart';
import 'Screens/AddNewItem.dart';
import 'Screens/EditProfile.dart';
import 'Screens/MainScreen.dart';
import 'Screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<User>(create: (_) => User()),
        ChangeNotifierProvider<Portfolio>(create: (_) => Portfolio()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xff28334a),
          accentColor: Color(0xffFFE100),
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText1: TextStyle(fontSize: 18.0),
          ),
        ),
        //  home: Provider.of<User>(context, listen: false).loggedIn? RegisterPageUser() : MainScreen(),
        home: SplashScreen(),
        routes: {
          RegisterPageUser.routeName: (ctx) => RegisterPageUser(),
          MainScreen.routeName: (ctx) => MainScreen(),
          EditUserDetailScreen.routeName: (ctx) => EditUserDetailScreen(),
          NewPortfolioItemScreen.routeName: (ctx) => NewPortfolioItemScreen(),
        },
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portfolioapp_dsc/Model/user.dart';
import 'package:portfolioapp_dsc/Screens/RegisterScreen.dart';
import 'package:provider/provider.dart';

import 'MainScreen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    Future<bool> wait5Sec() async {
      await Future.delayed(const Duration(seconds: 2));
      isLoggedIn = Provider.of<User>(context, listen: false).loggedIn;
      // return Future.value(
      //     isLoggedIn ? MainScreen() : RegisterPageUser());
      return isLoggedIn;
    }

    return FutureBuilder(
      future: wait5Sec(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Portfolio App",
                  style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20,),
                Text(
                  "Flutter Bootcamp Week 04",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          final isLoggedIn = snap.data;
          return isLoggedIn ? MainScreen() : RegisterPageUser();
        }
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseUser;
import 'package:flutter/cupertino.dart';

class User extends ChangeNotifier {
  bool _isLoggedin = false;
  String userId;
  String email;
  String name;
  String title;
  String picture;

  User({
    this.userId,
    this.email,
    this.name,
    this.title,
    this.picture,
  });

  User.fromJson(Map<String, dynamic> json)
      : this.userId = json['userId'],
        this.email = json['email'],
        this.name = json['name'],
        this.title = json['title'],
        this.picture = json['picture'];

  Future<String> signIn(String email1, String pass1) async {
    var msg = '';
    FirebaseUser.UserCredential userCredential;
    try {
      userCredential = await FirebaseUser.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email1, password: pass1);
      userId = userCredential.user.uid;
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnap.data().isEmpty) {
        msg = 'Not Authorized';
      } else {
        _isLoggedin = true;
        notifyListeners();
      }
    } on FirebaseUser.FirebaseAuthException catch (e) {
      // print('Firebase Auth Exception');
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        msg = 'Wrong password provided for that user.';
      }
      msg = e.code;
    } catch (e) {
      print('Exception');
      print(e);
      msg = e.toString();
    }
    return msg;
  }

  bool get loggedIn {
    var currentUser = FirebaseUser.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _isLoggedin = true;
    }
    return _isLoggedin;
  }

  Future<String> setUser() async {
    String errormsg = '';
    if (FirebaseUser.FirebaseAuth.instance.currentUser != null ||
        name.isEmpty) {
      if (userId == null) {
        var currentUser = FirebaseUser.FirebaseAuth.instance.currentUser;
        final id = currentUser.uid;
        userId = id;
      }
      try {
        final userSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (!userSnap.exists) {
          errormsg = 'There Was An Error In Creating Your Account.';
          return errormsg;
        }
        final userInfo = userSnap.data();
        name = userInfo['name'];
        title = userInfo['title'];
        email = userInfo['email'];
        picture = userInfo['picture'];
      } catch (e) {
        print(e);
        if (e != null) errormsg = e.toString();
      }
    }
    return errormsg;
  }

  Future<String> registerUser(
      String emailAdd, String pass, String name, String title) async {
    var msg = '';
    try {
      final firebaseUser = await FirebaseUser.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emailAdd, password: pass);

      userId = firebaseUser.user.uid;
      email = emailAdd;
      name = name;
      title = title;
      picture =
          "https://cdn4.iconfinder.com/data/icons/small-n-flat/24/user-alt-512.png";
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {
          'email': email,
          'name': name,
          'title': title,
          'picture':
              "https://cdn4.iconfinder.com/data/icons/small-n-flat/24/user-alt-512.png",
        },
      );
    } on FirebaseUser.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Email Already In Use');
        msg = 'Email Already In Use';
      } else if (e.code == 'weak-password') {
        print('Weak password');
        msg = 'Weak password';
      }
      msg = e.code;
    } catch (e) {
      msg = '${e.toString()}';
      print(e);
    }
    // print('Register Function Finishing');
    _isLoggedin = true;
    return msg;
    // notifyListeners();
  }

  Future<void> editUserDetails(Map<String, dynamic> userInfo) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(
        {
          // 'email': email,
          'name': userInfo['name'],
          'title': userInfo['title'],
          if (userInfo['picture'] != '') 'picture': userInfo['picture'],
        },
      );
      if (userInfo['picture'] != '') picture = userInfo['picture'];
      name = userInfo['name'];
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return;
  }

  Future<void> signOut() async {
    try {
      await FirebaseUser.FirebaseAuth.instance.signOut();
      //await GoogleSignIn().signOut();
    } on FirebaseUser.FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    // userId = '';
    // name = '';
    _isLoggedin = false;

    notifyListeners();
    return;
  }

  // Future<String> changePassword(String password) async {
  //   final user = FirebaseUser.FirebaseAuth.instance.currentUser;
  //   var msg = '';
  //   user.updatePassword(password).then((_) {
  //     // print("Succesfull changed password");
  //   }).catchError((error) {
  //     print("Password can't be changed" + error.toString());
  //     msg = 'Password can\'t be changed ${error.toString()}';
  //     //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
  //   });
  //   return msg;
  // }

}

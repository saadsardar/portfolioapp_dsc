import 'package:flutter/material.dart';
import 'package:portfolioapp_dsc/Model/user.dart';
import 'package:provider/provider.dart';

import 'MainScreen.dart';

// final GoogleSignIn googleSignIn = GoogleSignIn();

class RegisterPageUser extends StatefulWidget {
  static const routeName = '/register-page-user';
  @override
  _RegisterPageUserState createState() => _RegisterPageUserState();
}

class _RegisterPageUserState extends State<RegisterPageUser> {
  FocusNode emailFocusNode, passwordFocusNode, nameFocusNode, titleFocusNode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formkey = GlobalKey<FormState>();
  bool _showpass = false;
  // ignore: unused_field
  String _email, _pass, _name, _title;
  bool _isLoading = false;
  bool isLogin = false;
  bool isAuth = false;

  @override
  initState() {
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    titleFocusNode = FocusNode();
    super.initState();
  }

  @override
  dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    nameFocusNode.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }



  Widget _showheading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Portfolio App",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _showtitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        isLogin ? 'Login' : 'Register',
        // style: Theme.of(context).textTheme.headline1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 25,
          //fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emailfield() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        focusNode: emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: (_) =>
            // isLogin ?
            passwordFocusNode.requestFocus(),
        // : phoneFocusNode.requestFocus(),
        onSaved: (val) => _email = val.trim(),
        validator: (val) => !val.contains('@') ? 'Invalid Email Address' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
            hintText: 'Enter Email Address',
            icon: Icon(Icons.mail)),
      ),
    );
  }

  Widget _namefield() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        focusNode: nameFocusNode,
        onFieldSubmitted: (a) => titleFocusNode.requestFocus(),
        onSaved: (val) => _name = val.trim(),
        validator: (val) => val.length < 4 ? 'Enter Valid Name' : null,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name ',
            hintText: 'Enter Name',
            icon: Icon(Icons.person)),
      ),
    );
  }

  Widget _titlefield() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        focusNode: titleFocusNode,
        onFieldSubmitted: (_) => _submit(),
        onSaved: (val) => _title = val.trim(),
        validator: (val) => val.length < 4 ? 'Enter Valid Title' : null,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Title ',
            hintText: 'Enter Title',
            icon: Icon(Icons.work)),
      ),
    );
  }

  Widget _passwordfield() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
        textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
        focusNode: passwordFocusNode,
        onSaved: (val) => _pass = val.trim(),
        validator: (val) => val.length < 6 ? 'Password Too Short' : null,
        obscureText: _showpass ? false : true,
        onFieldSubmitted: (a) =>
            isLogin ? _submit() : nameFocusNode.requestFocus(),
        decoration: InputDecoration(
            suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showpass = !_showpass;
                  });
                },
                child:
                    Icon(_showpass ? Icons.visibility_off : Icons.visibility)),
            border: OutlineInputBorder(),
            labelText: 'Password',
            hintText: 'Enter password. Min Length 6',
            icon: Icon(Icons.lock)),
      ),
    );
  }

  Widget _formActionButton() {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: _isLoading
          ? CircularProgressIndicator()
          : Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      'Submit',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Theme.of(context).primaryColor,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                      isLogin ? 'New User? Register' : 'Existing User? Login'),
                  onPressed: () {
                    emailFocusNode.unfocus();
                    nameFocusNode.unfocus();
                    titleFocusNode.unfocus();
                    passwordFocusNode.unfocus();
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                ),
              ],
            ),
    );
  }

  void _submit() async {
    emailFocusNode.unfocus();
    nameFocusNode.unfocus();
    titleFocusNode.unfocus();
    passwordFocusNode.unfocus();

    final form = _formkey.currentState;
    if (form.validate()) {
      form.save();

      // print('$_email $_pass $_phone');
      var msg = await _registerUser();
      // .then((value) {
      if (msg == '') {
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
        print("Login Successfull");
      } else {
        print('Invalid Entry');
        _failSnackbar(msg);
      }
    }
  }

  void _failSnackbar(String e) {
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          e,
          textAlign: TextAlign.center,
          style: TextStyle(),
        ));
    //_scaffoldKey.currentState.showSnackBar(snackBar);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String> _registerUser() async {
    var msg = '';
    setState(() {
      _isLoading = true;
    });
    if (isLogin) {
      msg =
          await Provider.of<User>(context, listen: false).signIn(_email, _pass);
    } else {
      msg = await Provider.of<User>(context, listen: false)
          .registerUser(_email, _pass, _name, _title);
    }
    print('After SignIn SignUp Msg : $msg');
    setState(() {
      _isLoading = false;
    });
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        // appBar: AppBar(
        //   title: Text("User"),
        // ),

        body: Center(
          child: ListView(
            children: [
              //_displayImage(),
              SizedBox(
                height: 50,
              ),
              _showheading(),
              _showtitle(),
              AnimatedContainer(
                duration: Duration(seconds: 2),
                // height: isLogin ? 300 : 450,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _emailfield(),
                          _passwordfield(),
                          if (!isLogin) _namefield(),
                          if (!isLogin) _titlefield(),
                          _formActionButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

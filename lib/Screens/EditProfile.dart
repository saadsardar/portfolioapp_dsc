import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolioapp_dsc/Model/user.dart';
import 'package:provider/provider.dart';

class EditUserDetailScreen extends StatefulWidget {
  static const routeName = '/edit-user-screen';
  @override
  _EditUserDetailScreenState createState() => _EditUserDetailScreenState();
}

class _EditUserDetailScreenState extends State<EditUserDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formkey = GlobalKey<FormState>();

  FocusNode nameFocusNode, titleFocusNode;

  String _name, _title;
  // DateTime _dob = DateTime.now();
  bool _isLoading = false;

  @override
  initState() {
    nameFocusNode = FocusNode();
    titleFocusNode = FocusNode();
    super.initState();
  }

  @override
  dispose() {
    nameFocusNode.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  File _pickedimage;

  ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<User>(context, listen: false);

    Future _getImage() async {
      var pickedimagefile = await _picker.getImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 250,
      );
      // print(pickedimagefile);
      setState(() {
        _pickedimage = File(pickedimagefile.path);
      });
    }

    Widget _imageField() {
      return Stack(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: _pickedimage != null
                ? FileImage(_pickedimage)
                : userDetails.picture == ''
                    ? AssetImage('assets/logo.png')
                    : NetworkImage(userDetails.picture),
            radius: 60,
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 35.0,
                width: 35.0,
                child: Icon(
                  Icons.person_add_alt,
                  color: Theme.of(context).primaryColor,
                  size: 25,
                ),
              ),
              onTap: () async {
                await _getImage();
                print('pressed');
              },
            ),
          ),
        ],
      );
    }

    Widget _nameTextfield() {
      return Padding(
        padding: EdgeInsets.only(top: 20),
        child: TextFormField(
          initialValue: userDetails.name,
          textInputAction: TextInputAction.next,
          focusNode: nameFocusNode,
          keyboardType: TextInputType.text,
          onFieldSubmitted: (_) => titleFocusNode.requestFocus(),
          onSaved: (val) => _name = val.trim(),
          validator: (val) =>
              val.length == 0 ? 'Field Can not be left Empty' : null,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Full Name',
              hintText: 'Enter Your Name',
              icon: Icon(Icons.person)),
        ),
      );
    }

    Widget _titlefield() {
      return Padding(
        padding: EdgeInsets.only(top: 20),
        child: TextFormField(
          initialValue: userDetails.title,
          textInputAction: TextInputAction.next,
          focusNode: titleFocusNode,
          // onFieldSubmitted: (_) => orgBioFocusNode.requestFocus(),
          onSaved: (val) => _title = val.trim(),
          validator: (val) =>
              val.length < 7 ? 'Enter Valid Phone Number' : null,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Phone Number',
              hintText: 'Enter Phone Number',
              icon: Icon(Icons.phone)),
        ),
      );
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

    void _submit() async {
      setState(() {
        _isLoading = true;
      });
      nameFocusNode.unfocus();
      titleFocusNode.unfocus();
      String dpurl = '';

      final form = _formkey.currentState;
      if (form.validate()) {
        form.save();
        print('$_name $_title');
        final userid = Provider.of<User>(context, listen: false).userId;
        if (_pickedimage != null) {
          // String fileName = Provider.of<User>(context, listen: false).userId.toString();
          final ref =
              FirebaseStorage.instance.ref().child('ProfilePic/$userid');
          // child('user_dp');
          await ref.putFile(_pickedimage);
          dpurl = await ref.getDownloadURL();
        }
        Map<String, dynamic> userInfo = {
          'name': _name,
          'title': _title,
          // 'dob': _dob,
          'picture': dpurl,
        };
        await Provider.of<User>(context, listen: false)
            .editUserDetails(userInfo);
      } else {
        print('Invalid Entry');
        _failSnackbar('Invalid Entry');
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (context) => MainScreen()),
      //     (Route<dynamic> route) => false);
    }

    Widget _formActionButton() {
      return Padding(
        padding: EdgeInsets.only(top: 20),
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
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
                ],
              ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Details'),
      ),
      body: Center(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _imageField(),
                        _nameTextfield(),
                        _titlefield(),
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
    );
  }
}

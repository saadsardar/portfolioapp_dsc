import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolioapp_dsc/Model/portfolio.dart';
import 'package:portfolioapp_dsc/Model/user.dart';
import 'package:provider/provider.dart';

class NewPortfolioItemScreen extends StatefulWidget {
  static const routeName = '/new-item-screen';
  @override
  _NewPortfolioItemScreenState createState() => _NewPortfolioItemScreenState();
}

class _NewPortfolioItemScreenState extends State<NewPortfolioItemScreen> {
  FocusNode nameFocusNode, descriptionFocusNode, typeFocusNode;
  final _formkey = GlobalKey<FormState>();
  String _name = '', _description = '', _type = 'education';
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  // ignore: unused_field
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();
    typeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    typeFocusNode.dispose();
    super.dispose();
  }

  Widget _showtitle() {
    return Text(
      'Add New Portfolio Item',
      style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
    );
  }

  Widget typeWidget(String variable) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
        textInputAction: TextInputAction.newline,
        focusNode: typeFocusNode,
        keyboardType: TextInputType.multiline,
        validator: (val) =>
            val.length > 0 ? null : 'Field Cannot Be Left Empty',
        onSaved: (val) => _type = val,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Type',
          hintText: 'Education or Experience',
          icon: Icon(Icons.work),
        ),
      ),
    );
  }

  int _radioCaseCampaign = 0;

  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioCaseCampaign = value;

      switch (_radioCaseCampaign) {
        case 0:
          _type = "education";
          break;
        case 1:
          _type = "experience";
          break;
      }
    });
  }

  Widget _choseFromEducationExperience() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Type', style: new TextStyle(fontSize: 20.0)),
        Radio(
          value: 0,
          groupValue: _radioCaseCampaign,
          onChanged: _handleRadioValueChange1,
        ),
        new Text(
          'Education',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Radio(
          value: 1,
          groupValue: _radioCaseCampaign,
          onChanged: _handleRadioValueChange1,
        ),
        new Text(
          'Experience',
          style: new TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget nameWidget(String variable) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
        textInputAction: TextInputAction.newline,
        focusNode: nameFocusNode,
        keyboardType: TextInputType.multiline,
        validator: (val) =>
            val.length > 0 ? null : 'Field Cannot Be Left Empty',
        onSaved: (val) => _name = val,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name',
          hintText: 'Enter Name',
          icon: Icon(Icons.file_copy),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2022));
    if (picked != null && picked != _date)
      setState(() {
        _date = picked;
      });
  }

  Widget _dateWidget(context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: ListTile(
        leading: Icon(
          Icons.calendar_today_outlined,
          color: Theme.of(context).primaryColor,
        ),
        title: Text('Date'),
        subtitle: Text(
          '${DateFormat.yMMMd().format(_date)}',
          style: TextStyle(fontSize: 15),
        ),
        trailing: ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text('Select date'),
        ),
      ),
    );
  }

  Widget descriptionWidget(String variable) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
        textInputAction: TextInputAction.newline,
        focusNode: descriptionFocusNode,
        keyboardType: TextInputType.multiline,
        // initialValue: _initvalues['Description'],
        maxLines: 4,
        validator: (val) =>
            val.length > 0 ? null : 'Field Cannot Be Left Empty',
        onSaved: (val) => _description = val,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Description',
          hintText: 'Enter Description',
          icon: Icon(Icons.description),
        ),
      ),
    );
  }

  _submit() async {
    setState(() {
      _isLoading = true;
    });
    var user = Provider.of<User>(context, listen: false).userId;
    Map<String, dynamic> newPortfolioItem = {
      'name': _name,
      'userID': user,
      'type': _type,
      'description': _description,
      'date': _date,
    };
    await Provider.of<Portfolio>(context, listen: false)
        .addNewPortfolio(newPortfolioItem);
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _isLoading
          ? CircularProgressIndicator()
          : TextButton(
              style: TextButton.styleFrom(
                shadowColor: Theme.of(context).primaryColor,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () {
                if (_formkey.currentState.validate() == false) {
                  return;
                }
                _formkey.currentState.save();
                print(_name);
                _submit();
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  // fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Center(
      //   child:
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _showtitle(),
                  _choseFromEducationExperience(),
                  nameWidget(_name),
                  descriptionWidget(_description),
                  _dateWidget(context),
                  _submitButton(),
                ],
              ),
            ),
          ),
        ),
        // ),
      ),
    );
  }
}

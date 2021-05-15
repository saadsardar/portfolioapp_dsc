import 'package:flutter/material.dart';
import 'package:portfolioapp_dsc/Model/portfolio.dart';
import 'package:portfolioapp_dsc/Model/user.dart';
import 'package:portfolioapp_dsc/Screens/RegisterScreen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'AddNewItem.dart';
import 'EditProfile.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main-user';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  User userInfo;
  List<PortfolioItem> experienceList = [];
  List<PortfolioItem> educationList = [];
  @override
  void didChangeDependencies() {
    setUser();
    super.didChangeDependencies();
  }

  setUser() async {
    if (educationList.isEmpty && educationList.isEmpty) {
      final response =
          await Provider.of<User>(context, listen: false).setUser();
      if (response == '') {
        userInfo = Provider.of<User>(context, listen: false);
        await Provider.of<Portfolio>(context, listen: false)
            .getPortfolioList(userInfo.userId);
        // //print(portfolioMap);
        // experienceList = portfolioMap['experience'] as List<PortfolioItem>;
        // //print(experienceList);
        // educationList = portfolioMap['education'] as List<PortfolioItem>;
        // print('Edu');
        // print(educationList.length);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    experienceList = Provider.of<Portfolio>(context).experienceList;
    educationList = Provider.of<Portfolio>(context).educationList;

    Widget buildListItem(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    buildHeading(String heading) {
      return Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          heading,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      );
    }

    buildPortfolioItem(PortfolioItem item) {
      return Dismissible(
        key: ValueKey(item.portfolioID),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Are you sure?'),
              content: Text(
                'Do you want to remove the item?',
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          Provider.of<Portfolio>(context, listen: false)
              .deletePortfolioItem(item.portfolioID, item.type);
        },
        child: ListTile(
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          subtitle: Text(
            item.description,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          trailing: Text(
            "${DateFormat.yMMMd().format(item.date)}",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(NewPortfolioItemScreen.routeName)
                    .then((value) {
                  // setState(() {});
                });
              })
        ],
        title: Text('Portfolio'),
      ),
      drawer: Drawer(
          child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Sign out',
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
            ),
            onTap: () async {
              await Provider.of<User>(context, listen: false).signOut();
              Navigator.of(context)
                  .pushReplacementNamed(RegisterPageUser.routeName);
            },
          ),
        ],
      )),
      body: userInfo == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Stack(
                children: [
                  Positioned(
                    top: 0.0,
                    child: Container(
                      height: size.height * 0.15,
                      width: size.width,
                      color: Theme.of(context).primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.075,
                    left: size.width * 0.35,
                    child: CircleAvatar(
                      radius: size.width * 0.15,
                      backgroundImage: NetworkImage(
                        userInfo.picture,
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.25,
                    child: Container(
                      // height: size.height * 0.7,
                      height: double.maxFinite,
                      width: size.width,
                      child: ListView(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width * 0.8,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      buildListItem(userInfo.name),
                                      buildListItem(userInfo.title),
                                      buildListItem(userInfo.email),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(
                                            EditUserDetailScreen.routeName)
                                        .then((value) {
                                      setState(() {});
                                    });
                                  })
                            ],
                          ),
                          SizedBox(height: 30),
                          if (educationList.isNotEmpty)
                            buildHeading('Education'),
                          if (educationList.isNotEmpty)
                            for (var item in educationList)
                              buildPortfolioItem(item),
                          if (experienceList.isNotEmpty)
                            buildHeading('Experience'),
                          if (experienceList.isNotEmpty)
                            for (var item in experienceList)
                              buildPortfolioItem(item),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

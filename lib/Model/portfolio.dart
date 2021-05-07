import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioItem {
  String portfolioID;
  String type;
  String userID;
  DateTime date;
  String name;
  String description;

  PortfolioItem({
    @required this.portfolioID,
    @required this.type,
    @required this.userID,
    @required this.date,
    @required this.name,
    @required this.description,
  });

  PortfolioItem.fromJson(Map<String, dynamic> json)
      : this.portfolioID = json['portfolioID'],
        this.type = json['type'],
        this.userID = json['userID'],
        this.date = json['date'].toDate(),
        this.name = json['name'],
        this.description = json['description'];
}

class Portfolio extends ChangeNotifier {
  List<PortfolioItem> _portfolioItemList = [];

  Future<Map<String, dynamic>> getPortfolioList(userID) async {
    _portfolioItemList = [];
    _portfolioItemList.remove(true);
    print('Getting Portfolio');
    try {
      final dataSnapshot = await FirebaseFirestore.instance
          .collection('portfolio')
          .where('userID', isEqualTo: userID)
          .get();
      final data = dataSnapshot.docs;
      data.forEach(
        (e) {
          var map = e.data();
          // print(map['name']);
          // print('Portfolio Added: ${map['name']}');
          map['portfolioID'] = e.id;
          _portfolioItemList.add(PortfolioItem.fromJson(map));
        },
      );
    } catch (e) {
      print(e);
    }
    print('done');
    _portfolioItemList.forEach((e) {
      // print('GetPortfolioList Func: ${e.name} ${e.organizationID} ${e.isActive()}');
    });
    List<PortfolioItem> education = [];
    List<PortfolioItem> experience = [];
    _portfolioItemList.forEach((e) {
      if (e.type == "education") {
        education.add(e);
      } else {
        experience.add(e);
      }
    });
    final map = {'education': education, 'experience': experience};
    //print(map);
    return map;
  }

  PortfolioItem getPortfoliobById(String id) {
    return _portfolioItemList.firstWhere((e) => e.portfolioID == id);
  }

  // ignore: missing_return
  Future<String> addNewPortfolio(
      Map<String, dynamic> newPortfolioItemDetails) async {
    // print('In Portfolio.dart $newPortfolioDetails');
    try {
      var newPortfolioItem =
          await FirebaseFirestore.instance.collection('portfolio').add({
        'name': newPortfolioItemDetails['name'],
        'userID': newPortfolioItemDetails['userID'],
        'description': newPortfolioItemDetails['description'],
        'date': newPortfolioItemDetails['date'],
        'type': newPortfolioItemDetails['type'],
      });

      _portfolioItemList.add(
        PortfolioItem(
          portfolioID: newPortfolioItem.id,
          name: newPortfolioItemDetails['name'],
          userID: newPortfolioItemDetails['userID'],
          description: newPortfolioItemDetails['description'],
          date: newPortfolioItemDetails['date'],
          type: newPortfolioItemDetails['type'],
        ),
      );
      return newPortfolioItem.id;
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  Future<void> editPortfolio(PortfolioItem portfolioItemDetails) async {
    // print('In Portfolio.dart $newPortfolioDetails');
    var i = _portfolioItemList.indexWhere(
        (element) => element.portfolioID == portfolioItemDetails.portfolioID);
    _portfolioItemList[i].name = portfolioItemDetails.name;
    _portfolioItemList[i].description = portfolioItemDetails.description;
    _portfolioItemList[i].date = portfolioItemDetails.date;
    _portfolioItemList[i].type = portfolioItemDetails.type;
    var updatedPortfolio = _portfolioItemList[i];

    try {
      await FirebaseFirestore.instance
          .collection('portfolio')
          .doc(updatedPortfolio.portfolioID)
          .update(
        {
          'name': updatedPortfolio.name,
          'description': updatedPortfolio.description,
          'date': updatedPortfolio.date,
          'title': updatedPortfolio.type,
        },
      );
    } catch (e) {
      print(e);
    }
    // print(_portfolioItemList[i].amountNeeded);
    notifyListeners();
  }

  Future<String> deleteCase(String portfolioID) async {
    String msg = '';
    try {
      await FirebaseFirestore.instance
          .collection('portfolio')
          .doc(portfolioID)
          .delete();
      _portfolioItemList.removeWhere((e) => e.portfolioID == portfolioID);
    } catch (e) {
      msg = e.toString();
    }
    notifyListeners();
    return msg;
  }
}

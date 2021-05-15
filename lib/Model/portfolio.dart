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
  List<PortfolioItem> _educationList = [];
  List<PortfolioItem> _experienceList = [];

  List<PortfolioItem> get educationList {
    return [..._educationList];
  }

  List<PortfolioItem> get experienceList {
    return [..._experienceList];
  }

  // Future<Map<String, dynamic>> getPortfolioList(userID) async {
  Future<void> getPortfolioList(userID) async {
    print('Getting Portfolio');
    _educationList = [];
    _experienceList = [];
    try {
      final dataSnapshot = await FirebaseFirestore.instance
          .collection('portfolio')
          .where('userID', isEqualTo: userID)
          .get();
      final data = dataSnapshot.docs;
      data.forEach(
        (e) {
          var map = e.data();
          map['portfolioID'] = e.id;
          if (map['type'] == 'education') {
            _educationList.add(PortfolioItem.fromJson(map));
          } else {
            _experienceList.add(PortfolioItem.fromJson(map));
          }
        },
      );
    } catch (e) {
      print(e);
    }

    // final map = {
    //   'education': [..._educationList],
    //   'experience': [..._experienceList]
    // };
    // return map;
  }

  Future<void> addNewPortfolio(
      Map<String, dynamic> newPortfolioItemDetails) async {
    try {
      var newPortfolioItem =
          await FirebaseFirestore.instance.collection('portfolio').add({
        'name': newPortfolioItemDetails['name'],
        'userID': newPortfolioItemDetails['userID'],
        'description': newPortfolioItemDetails['description'],
        'date': newPortfolioItemDetails['date'],
        'type': newPortfolioItemDetails['type'],
      });

      final newPotfolio = new PortfolioItem(
        portfolioID: newPortfolioItem.id,
        name: newPortfolioItemDetails['name'],
        userID: newPortfolioItemDetails['userID'],
        description: newPortfolioItemDetails['description'],
        date: newPortfolioItemDetails['date'],
        type: newPortfolioItemDetails['type'],
      );

      if (newPotfolio.type == 'education') {
        _educationList.add(newPotfolio);
      } else {
        _experienceList.add(newPotfolio);
      }
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  Future<String> deletePortfolioItem(String portfolioID, String type) async {
    String msg = '';
    try {
      await FirebaseFirestore.instance
          .collection('portfolio')
          .doc(portfolioID)
          .delete();

      if (type == 'education') {
        _educationList.removeWhere((e) => e.portfolioID == portfolioID);
      } else {
        _experienceList.removeWhere((e) => e.portfolioID == portfolioID);
      }
    } catch (e) {
      msg = e.toString();
    }
    notifyListeners();
    return msg;
  }
}

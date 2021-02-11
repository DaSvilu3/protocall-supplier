import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/components/requestComponent.dart';
import 'package:supplier/screens/chatImage.dart';
import 'package:supplier/screens/dashbaord/orders_request/requests.dart';
import 'package:supplier/screens/showImage.dart';
import 'package:supplier/utils/colors.dart';
import 'package:supplier/widgets/customTab.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class OrdersRequestsPage extends StatefulWidget {
  OrdersRequestsPage({this.openSlideView});
  VoidCallback openSlideView;
  @override
  _OrdersRequestsPageState createState() => _OrdersRequestsPageState();
}

class _OrdersRequestsPageState extends State<OrdersRequestsPage> {
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  String user_uid = "";
  List items = [];
  bool isLoading = false;
  bool isSub = false;
  Map status = {
    "accepted": {"color": Color(0xff3366cc), "title": "Accepted"},
    "in-progress": {"color": Color(0xff990099), "title": "In Progress"},
    "completed": {"color": Color(0xff109618), "title": "Completed"},
    "canceled": {"color": Color(0xfffdbe19), "title": "Canceled"},
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      var groupID = sp.get("groupID").toString();
      setState(() {
        if (groupID != null) {
          user_uid = groupID;
          getData();
        } else {
          print("error");
        }
      });
    });
    var value = FirebaseAuth.instance.currentUser;

    if (value != null) {
      setState(() {
        print(user_uid);
        user_uid = value.uid;
        getData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: choices.length,
      child: Scaffold(
        backgroundColor: Color(0xffFAFAFA),
        appBar: AppBar(
          backgroundColor: Color(0xffFAFAFA),
          leading: new IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                widget.openSlideView();
              }),
          title: Text(
            'Requests Page',
            style: GoogleFonts.comfortaa(),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: purpleColor,
            tabs: choices.map((Choice choice) {
              return Tab(
                text: choice.title,
              );
            }).toList(),
          ),
        ),
        body: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : items.length == 0
                ? new Center(
                    child: new Text(
                      "No Orders for you",
                      style: GoogleFonts.comfortaa(),
                    ),
                  )
                : TabBarView(
                    children: [
                      _listItem("All"),
                      _listItem("accepted"),
                      _listItem("in-progress"),
                      _listItem("completed"),
                      _listItem("canceled"),
                    ],
                  ),
      ),
    );
  }

  Widget _listItem(category) {
    List list = items;
    if (category == "All") {
      list = items;
    } else {
      list = items.where((element) => element["status"] == category).toList();
    }
    if (list == null) return new ListView();
    return list.length == 0
        ? Center(
            child: new Text(
              "No Order in this category",
              style: GoogleFonts.comfortaa(),
            ),
          )
        : new ListView(
            children: list.map((e) {
              if (e != null ||
                  e["key"] != null &&
                      category != "All" &&
                      category == e["status"]) {
                return OrderRequestItem(
                  item: e,
                );
              }
            }).toList(),
          );
  }

  void getData() async {
    setState(() {
      isLoading = true;
      items = [];
    });
    try {
      firestoreInstance
          .collection("request")
          .where("supplier", isEqualTo: user_uid)
          .get()
          .then((value) {
        if (value.docs.length == 0 || value == null) {
          setState(() {
            isLoading = false;
          });
        }
        value.documents.forEach((element) {
          var temp = element.data();
          temp["key"] = element.id;

          items.add(temp);
          setState(() {
            print(temp);
            isLoading = false;
          });
        });
      });
    } catch (e) {
      setState(() {
        print("Error Error");

        isLoading = false;
      });
    }
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'All', icon: Icons.directions_car),
  const Choice(title: 'Accepted', icon: Icons.directions_bike),
  const Choice(title: 'In Progress', icon: Icons.directions_boat),
  const Choice(title: 'Completed', icon: Icons.directions_bus),
  const Choice(title: 'Canceled', icon: Icons.directions_railway),
];

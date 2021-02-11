import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/screens/auth/register.dart';
import 'package:supplier/screens/dashbaord/dashboatd.dart';
import 'package:supplier/screens/dashbaord/orders_request/index.dart';
import 'package:supplier/screens/dashbaord/products/list.dart';
import 'package:supplier/screens/dashbaord/profile/show.dart';
import 'package:supplier/screens/dashbaord/services/list.dart';
import 'package:supplier/utils/category_list.dart';
import 'package:supplier/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool isLeftOpened = false;
  var content;
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initNecceryData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        child: new Stack(
      children: [
        content,
        !isLeftOpened
            ? new Container(
                width: 0,
                height: 0,
              )
            : _buildSideNavbar(size)
      ],
    ));
  }

  initNecceryData() {
    CategoryClasses();

    FirebaseFirestore.instance
        .collection("services_category_second")
        .get()
        .then((value) {
      CategoryClasses.CATEGORY_LIST = [];

      value.docs.forEach((element) {
//        print(element.data);
        element.data()["key"] = element.id;

        CategoryClasses.CATEGORY_LIST.add(element.data());
      });
//      print("json file");
//      print(json.encode(CategoryClasses.CATEGORY_LIST));
    });
    FirebaseFirestore.instance
        .collection("product_category_second")
        .get()
        .then((value) {
      CategoryClasses.PRODUCTS_LIST = [];
      value.docs.forEach((element) {
        print(json.encode(element.data()) + ",");
        CategoryClasses.PRODUCTS_LIST.add(element.data());
      });
    });
    SharedPreferences.getInstance().then((sp) {
      String group_id = sp.getString("groupID");
      if (group_id != null) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(group_id)
            .snapshots()
            .forEach((element) {
          saveMainData(element);
        });

        final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

        _firebaseMessaging.getToken().then((token) {
          print(token);
          FirebaseFirestore.instance
              .collection("users")
              .doc(group_id)
              .update({"token": token});
        });
      }
    });

    content = DashboardContentPage(
      openSlideView: openSlideView,
    );
  }

  saveMainData(element) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("uid", element()["UID"]);
    pref.setString("name", element()["name"]);
    pref.setString("profile_photo", element()["profile"]);
    print(pref.get("uid").toString() + " is my uid  ");
  }

  Widget _buildSideNavbar(size) {
    return new Container(
      width: 80,
      padding: new EdgeInsets.only(left: 0),
      margin: new EdgeInsets.only(left: 0),
      height: size.height + 50,
      decoration: new BoxDecoration(
          color: new Color(0xffEEEEEE),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: new BorderRadius.only(
              topRight: new Radius.circular(50),
              bottomRight: Radius.circular(50))),
      child: Scaffold(
//                  backgroundColor: Colors.transparent,
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDrawerItem(
                Icons.home,
                DashboardContentPage(
                  openSlideView: openSlideView,
                ),
                0),
            _buildDrawerItem(
                Icons.list,
                ServicesListPage(
                  openSlideView: openSlideView,
                ),
                1),
            _buildDrawerItem(
                Icons.apps, ProductsListPage(openSlideView: openSlideView), 2),
            _buildDrawerItem(Icons.shop,
                OrdersRequestsPage(openSlideView: openSlideView), 3),
            _buildDrawerItem(
                Icons.person, ProfilePage(openSlideView: openSlideView), 4),
            _buildDrawerItem(Icons.exit_to_app, null, 5),
            new SizedBox(
              height: 32,
            ),
            _buildDrawerItem(Icons.clear, null, -9),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(icon, next, item) {
    return Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.all(10),
      decoration: new BoxDecoration(
          color: index == item ? purpleColor : Color(0xffBFBFBF),
          borderRadius: new BorderRadius.circular(10)),
      child: new Card(
        elevation: 0,
        color: index == item ? purpleColor : Color(0xffBFBFBF),
        child: new Center(
          child: new IconButton(
              icon: Icon(
                icon,
                color: index == item ? Colors.white : Colors.white,
              ),
              onPressed: () {
                if (item == 5) {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (content) => RegisterPage()));
                  });
                } else if (next == null) {
                  setState(() {
                    isLeftOpened = false;
                  });
                } else {
                  setState(() {
                    content = next;
                    index = item;
                    isLeftOpened = false;
                  });
                }
              }),
        ),
      ),
    );
  }

  void openSlideView() {
    print('here is back');
    setState(() {
      isLeftOpened = true;
    });
  }

//  Future<String> get _localPath async {
////    final directory = await  ();
//
//    return directory.path;
//  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/components/serviceItem.dart';
import 'package:supplier/screens/dashbaord/services/add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supplier/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesListPage extends StatefulWidget {
  final VoidCallback openSlideView;
  ServicesListPage({this.openSlideView});

  @override
  _ServicesListPageState createState() => _ServicesListPageState();
}

class _ServicesListPageState extends State<ServicesListPage> {
  String user_uid = "";
  final firestoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  List items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((sp) {
      var groupID = sp.get("groupID").toString();
      setState(() {
        print(user_uid);
        user_uid = groupID;
        isLoading = false;
      });
    });
//    FirebaseAuth.instance.currentUser().then((value) {
//      if (value != null) {
//        setState(() {
//          print(user_uid);
//          user_uid = value.uid;
//          isLoading = false;
//        });
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        leading: widget.openSlideView == null
            ? InkWell(
                child: new Icon(Icons.clear),
                onTap: () {
                  Navigator.of(context).pop();
                })
            : InkWell(
                child: new Icon(Icons.menu),
                onTap: () {
                  widget.openSlideView();
                },
              ),
        title: Text('Services List', style: GoogleFonts.comfortaa()),
      ),
      floatingActionButton: FloatingActionButton(
        child: new Icon(Icons.add),
        backgroundColor: purpleColor,
        onPressed: () => navigate(AddServicePage()),
      ),
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .where("owner", isEqualTo: user_uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return snapshot.data.docs.length == 0
                        ? Center(
                            child: new Text("You didn't add any services yet",
                                style: GoogleFonts.comfortaa()),
                          )
                        : new ListView(
                            children: snapshot.data.docs
                                .map((DocumentSnapshot document) {
                            Map d = document.data();
                            d["key"] = document.id;
                            return ServicesListItem(
                              elemnt: d,
                              callback: getData,
                            );
                          }).toList());
                }
              },
            ),
    );
  }

  void getData() async {
    setState(() {});
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  void showAddServices() {
    navigate(AddServicePage(
      onAddedDone: getData,
    ));
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/components/productslistItem.dart';
import 'package:supplier/screens/dashbaord/products/add.dart';
import 'package:supplier/screens/dashbaord/products/edit.dart';
import 'package:supplier/screens/dashbaord/services/add.dart';
import 'package:supplier/screens/showImage.dart';
import 'package:supplier/utils/category_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supplier/utils/colors.dart';

class ProductsListPage extends StatefulWidget {
  ProductsListPage({this.openSlideView});
  VoidCallback openSlideView;
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  String user_uid = "NNextUser";
  final firestoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      var groupID = sp.get("groupID").toString();
      setState(() {
        print(user_uid);
        user_uid = groupID;
        isLoading = false;
      });
    });
  }

  void getData() async {
    setState(() {
      isLoading = true;
//      items = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    print(items.length);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
                }),
        title: Text('Products List', style: GoogleFonts.comfortaa()),
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      floatingActionButton: FloatingActionButton(
        child: new Icon(Icons.add),
        backgroundColor: purpleColor,
        onPressed: () => navigate(AddProductPage()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where("owner", isEqualTo: user_uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return snapshot.data.documents.length == 0
                  ? new Center(
                      child: new Text("You didn't add any products"),
                    )
                  : new ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                      Map d = document.data();
                      d["key"] = document.id;
//                        document.data["key"] = document.documentID;
                      return ProductListItem(
                        element: d,
                        callback: getData,
                      );
                    }).toList());
          }
        },
      ),
    );
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  void showAddServices() {
    navigate(AddServicePage(
      onAddedDone: getData,
    ));
//    Size size = MediaQuery.of(context).size;
//    showModalBottomSheet(
//        context: context,
//        builder: (builder){
//          return new Container(
//            height: size.height * 01 ,
//            color: Colors.transparent, //could change this to Color(0xFF737373),
//            //so you don't have to change MaterialApp canvasColor
//            child: AddServicePage());
//        }
//    );
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/screens/dashbaord/orders_request/requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supplier/utils/locations.dart' as loc;
import 'package:supplier/utils/category_list.dart';
import 'package:supplier/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/utils/uploadMedia.dart';
import 'package:supplier/components/MediaPicture.dart';

enum ProfileLanguage { Arabic, English }

//import 'date';
class AddProductPage extends StatefulWidget {
  final VoidCallback onAddedDone;
  AddProductPage({this.onAddedDone});
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final firestoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  bool haveShipping = false;

  String user_uid = "NNextUser";
  List<Map> photos = [];
  TextEditingController contollerTitle = new TextEditingController();
  TextEditingController contollerPrice = new TextEditingController();
  TextEditingController contollerShipping = new TextEditingController();
  TextEditingController contollerDescription = new TextEditingController();

  TextEditingController contollerTitleAR = new TextEditingController();
  TextEditingController contollerDescriptionAR = new TextEditingController();
  ProfileLanguage profileLang = ProfileLanguage.English;
  String main_value = "";
  String sub_value = "";
  Set<String> sub_category = new Set<String>();
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
//    FirebaseAuth.instance.currentUser().then((value) {
//      if (value != null) {
//        setState(() {
//          print(user_uid);
//          isLoading = false;
//          user_uid = value.uid;
//        });
//      }
//    });
    main_value = new CategoryClasses().getProductsMainCategory().elementAt(0);
    print("main value is : " + main_value);
    sub_category = new CategoryClasses().getProductsMainSubs(main_value);
    print("subs are");
    print(sub_category);
    sub_value = sub_category.elementAt(0);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(photos);
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          "Add Product",
          style: GoogleFonts.comfortaa(),
        ),
      ),
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new Container(
              padding: new EdgeInsets.all(16),
              child: new SingleChildScrollView(
                  child: new Column(
                children: [
                  new SizedBox(
                    height: 16,
                  ),
                  new ListTile(
                    title: new Text("Main Category",
                        style: GoogleFonts.comfortaa()),
                    trailing: DropdownButton<String>(
                      value: main_value,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.comfortaa(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          main_value = newValue;
                          sub_category = new CategoryClasses()
                              .getProductsMainSubs(main_value);
                          sub_value = sub_category.elementAt(0);
                        });
                      },
                      items: new CategoryClasses()
                          .getProductsMainCategory()
                          .toList()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  sub_value == "Other"
                      ? new TextField(
                          controller: contollerTitle,
                          decoration: new InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(16),
                              labelText: "Service Title",
                              hintText: "Service Title",
                              labelStyle:
                                  GoogleFonts.comfortaa(color: purpleColor)),
                        )
                      : new ListTile(
                          title: new Text(
                            "Sub Category",
                            style: GoogleFonts.comfortaa(),
                          ),
                          trailing: DropdownButton<String>(
                            value: sub_value,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.white,
                            style:
                                GoogleFonts.comfortaa(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                sub_value = newValue;
                              });
                            },
                            items: sub_category
                                .toList()
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                  new SizedBox(
                    height: 16,
                  ),
                  new Row(
                    children: [
                      new FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              profileLang = ProfileLanguage.English;
                            });
                          },
                          color: profileLang == ProfileLanguage.English
                              ? Colors.lightGreen
                              : Colors.white,
                          icon: Icon(Icons.language),
                          label: new Text("English Data")),
                      new FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              profileLang = ProfileLanguage.Arabic;
                            });
                          },
                          color: profileLang == ProfileLanguage.Arabic
                              ? Colors.lightGreen
                              : Colors.white,
                          icon: Icon(Icons.language),
                          label: new Text("بيانات  بالعربي"))
                    ],
                  ),
                  new SizedBox(
                    height: 8,
                  ),
                  profileLang == ProfileLanguage.English
                      ? new Column(
                          children: [
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              controller: contollerTitle,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(16),
                                  labelText: "Product Name",
                                  hintText: "Product Name",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 6,
                              maxLines: 10,
                              controller: contollerDescription,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(16),
                                  labelText: "Product Descriptions",
                                  hintText: "Details about the product",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                          ],
                        )
                      : new Column(
                          children: [
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              controller: contollerTitleAR,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(16),
                                  labelText: "اسم المنتج",
                                  hintText: "اسم المنتج",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 6,
                              maxLines: 10,
                              controller: contollerDescriptionAR,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(16),
                                  labelText: "وصف المنتج",
                                  hintText: "وصف المنتج",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                          ],
                        ),
                  new SizedBox(
                    height: 16,
                  ),
                  new TextField(
                    controller: contollerPrice,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(16),
                        labelText: "Product Price",
                        hintText: "product price",
                        labelStyle: GoogleFonts.comfortaa(color: purpleColor)),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  haveShipping
                      ? new Container(
                          height: 0.5,
                        )
                      : new TextField(
                          controller: contollerShipping,
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(16),
                              labelText: "Shipping Price",
                              hintText: "Shipping price",
                              labelStyle:
                                  GoogleFonts.comfortaa(color: purpleColor)),
                        ),
                  new SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Container(
                        child: new Checkbox(
                            value: haveShipping,
                            onChanged: (con) {
                              setState(() {
                                haveShipping = !haveShipping;
                              });
                            }),
                      ),
                      new Container(
                        child: new Text('shipping not provided'),
                      )
                    ],
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: size.width,
                    child: new Text(
                      "Product Images",
                      style: GoogleFonts.comfortaa(),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    height: 90,
                    child: new ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: new Card(
                            child: new InkWell(
                              onTap: () {
                                setState(() {
                                  isLoading = true;
                                });
                                new UploadMediatoFB()
                                    .photoOption(0)
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (value != null) {
                                    photos.add({
                                      "type": 0,
                                      "url": value["main"],
                                      "thumb": value["thumb"]
                                    });
                                    setState(() {});
                                    showSnackBar();
                                  }
                                });
                              },
                              child: Center(
                                child: new Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        )
                      ]..addAll(photos.map((e) => MediaComponent(
                            map: e,
                            index: photos.indexOf(e),
                            removeItem: (i) {
                              setState(() {
                                photos.removeAt(i);
                              });
                            },
                          ))),
                    ),
                  ),
                ]..add(new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Container(
                        width: size.width * 0.25,
                        decoration: new BoxDecoration(
                            color: grayColor,
                            borderRadius: new BorderRadius.circular(16)),
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: new Center(
                            child: new Text(
                              "Cancel",
                              style: GoogleFonts.comfortaa(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      new Container(
                        width: size.width * 0.25,
                        decoration: new BoxDecoration(
                            color: purpleColor,
                            borderRadius: new BorderRadius.circular(16)),
                        child: OutlineButton(
                          onPressed: () {
                            saveData();
                          },
                          child: new Center(
                            child: new Text(
                              "Add",
                              style: GoogleFonts.comfortaa(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              ))),
    );
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  void saveData() {
    if (contollerTitle.text.replaceAll(" ", "").length == 0 ||
        contollerDescription.text.replaceAll(" ", "").length == 0 ||
        contollerPrice.text.replaceAll(" ", "").length == 0) {
      showSnackBarError('Please Enter all required values');
    }
    if (contollerTitleAR.text.replaceAll(" ", "").length == 0 ||
        contollerDescriptionAR.text.replaceAll(" ", "").length == 0) {
      showSnackBarError("الرجاء ملئ البيانات بالعربي");
      setState(() {
        profileLang = ProfileLanguage.Arabic;
      });
    } else {
      setState(() {
        isLoading = true;
      });

      firestoreInstance.collection("products").add({
        "title": contollerTitle.text.toString(),
        "description": contollerDescription.text.toString(),
        "titleAR": contollerTitleAR.text.toString(),
        "descriptionAR": contollerDescriptionAR.text.toString(),
        "photos": photos,
        "owner": user_uid,
        "price": contollerPrice.text,
        "shipping": haveShipping ? "0" : contollerShipping.text,
        "time": DateTime.now().toIso8601String(),
        "category": sub_value,
        "maincategory": main_value,
        "category_id": CategoryClasses().getSubProductId(sub_value),
//      "locations" : selected_cities.toList()
      }).then((s) {
        isLoading = false;
        widget.onAddedDone != null ? widget.onAddedDone() : print("object");

        Navigator.of(context).pop();
//        firestoreInstance
//            .collection("users")
//            .document(user_uid)
//            .collection("products")
//            .add({"id": s.documentID}).then((value) {
//          setState(() {
//            isLoading = false;
//            widget.onAddedDone != null ? widget.onAddedDone() : print("object");
//
//          });
//        });
      });
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar() {
    final snackBar = SnackBar(
      content: Text('Done uploading media'),
      action: SnackBarAction(
        label: 'clear',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void showSnackBarError(txt) {
    final snackBar = SnackBar(
      content: Text(txt),
      action: SnackBarAction(
        label: 'clear',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}

/*
1
comment
"gg"
created_at
"2020-12-01T12:40:27.710914"
customer
"jbDD3MMoGfgDfLTBHJ4ZcPmnpor1"
arrow_drop_down
customerObj
id
"jbDD3MMoGfgDfLTBHJ4ZcPmnpor1"
name
""
phone
"+96899229922"
location
null
arrow_drop_down
products
0
"RySsCmu6KmFIR6IEnCD4"
requestID
"020ddceb367649ceae535314ebbb9468"
status
"accepted"
supplier
"101f4edc23474bf986c32f4d38177bf2"
type
"product"
 
Cloud Firestore location: nam5 (us-central)

*/

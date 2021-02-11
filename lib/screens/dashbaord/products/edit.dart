import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supplier/components/MediaPicture.dart';
import 'package:supplier/utils/category_list.dart';
import 'package:supplier/utils/colors.dart';
import 'package:supplier/utils/uploadMedia.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

enum ProfileLanguage { Arabic, English }

class EditProductPage extends StatefulWidget {
  EditProductPage({this.data, this.callBack});
  final Map data;
  VoidCallback callBack;
  @override
  _EditProductPageState createState() => _EditProductPageState(data: this.data);
}

class _EditProductPageState extends State<EditProductPage> {
  final Map data;
  _EditProductPageState({this.data});
  bool haveShipping = false;

  final firestoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  String user_uid = "NNextUser";
  TextEditingController contollerTitle = new TextEditingController();
  TextEditingController contollerPrice = new TextEditingController();
  TextEditingController contollerDescription = new TextEditingController();
  TextEditingController contollerTitleAR = new TextEditingController();
  TextEditingController contollerDescriptionAR = new TextEditingController();
  TextEditingController contollerShipping = new TextEditingController();

  List<Map> photos = [];
  ProfileLanguage profileLang = ProfileLanguage.English;

  String main_value = "";
  String sub_value = "";
  Set<String> sub_category = new Set<String>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    contollerTitle = new TextEditingController(text: data["title"] ?? "");
    contollerDescription =
        new TextEditingController(text: data["description"] ?? "");

    contollerTitleAR = new TextEditingController(text: data["titleAR"] ?? "");
    contollerDescriptionAR =
        new TextEditingController(text: data["descriptionAR"] ?? "");
    contollerPrice = new TextEditingController(text: data["price"] ?? "");
    contollerShipping =
        new TextEditingController(text: data["shipping"] ?? "0");

    if (contollerShipping.text == "0") {
      haveShipping = true;
    }

    CategoryClasses.PRODUCTS_LIST.forEach((element) {
      if (element["sub"] == data["category"]) {
        main_value = element["main"];
        sub_value = data["category"];
        sub_category = new CategoryClasses().getProductsMainSubs(main_value);
      }
    });

    try {
      List photo = data["photos"];
      photo.forEach((element) {
        photos.add(element);
      });
    } catch (e) {
      photos = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
//    print(photos);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Edit Product',
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
                    title: new Text("Main Category"),
                    trailing: DropdownButton<String>(
                      value: main_value,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.deepPurple),
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
                          title: new Text("Sub Category"),
                          trailing: DropdownButton<String>(
                            value: sub_value,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.white,
                            style: TextStyle(color: Colors.deepPurple),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          label: new Text("بيانات بالعربي"))
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
                                  labelText: "Product Title",
                                  hintText: "Product Title",
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
                                UploadMediatoFB().photoOption(0).then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (value != null) {
                                    photos.add({
                                      "url": value["main"],
                                      "thumb": value["thumb"],
                                      "type": 0
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
                  new SizedBox(
                    height: 16,
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
                            updateData();
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

  void updateData() async {
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
      firestoreInstance.collection("products").doc(data["key"]).update({
        "title": contollerTitle.text.toString(),
        "description": contollerDescription.text.toString(),
        "photos": photos,
        "price": contollerPrice.text,
        "category_id": CategoryClasses().getSubProductId(sub_value),

        "category": sub_value,
        "titleAR": contollerTitleAR.text.toString(),
        "descriptionAR": contollerDescriptionAR.text.toString(),
        "shipping": haveShipping ? "0" : contollerShipping.text,

        "maincategory": main_value,
//      "time": DateTime.now().toIso8601String()
      }).then((value) {
        isLoading = false;
        widget.callBack();
        Navigator.of(context).pop();
      });
    }
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
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

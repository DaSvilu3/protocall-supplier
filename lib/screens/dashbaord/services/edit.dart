import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supplier/components/MediaPicture.dart';
import 'package:supplier/utils/category_list.dart';
import 'package:supplier/utils/colors.dart';
import 'package:supplier/utils/locations.dart' as loc;
import 'package:supplier/utils/uploadMedia.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';

enum ProfileLanguage { Arabic, English }

class EditServicePage extends StatefulWidget {
  final VoidCallback callback;
  final Map data;
  EditServicePage({this.callback, this.data});

  @override
  _EditServicePageState createState() => _EditServicePageState(data: this.data);
}

class _EditServicePageState extends State<EditServicePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  UploadMediatoFB uploadMedia = new UploadMediatoFB();

  final Map data;
  _EditServicePageState({this.data});
  final firestoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  bool toBeQouted = false;

  String user_uid = "";

  String main_value = "";
  String sub_value = "";
  Set<String> sub_category = new Set<String>();
  String state_value = "";
  String city_value = "";
  List<String> cities_list = [];
  List<String> selected_cities = [];
  ProfileLanguage profileLang = ProfileLanguage.English;
  TextEditingController contollerPrice = new TextEditingController();

  TextEditingController contollerTitle = new TextEditingController();
  TextEditingController contollerDescription = new TextEditingController();
  TextEditingController contollerContract = new TextEditingController();
  TextEditingController contollerGarente = new TextEditingController();
  TextEditingController contollerTitleAR = new TextEditingController();
  TextEditingController contollerDescriptionAR = new TextEditingController();
  TextEditingController contollerContractAR = new TextEditingController();
  TextEditingController contollerGarenteAR = new TextEditingController();

  List photos = [];
  UploadMediatoFB uploadManager = new UploadMediatoFB();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fill the info for
    CategoryClasses.CATEGORY_LIST.forEach((element) {
      if (element["sub"] == data["category"]) {
        main_value = element["main"];
        sub_value = data["category"];
        sub_category = new CategoryClasses().getMainSubs(main_value);
      }
    });

    contollerTitle = new TextEditingController(text: data["title"] ?? "");
    contollerDescription =
        new TextEditingController(text: data["description"] ?? "");
    contollerContract = new TextEditingController(text: data["contract"] ?? "");
    contollerGarente = new TextEditingController(text: data["grantee"] ?? "");

    contollerTitleAR = new TextEditingController(text: data["titleAR"] ?? "");
    contollerDescriptionAR =
        new TextEditingController(text: data["descriptionAR"] ?? "");
    contollerContractAR =
        new TextEditingController(text: data["contractAR"] ?? "");
    contollerGarenteAR =
        new TextEditingController(text: data["granteeAR"] ?? "");
    contollerPrice = new TextEditingController(text: data["price"] ?? "");

    toBeQouted = data['toBeQouted'] ?? false;

    try {
      List citt = data["locations"];
      citt.forEach((element) {
        selected_cities.add(element);
        print("added");
      });
//      selected_cities = [];

    } catch (e) {
      print(e.toString());

//      selected_cities = [];
    }

    try {
      List photo = data["photos"];
      photo.forEach((element) {
        photos.add(element);
      });
//      selected_cities = [];

    } catch (e) {
      photos = [];
    }

    state_value = loc.getMainCategory().elementAt(0);
    cities_list = loc.getMainSubs(state_value);
    city_value = cities_list[0];
    setState(() {});

    // init values
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(widget.data["locations"]);
    print(selected_cities);
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Edit Services"),
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
                          sub_category =
                              new CategoryClasses().getMainSubs(main_value);
                          sub_value = sub_category.elementAt(0);
                        });
                      },
                      items: new CategoryClasses()
                          .getMainCategory()
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
                  new ListTile(
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
                        style: GoogleFonts.comfortaa(color: Colors.deepPurple),
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
                            sub_value != "Other"
                                ? Container(
                                    height: 0,
                                  )
                                : new TextField(
                                    controller: contollerTitle,
                                    decoration: new InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        filled: true,
                                        contentPadding: EdgeInsets.all(16),
                                        labelText: "Service Title",
                                        hintText: "Service Title",
                                        labelStyle: GoogleFonts.comfortaa(
                                            color: purpleColor)),
                                  ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 3,
                              maxLines: 4,
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
                                  labelText: "Service Description",
                                  hintText: "Service Title",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 3,
                              maxLines: 4,
                              controller: contollerContract,
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
                                  labelText: "Prices and offers",
                                  hintText:
                                      "details about the nature of the contract, prices, .. etc",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 3,
                              maxLines: 4,
                              controller: contollerGarente,
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
                                  labelText: "Grantee Details",
                                  hintText:
                                      "details about the nature of the grantee period, terms .. etc",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                          ],
                        )
                      : new Column(
                          children: [
                            sub_value != "Other"
                                ? Container(
                                    height: 0,
                                  )
                                : new TextField(
                                    controller: contollerTitleAR,
                                    decoration: new InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        filled: true,
                                        contentPadding: EdgeInsets.all(16),
                                        labelText: "عنوان الخدمة",
                                        hintText: "عنوان الخدمة",
                                        labelStyle: GoogleFonts.comfortaa(
                                            color: purpleColor)),
                                  ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 3,
                              maxLines: 4,
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
                                  labelText: "وصف الخدمة",
                                  hintText: "تفاصيل الخدمة المقدمة",
                                  suffixIcon: new Container(
                                    width: 50,
                                    child: new Center(
                                      child: new Text(
                                        "*",
                                        style: new TextStyle(
                                            fontSize: 20, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 3,
                              maxLines: 4,
                              controller: contollerContractAR,
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
                                  labelText: "الأسعار والعرض",
                                  hintText:
                                      "تفاصيل حول سعر الخدمة وتفاصيل العروض",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              minLines: 3,
                              maxLines: 4,
                              controller: contollerGarenteAR,
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
                                  labelText: "وصف الضمان",
                                  hintText: "تفاصيل حول الضمان المقدم للخدمة",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                          ],
                        ),
                  new SizedBox(
                    height: 16,
                  ),
                  toBeQouted
                      ? new Container(
                          height: 0.2,
                        )
                      : new TextField(
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
                              labelText: "Service Price",
                              hintText: "based price for the service",
                              labelStyle:
                                  GoogleFonts.comfortaa(color: purpleColor)),
                        ),
                  Row(
                    children: [
                      Container(
                        child: new Checkbox(
                            value: toBeQouted,
                            onChanged: (con) {
                              setState(() {
                                toBeQouted = !toBeQouted;
                              });
                            }),
                      ),
                      new Container(
                        child: new Text('To Be Qouted Later'),
                      )
                    ],
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: size.width,
                    child: new Text(
                      "Service Location",
                      style: GoogleFonts.comfortaa(),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton<String>(
                        value: state_value,
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
                            state_value = newValue;
                            cities_list = loc.getMainSubs(state_value);
                            city_value = cities_list[0];
                          });
                        },
                        items: loc
                            .getMainCategory()
                            .toList()
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      DropdownButton<String>(
                        value: city_value,
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
                            city_value = newValue;
                          });
                        },
                        items: cities_list
                            .toList()
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  new Container(
                    child: new OutlineButton(
                      onPressed: () {
                        setState(() {
                          if (selected_cities.indexOf(city_value) == -1) {
                            selected_cities.add(city_value);
                          } else {
                            print(selected_cities.indexOf(city_value));
                          }
                        });
                      },
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Icon(Icons.add),
                          SizedBox(
                            width: 16,
                          ),
                          new Text(
                            "Add City",
                            style: GoogleFonts.comfortaa(),
                          )
                        ],
                      ),
                    ),
//                    width: size.width * 0.5,
                  ),
                  Container(
                    height: selected_cities.length == 0 ? 0 : 40,
                    child: new ListView(
                      scrollDirection: Axis.horizontal,
                      children: selected_cities
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: new Chip(
                                  label: new Text(
                                    e,
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                  deleteIcon: Icon(Icons.clear),
                                  onDeleted: () {
                                    setState(() {
                                      selected_cities.remove(e);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  new SizedBox(
                    height: 16,
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
                                uploadMedia.photoOption(0).then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  print(value);
                                  if (value != null) {
                                    print(value);
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
                                  Icons.image,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                uploadMedia.photoOption(1).then((value) {
                                  print(value);

                                  if (value != null) {
                                    photos.add({
                                      "type": 1,
                                      "url": value["main"],
                                      "thumb": value["thumb"]
                                    });
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showSnackBar();
                                  }
                                });
                              },
                              child: Center(
                                child: new Icon(
                                  Icons.video_call,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      new Container(
                        width: size.width * 0.35,
                        margin: EdgeInsets.only(top: 24),
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
                        margin: EdgeInsets.only(top: 24),
                        width: size.width * 0.35,
                        decoration: new BoxDecoration(
                            color: purpleColor,
                            borderRadius: new BorderRadius.circular(16)),
                        child: OutlineButton(
                          onPressed: () {
                            saveData();
                          },
                          child: new Center(
                            child: new Text(
                              "Continue",
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
    if (contollerDescription.text.replaceAll(" ", "").length == 0 ||
        contollerDescriptionAR.text.replaceAll(" ", "").length == 0 ||
        contollerContract.text.replaceAll(" ", "").length == 0 ||
        contollerContractAR.text.replaceAll(" ", "").length == 0 ||
        contollerGarente.text.replaceAll(" ", "").length == 0 ||
        (!toBeQouted && contollerPrice.text.replaceAll(" ", "").length == 0) ||
        contollerGarenteAR.text.replaceAll(" ", "").length == 0) {
      showSnackBarError();
    } else {
      setState(() {
        isLoading = true;
      });
      String idSub = CategoryClasses().getSubId(sub_value);
      print("service id " + idSub.toString());
      firestoreInstance.collection("services").doc(data["key"]).update({
        "title": contollerTitle.text.toString(),
        "description": contollerDescription.text.toString(),
        "contract": contollerContract.text.toString(),
        "grantee": contollerGarente.text.toString(),
        "category": sub_value,
        "price": contollerPrice.text,
        "category_sub_id": idSub,
        "toBeQouted": toBeQouted,
        "photos": photos,
//      "owner": user_uid,
        "locations": selected_cities.toList(),
//      "time": DateTime.now().toIso8601String()
      }).then((s) {
        setState(() {});
      }).then((value) {
        setState(() {
          isLoading = false;
          widget.callback != null ? widget.callback() : print("object");
          Navigator.of(context).pop();
        });
      });
    }
  }

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

  void showSnackBarError() {
    final snackBar = SnackBar(
      content: Text('Please Enter all required values'),
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

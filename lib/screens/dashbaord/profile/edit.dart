import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supplier/screens/dashbaord/index.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supplier/screens/dashbaord/profile/choose.dart';
import 'package:supplier/utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supplier/utils/uploadMedia.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:supplier/utils/locations.dart' as loc;
import 'package:google_fonts/google_fonts.dart';

enum ProfileLanguage { Arabic, English }

class EditProfilePage extends StatefulWidget {
  EditProfilePage({this.profile});
  final Map profile;

  @override
  _EditProfilePageState createState() =>
      _EditProfilePageState(profile: this.profile);
}

class _EditProfilePageState extends State<EditProfilePage> {
  _EditProfilePageState({this.profile});
  Map profile;
  bool isLoading = false;
  List files = [];
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController contollerDescriptionAR = new TextEditingController();
  TextEditingController controllerNameAR = new TextEditingController();
  TextEditingController contollerDescription = new TextEditingController();
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerInstagram = new TextEditingController();
  TextEditingController controllerFacebook = new TextEditingController();
  TextEditingController controllerTwitter = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String main_value = "";
  String sub_value = "";
  List<String> sub_category = [];
  String state_value = "";
  String city_value = "";
  List<String> cities_list = [];
  List<double> positions = [0, 0];
  String profileImage;
  ProfileLanguage profileLang = ProfileLanguage.English;

  ChooseMyLocation chooseMyLocationPage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chooseMyLocationPage = new ChooseMyLocation(callback: locationUpdated);
//    state_value = loc.getMainCategory().elementAt(0);
    state_value = profile["state"];
    cities_list = loc.getMainSubs(state_value);
    city_value = profile["city"];
    profileImage = profile["profile"];
    controllerName = new TextEditingController(text: profile["name"]);
    contollerDescription =
        new TextEditingController(text: profile["description"]);
    controllerNameAR = new TextEditingController(text: profile["nameAR"]);
    contollerDescriptionAR =
        new TextEditingController(text: profile["descriptionAR"]);

    controllerTwitter = new TextEditingController(text: profile["twitter"]);
    controllerInstagram = new TextEditingController(text: profile["insta"]);
    controllerFacebook = new TextEditingController(text: profile["facebook"]);
    controllerEmail = new TextEditingController(text: profile["email"]);

    var pos = profile["position"];
    try {
      positions = [
        double.parse(pos.toString().split(",")[0]),
        double.parse(pos.toString().split(",")[1])
      ];
    } catch (e) {
      positions = [0, 0];
    }

    try {
      files = profile["photos"];
    } catch (e) {
      print(e.toString());
      files = [];
    }
    if (files == null) {
      files = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Set<Marker> ss = new Set<Marker>();
    ss.add(new Marker(
        markerId: new MarkerId("userinfo"),
        position: LatLng(positions[0], positions[1])));
    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text("Company Profile"),
//          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : new Container(
                padding: new EdgeInsets.all(16),
                child: new SingleChildScrollView(
                    child: new Column(children: [
                  new SizedBox(
                    height: 16,
                  ),
//                  ),
                  profileImage == null
                      ? Container(
                          height: 89,
                          width: 89,
                          child: new CircleAvatar(),
                        )
                      : Container(
                          height: 89,
                          width: 89,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      CachedNetworkImageProvider(profileImage),
                                  fit: BoxFit.cover)
//                          borderRadius: new BorderRadius.circular(45),
//                          border: new Border.all(color: Colors.black, width: 2)
                              ),
                        ),
                  new ListTile(
                    title: new Text("Company Profile"),
                    trailing: new FlatButton(
                        child: new Text("Change"),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          new UploadMediatoFB().photoOption(0).then((value) {
                            setState(() {
                              isLoading = false;
                              if (value != null) {
                                profileImage = value["main"];
                                showSnackBar();
                              }
                            });
                          });
                        }),
                  ),
                  new Text("Media"),
                  new SizedBox(
                    height: 8,
                  ),
                  new Container(
                    height: 100,
                    child: new ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        new Container(
                          width: 100,
                          height: 100,
                          margin: new EdgeInsets.only(right: 10),
                          decoration: new BoxDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              new UploadMediatoFB()
                                  .photoOption(0)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                  if (value != null) {
                                    files.add({
                                      "type": 0,
                                      "url": value["main"],
                                      "thumb": value["thumb"]
                                    });
                                    showSnackBar();
                                  }
                                });
                              });
                            },
                            child: new Card(
                              elevation: 2,
                              child: new Center(
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    new Icon(
                                      Icons.photo,
                                      size: 35,
                                    ),
                                    new SizedBox(
                                      height: 10,
                                    ),
                                    new Text(
                                      "Add Photo",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        new Container(
                          width: 100,
                          height: 100,
                          margin: new EdgeInsets.only(right: 10),
                          decoration: new BoxDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              new UploadMediatoFB()
                                  .photoOption(1)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                  if (value != null) {
                                    files.add({
                                      "type": 1,
                                      "url": value["main"],
                                      "thumb": value["thumb"]
                                    });
                                    showSnackBar();
                                  }
                                });
                              });
                            },
                            child: new Card(
                              elevation: 2,
                              child: new Center(
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    new Icon(
                                      Icons.video_label,
                                      size: 35,
                                    ),
                                    new SizedBox(
                                      height: 10,
                                    ),
                                    new Text(
                                      "Add Video",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]..addAll(files.map((e) => _buildMedia(e)).toList()),
                    ),
                  ),
                  new SizedBox(
                    height: 8,
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
                          label: new Text("English Profile")),
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
                          label: Row(
                            children: [
                              new Text("بروفايل عربي"),
                              new Container(
                                width: 50,
                                child: new Center(
                                  child: new Text(
                                    "*",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                  new SizedBox(
                    height: 8,
                  ),
                  profileLang == ProfileLanguage.Arabic
                      ? new Column(
                          children: [
                            new SizedBox(
                              height: 16,
                            ),
                            new TextField(
                              controller: controllerNameAR,
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
                                  labelText: "اسم الشركة",
                                  hintText: "اسم الشركة",
                                  suffixIcon: new Container(
                                    width: 50,
                                    child: new Center(
                                      child: new Text(
                                        "*",
                                        style: TextStyle(
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
                                  labelText: "وصف الشركة",
                                  hintText: "وصف الشركة",
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
                              controller: controllerName,
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
                                  labelText: "Company Name",
                                  hintText: "Company Name",
                                  suffixIcon: new Container(
                                    width: 50,
                                    child: new Center(
                                      child: new Text(
                                        "*",
                                        style: TextStyle(
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
                                  labelText: "Company Description",
                                  hintText: "Company Title",
                                  labelStyle: GoogleFonts.comfortaa(
                                      color: purpleColor)),
                            ),
                          ],
                        ),
                  new SizedBox(
                    height: 16,
                  ),
                  Card(
                    child: new ListTile(
                      title: Row(
                        children: [
                          new Text("State"),
                          new Container(
                            width: 50,
                            child: new Center(
                              child: new Text(
                                "*",
                                style:
                                    TextStyle(fontSize: 20, color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: DropdownButton<String>(
                        value: state_value,
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
                    ),
                  ),
                  new SizedBox(
                    height: 16,
                  ),

                  Card(
                    child: new ListTile(
                      title: Row(
                        children: [
                          new Text("City"),
                          new Container(
                            width: 50,
                            child: new Center(
                              child: new Text(
                                "*",
                                style:
                                    TextStyle(fontSize: 20, color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: DropdownButton<String>(
                        value: city_value,
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
                      ),
                    ),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  new ListTile(
                    title: new Text("Location"),
                    trailing: new FlatButton(
                        onPressed: () {
                          navigate(chooseMyLocationPage);
                        },
                        child: new Text("edit your location")),
                  ),
                  InkWell(
                    onTap: () {
                      navigate(chooseMyLocationPage);

                    },
                    child: Container(
                      height: 200,
                      child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },

                          onTap: (c){
                            navigate(chooseMyLocationPage);

                          },
                          initialCameraPosition: CameraPosition(
                              target: LatLng(positions[0], positions[1]),
                              zoom: 19),
                          markers: ss),
                    ),
                  ),
                  new TextField(
                    controller: controllerEmail,
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
                        labelText: "Email",
                        hintText: "Email",
                        labelStyle: GoogleFonts.comfortaa(color: purpleColor)),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  new TextField(
                    controller: controllerInstagram,
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
                        labelText: "Instagram User",
                        hintText: "@",
                        labelStyle: GoogleFonts.comfortaa(color: purpleColor)),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  new TextField(
                    controller: controllerTwitter,
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
                        labelText: "Twitter Account",
                        hintText: "@",
                        labelStyle: GoogleFonts.comfortaa(color: purpleColor)),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  new TextField(
                    controller: controllerFacebook,
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
                        labelText: "Facebook Profile Url",
                        hintText: "@",
                        labelStyle: GoogleFonts.comfortaa(color: purpleColor)),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      new Container(
                        margin: EdgeInsets.only(top: 24),
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
                              "Save",
                              style: GoogleFonts.comfortaa(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  new SizedBox(
                    height: 32,
                  )
                ]))));
  }

  void saveData() async {
    if (
//    profileImage == null ||
        controllerName.text == "" || controllerName.text == " ") {
      final snackBar = SnackBar(
        content: Text('Please fill all necessary data in enlish section'),
        action: SnackBarAction(
          label: 'clear',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
    }
    if (controllerNameAR.text == "" || controllerNameAR.text == " ") {
      final snackBar = SnackBar(
        content: Text('الرجاء ملئ البيانات بالعربي كذلك'),
        action: SnackBarAction(
          label: 'clear',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      setState(() {
        profileLang = ProfileLanguage.Arabic;
      });
      _scaffoldkey.currentState.showSnackBar(snackBar);
    } else {
      setState(() {
        isLoading = true;
      });
      FirebaseFirestore.instance
          .collection("users")
          .doc(profile["UID"])
          .update({
//      "UID": widget.uid,
        "profile": profileImage,
        "position": positions[0].toString() + "," + positions[1].toString(),
        "name": controllerName.text,
        "description": contollerDescription.text,
        "nameAR": controllerNameAR.text,
        "descriptionAR": contollerDescriptionAR.text,
        "state": state_value,
        "city": city_value,
        "photos": files,
        "email": controllerEmail.text,
        "insta": controllerInstagram.text,
        "twitter": controllerTwitter.text,
        "facebook": controllerFacebook.text,
      }).then((value) {
        Navigator.of(context).pop();
      });
    }
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildMedia(map) {
    return Container(
      child: new Stack(
        children: [
          Container(
            color: Colors.red,
            width: 90,
            height: 90,
            margin: new EdgeInsets.all(8),
            child: new CachedNetworkImage(
              imageUrl: map["thumb"],
              fit: BoxFit.cover,
            ),
          ),
          new Positioned(
            top: 0,
            right: 0,
            height: 30,
            width: 30,
            child: InkWell(
              onTap: () {
                setState(() {
                  files.remove(map);
                });
              },
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.red,
                    border: new Border.all(color: Colors.redAccent, width: 2),
                    shape: BoxShape.circle),
                child: Center(
                    child: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 15,
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  void locationUpdated() async {
    setState(() {
      positions = [
        chooseMyLocationPage.location.latitude,
        chooseMyLocationPage.location.longitude
      ];
    });
    final GoogleMapController controller = await _controller.future;
    CameraPosition _kLake = CameraPosition(
//        bearing: 192.8334901395799,
        target: LatLng(positions[0], positions[1]),
//        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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
    _scaffoldkey.currentState.showSnackBar(snackBar);
  }
}

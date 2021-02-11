import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:supplier/screens/auth/editphone.dart';
import 'package:supplier/screens/dashbaord/profile/edit.dart';
import 'package:supplier/screens/dashbaord/profile/reviews.dart';
import 'package:supplier/screens/showImage.dart';
import 'package:supplier/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/widgets/customTab.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.openSlideView});
  VoidCallback openSlideView;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Map profile;
  bool isLoading = true;
  User user;
  List files = [];
  List users = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });

//    FirebaseAuth.instance.currentUser().then((value) {
//      setState(() {
//        user = value;
//      });
//    });
    SharedPreferences.getInstance().then((sp) {
      var groupID = sp.get("groupID").toString();
      setState(() {
        if (groupID != null) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(groupID)
              .snapshots()
              .forEach((element) {
            setState(() {
              print(profile);

              profile = element.data();
              isLoading = false;
              loadAllUsers();
            });
          });
        } else {
          print("error");
        }
      });
    });
  }

  void loadAllUsers() async {
    FirebaseFirestore.instance
        .collection("groups")
        .where('groupID', isEqualTo: profile["UID"])
        .get()
        .then((value) {
      setState(() {
        users = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      files = profile["photos"];
    } catch (e) {
      files = [];
    }
    if (files == null) {
      files = [];
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            backgroundColor: Color(0xffFAFAFA),
            title: new Text(
              "Profile",
              style: GoogleFonts.comfortaa(),
            ),
            centerTitle: false,
            elevation: 0,
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Company Info",
                ),
                Tab(
                  text: "Reviews",
                ),
              ],
            ),
            leading: IconButton(
              onPressed: () {
                widget.openSlideView();
              },
              icon: Icon(Icons.menu),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: purpleColor,
            foregroundColor: Colors.white,
            onPressed: () {
              navigate(EditProfilePage(
                profile: profile,
              ));
            },
            child: new Icon(Icons.edit),
          ),
          body: profile == null
              ? Center(
                  child: new CircularProgressIndicator(),
                )
              : TabBarView(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : new Container(
                                padding: new EdgeInsets.all(16),
                                child: new SingleChildScrollView(
                                    child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    new Row(
                                      children: [
                                        profile["profile"] == null
                                            ? Container(
                                                height: 0.0,
                                              )
                                            : Container(
                                                height: 89,
                                                width: 89,
                                                decoration: new BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image:
                                                            CachedNetworkImageProvider(
                                                                profile[
                                                                    "profile"]),
                                                        fit: BoxFit.cover)
//                          borderRadius: new BorderRadius.circular(45),
//                          border: new Border.all(color: Colors.black, width: 2)
                                                    ),
                                              ),
                                        Container(
                                          margin: new EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: new Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              new Text(
                                                profile["name"]
                                                            .toString()
                                                            .length >
                                                        12
                                                    ? profile["name"]
                                                            .toString()
                                                            .substring(0, 11) +
                                                        "..."
                                                    : profile["name"],
                                                style: GoogleFonts.comfortaa(
                                                    fontSize: 24),
                                              ),
                                              new Text(profile["state"] +
                                                  ", " +
                                                  profile["city"])
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    new SizedBox(
                                      height: 16,
                                    ),
                                    new Text(
                                      "Media",
                                      style: GoogleFonts.comfortaa(
                                          fontWeight: FontWeight.w300,
                                          color: purpleColor,
                                          fontSize: 20),
                                    ),
                                    new SizedBox(
                                      height: 8,
                                    ),
                                    new Container(
                                      height: 100,
                                      child: new ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: []..addAll(files
                                            .map((e) => _buildMedia(e))
                                            .toList()),
                                      ),
                                    ),
                                    new SizedBox(
                                      height: 16,
                                    ),
                                    new Text(
                                      "Description",
                                      style: GoogleFonts.comfortaa(
                                          fontSize: 20,
                                          color: purpleColor,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    new SizedBox(
                                      height: 8,
                                    ),
                                    new Text(
                                      profile["description"],
                                      style: GoogleFonts.comfortaa(),
                                    ),
                                    new SizedBox(
                                      height: 32,
                                    ),
                                    new Text(
                                      "Contact",
                                      style: GoogleFonts.comfortaa(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300,
                                          color: purpleColor),
                                    ),
                                    new SizedBox(
                                      height: 8,
                                    ),
                                    new Column(
                                      children: [
                                        buildContactItem(
                                            Icons.phone, profile["phone"]),
                                        buildContactItem(
                                            Icons.email, profile["email"]),
                                        buildContactItem(
                                            FontAwesomeIcons.facebookF,
                                            profile["facebook"] ?? " "),
                                        buildContactItem(
                                            FontAwesomeIcons.twitter,
                                            profile["twitter"] ?? " "),
                                        buildContactItem(
                                            FontAwesomeIcons.instagram,
                                            profile["insta"] ?? " "),
                                      ],
                                    ),
                                    new SizedBox(
                                      height: 30,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        navigate(EditPhonePage(
                                            callBack: loadAllUsers));
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: purpleColor,
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: new Center(
                                          child: Text(
                                            "Change Phone Number",
                                            style: GoogleFonts.comfortaa(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    new SizedBox(
                                      height: 30,
                                    ),
                                  ]..addAll(buildListOfLinkedUsers()),
                                )))),
                    ReviewsList(
                      groupID: profile != null ? profile["UID"] : null,
                    )
                  ],
                )),
    );
  }

  Widget buildContactItem(icon, text) {
    if (text == null || text == " " || text == "") {
      return Container(
        height: 0.0,
      );
    }
    return Column(
      children: [
        new Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
            ),
            new SizedBox(
              width: 16,
            ),
            new Text(
              text,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
        new SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildMedia(map) {
    print(map);
    return Container(
      child: new Stack(
        children: [
          InkWell(
            onTap: () {
              navigate(ShowImage(
                type: map["type"],
                url: map["url"],
              ));
            },
            child: Container(
//            color: Colors.red,
              width: 90,
              height: 90,
              margin: new EdgeInsets.all(8),
              child: new CachedNetworkImage(
                imageUrl: map["thumb"],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildListOfLinkedUsers() {
    List<Widget> list = [];
    list.add(new Text(
      "Users List",
      style: GoogleFonts.comfortaa(
          fontSize: 20, color: purpleColor, fontWeight: FontWeight.w300),
    ));
    users.forEach((element) {
      print("-" + element["userID"] + "-compare :-" + user.phoneNumber);
      list.add(new ListTile(
        leading: new Icon(
          Icons.person,
        ),
        title: new Text(element["userID"] ?? "-"),
        trailing: user != null && user.phoneNumber == element["userID"]
            ? Container(
                width: 1,
              )
            : InkWell(
                onTap: () => _showMyDialog(element),
                child: new Icon(
                  Icons.delete,
                ),
              ),
      ));
    });
    list.add(new SizedBox(
      height: 16,
    ));
    list.add(Center(
      child: Container(
        decoration: new BoxDecoration(
            color: purpleColor, borderRadius: BorderRadius.circular(16)),
        child: new FlatButton(
            onPressed: () async {
              return addAnotherPhone(
                  await prompt(context, initialValue: "+968"));
            },
            child: new Text(
              "Add Another User",
              style: GoogleFonts.comfortaa(color: Colors.white),
            )),
      ),
    ));
    return list;
  }

  Future<void> _showMyDialog(elemnt) async {
    print(elemnt.documentID);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are deleting member in this group.'),
                Text('Are you sure?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
                Firestore.instance
                    .collection("groups")
                    .document(elemnt.documentID)
                    .delete()
                    .then((value) => loadAllUsers());
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  addAnotherPhone(String newPhone) async {
    print(newPhone);
    if (newPhone == null ||
        newPhone.replaceAll(" ", "").replaceAll("+968", "").length < 8) {
      print("error");
      showSnackBarError("Please Enter valid phone number");
    } else {
      bool isEntered = false;
      users.forEach((element) {
        if (element["userID"].toString() == newPhone) {
          isEntered = true;
        }
      });

      if (isEntered == false) {
        var snapshots = await Firestore.instance
            .collection("groups")
            .where("userID", isEqualTo: newPhone)
            .getDocuments();

        if (snapshots.documents.length != 0) {
          showSnackBarError(
              "This number is already have been added in other group");
        } else {
          Firestore.instance.collection("groups").add({
            "userID": newPhone.replaceAll(" ", ""),
            "groupID": profile["UID"],
            "time": DateTime.now().toString()
          }).then((value) {
            loadAllUsers();
          });
        }
      } else {
        showSnackBarError(
            "This number is already have been added in this group");
      }
    }
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBarError(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
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

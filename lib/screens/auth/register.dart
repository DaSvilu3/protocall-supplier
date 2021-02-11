import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/screens/auth/finalize_register.dart';
import 'package:supplier/screens/dashbaord/index.dart';
import 'package:supplier/utils/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController(text: " ");
  final _codeController = TextEditingController();
  bool showOTP = false;
  bool isLoading = false;
  String verification;
  FocusNode myFocusNode;
  FocusNode myFocusNode2;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  Position position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    myFocusNode2 = FocusNode();

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    getLocation();
    _firebaseMessaging.getToken().then((token) {
      print(token);
      User value = FirebaseAuth.instance.currentUser;

      if (value != null) {
        print("phone number: " + value.phoneNumber.toString());
        FirebaseFirestore.instance
            .collection("groups")
            .where('userID', isEqualTo: value.phoneNumber.toString())
            .get()
            .then((value2) {
          if (value2.docs.length == 0) {
            navigate(FinilizeRegister(
                phone: value.phoneNumber.toString(), uid: value.uid));
          } else {
            SharedPreferences.getInstance().then((sp) {
              sp
                  .setString("groupID", value2.docs[0].data()["groupID"])
                  .then((value3) {
                navigate(DashboardPage());
              });
            });
          }
        });
      } else {
        setState(() {
          myFocusNode2.requestFocus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.white,
//      appBar: AppBar(
//        title: Text("Register Page"),
//      ),
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new Container(
              padding: new EdgeInsets.all(16),
              child: new SingleChildScrollView(
                child: new Column(
                  children: [
                    new Container(
                      padding: new EdgeInsets.only(
                          left: size.width * 0.2,
                          right: size.width * 0.2,
                          top: size.height * 0.1,
                          bottom: size.height * 0.1),
                      child: Image.asset("assets/logo.png"),
                    ),
                    showOTP
                        ? new TextField(
                            keyboardType: TextInputType.number,
                            controller: _codeController,
                            focusNode: myFocusNode,
                            decoration: new InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
//                    filled: true,

                                contentPadding: EdgeInsets.all(16),
                                labelText: "OTP",
//                                hintText: "OTP",
                                labelStyle:
                                    GoogleFonts.comfortaa(color: purpleColor)),
                          )
                        : new TextField(
                            focusNode: myFocusNode2,
                            keyboardType: TextInputType.number,
                            controller: _phoneController,
                            decoration: new InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
//                    filled: true,
                                prefixIcon: new Container(
                                  padding: new EdgeInsets.only(top: 8, left: 8),
                                  child: new Text("+968"),
                                ),
                                contentPadding: EdgeInsets.all(16),
                                labelText: "Phone Number",
//                                hintText: "Phone Number",
                                labelStyle:
                                    GoogleFonts.comfortaa(color: purpleColor)),
                          ),
                    new SizedBox(
                      height: 16,
                    ),
                    new Container(
                      width: size.width * 0.35,
                      decoration: new BoxDecoration(
                          color: purpleColor,
                          borderRadius: new BorderRadius.circular(16)),
                      child: OutlineButton(
                        onPressed: () {
                          showOTP
                              ? verify()
                              : loginUser(_phoneController.text, context);
//                    Navigator.of(context).push(new MaterialPageRoute(
//                        builder: (context) => new OTPPage()));
                        },
                        child: new Center(
                          child: new Text(
                            "Continue",
                            style: GoogleFonts.comfortaa(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    new SizedBox(
                      height: 200,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: new Text(
                        "This app is for suppliers, if you are a customer, use the customer application ",
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  verify() async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection("groups")
          .where('userID', isEqualTo: currentUser.phoneNumber.toString())
          .get()
          .then((value2) {
        if (value2.docs.length == 0) {
          navigate(FinilizeRegister(
              phone:
                  "+968" + _phoneController.text.replaceAll(' ', '').toString(),
              uid: currentUser.uid));
        } else {
          SharedPreferences.getInstance().then((sp) {
            sp
                .setString("groupID", value2.docs[0].data()["groupID"])
                .then((value3) {
              navigate(DashboardPage());
            });
          });
        }
      });
    }
    setState(() {
      isLoading = true;
    });

    final code = _codeController.text.trim();
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verification, smsCode: code);

    var result = await _auth.signInWithCredential(credential);

    User user = result.user;
    setState(() {
      isLoading = false;
    });
    if (user != null) {
      FirebaseFirestore.instance
          .collection("groups")
          .where('userID', isEqualTo: user.phoneNumber.toString())
          .get()
          .then((value2) {
        if (value2.docs.length == 0) {
          navigate(FinilizeRegister(
              phone:
                  "+968" + _phoneController.text.toString().replaceAll(" ", ""),
              uid: user.uid));
        } else {
          SharedPreferences.getInstance().then((sp) {
            sp
                .setString("groupID", value2.docs[0].data()["groupID"])
                .then((value3) {
              navigate(DashboardPage());
            });
          });
        }
      });
      print(user.uid);
    } else {
      print("Error");
    }
  }

  Future<bool> loginUser(String phone, BuildContext context) async {
    if (phone == " " || phone.replaceAll(" ", "").length != 8) {
      print("Error ");
    } else {
      FirebaseAuth _auth = FirebaseAuth.instance;
      setState(() {
        isLoading = true;
      });
      _auth.verifyPhoneNumber(
        phoneNumber: "+968" + phone.toString(),
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
//          Navigator.of(context).pop();
          print("Auth Completed");
          var result = await _auth.signInWithCredential(credential);
          User user = result.user;
          if (user != null) {
          } else {
            print("Error");
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          print(verificationId);
          setState(() {
            showOTP = true;
            isLoading = false;
            verification = verificationId;
            myFocusNode.requestFocus();
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Error here and there");
        },
      );
    }
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
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

  void getLocation() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var location = LatLng(position.latitude, position.longitude);
    GoogleMap(
      onTap: (newLocation) {
        setState(() {
          position = new Position(
              latitude: newLocation.latitude, longitude: newLocation.longitude);
//          widget.location = newLocation;
        });
      },
//      markers: markers,
      initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 15),
    );
  }
}

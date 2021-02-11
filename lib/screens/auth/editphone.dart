import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPhonePage extends StatefulWidget {
  EditPhonePage({Key key, this.title, this.callBack}) : super(key: key);
  final VoidCallback callBack;
  final String title;

  @override
  _EditPhonePageState createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool showOTP = false;
  bool isLoading = false;
  String verification;
  FocusNode myFocusNode;
  FocusNode myFocusNode2;

  User oldUser;
  String user_id;
  String previosPhone;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    myFocusNode2 = FocusNode();

    oldUser = FirebaseAuth.instance.currentUser;
    user_id = oldUser.uid;
    previosPhone = oldUser.phoneNumber;
    myFocusNode2.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: new IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text("Change Phone Number"),
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
                  ],
                ),
              ),
            ),
    );
  }

  verify() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    setState(() {
      isLoading = true;
    });

    final code = _codeController.text.trim();
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verification, smsCode: code);

    var result = await _auth.signInWithCredential(credential);
    print("credintional  " + result.user.phoneNumber);

    User user = result.user;
    setState(() {
      isLoading = false;
    });
    if (user != null) {
      SharedPreferences.getInstance().then((sp) {
        String groupID = sp.get("groupID").toString();
        FirebaseFirestore.instance
            .collection("groups")
            .where("userID", isEqualTo: previosPhone)
            .get()
            .then((snapshots) {
          snapshots.docs.forEach((element) {
            element.reference
                .update({"userID": _phoneController.text}).then((value33) {
              widget.callBack();
              Navigator.of(context).pop();
            });
          });
        });
      });

      print(user.uid);
    } else {
      print("Error");
    }
  }

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    setState(() {
      isLoading = true;
    });

    _auth.verifyPhoneNumber(
        phoneNumber: "+968" + phone.toString(),
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
//          Navigator.of(context).pop();
          var result = await _auth.signInWithCredential(credential);
          User user = result.user;
//          oldUser.updatePhoneNumberCredential(credential);
//          oldUser.linkWithCredential(credential);
//          copyProfile(oldUser.uid, user.uid);
//          user.linkWithCredential(credential);
//          oldUser.updateProfile()
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
        codeAutoRetrievalTimeout: (String s) {});
  }

  copyProfile(oldUID, newUID) async {
    // copy profile
    print("copy profile");

    final inst = FirebaseFirestore.instance;
    await inst
        .collection("users")
        .where("phone", isEqualTo: previosPhone)
        .snapshots()
        .first
        .then((v) {
      // copy profile
      var data = v.docs[0].data();
      data["UID"] = newUID;
      data["phone"] = "+968" + _phoneController.text;
      inst.collection("users").doc(newUID).set(data);
      // revoke data from old profile
      inst.collection("users").doc(oldUID).delete();
    });

    // copy products
    print("updating services");
    await inst
        .collection("services")
        .where('owner', isEqualTo: oldUID)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await inst
            .collection("services")
            .doc(element.id)
            .update({'owner': newUID});
      });
    });

    // move products
    print("updating products");

    await inst
        .collection("products")
        .where('owner', isEqualTo: oldUID)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await inst
            .collection("products")
            .doc(element.id)
            .update({'owner': newUID});
      });
    });

    // move requests
    print("move request");
    await inst
        .collection("request")
        .where('supplier', isEqualTo: oldUID)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        await inst
            .collection("request")
            .document(element.documentID)
            .updateData({'supplier': newUID});
      });
    });

    setState(() {
//      isLoading = false;
      Phoenix.rebirth(context);
    });
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }
}

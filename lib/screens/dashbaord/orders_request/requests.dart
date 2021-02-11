import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supplier/screens/dashbaord/index.dart';
import 'package:supplier/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateRequests extends StatefulWidget {
  final Map data;
  VoidCallback callback;
  UpdateRequests({this.data, this.callback});
  @override
  _UpdateRequest createState() => _UpdateRequest(data: this.data);
}

class _UpdateRequest extends State<UpdateRequests> {
  final Map data;
  _UpdateRequest({this.data});
  TextEditingController contollerNotes = new TextEditingController();
  String selection_value = "";
  bool isLoading = false;
  List<Map> status = [
    {"code": "accepted", "color": Color(0xff3366cc), "title": "Accepted"},
    {"code": "in-progress", "color": Color(0xff990099), "title": "In Progress"},
    {"code": "completed", "color": Color(0xff109618), "title": "Completed"},
    {"code": "canceled", "color": Color(0xfffdbe19), "title": "Canceled"},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      selection_value = data["status"] ?? "accepted";
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests", style: GoogleFonts.comfortaa()),
        elevation: 0,
      ),
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new Container(
              padding: new EdgeInsets.all(16),
              child: new Column(
                children: [
                  new ListTile(
                    title: new Text(
                      "Status",
                      style: GoogleFonts.comfortaa(),
                    ),
                    trailing: DropdownButton<String>(
                      value: selection_value,
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
                          selection_value = newValue;
                        });
                      },
                      items: status
                          .toList()
                          .map<DropdownMenuItem<String>>((Map value) {
                        return DropdownMenuItem<String>(
                          value: value["code"],
                          child: Text(
                            value["title"],
                            style: GoogleFonts.comfortaa(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  new Divider(),
                  new TextField(
                    minLines: 5,
                    maxLines: 9,
                    controller: contollerNotes,
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
                        labelText: "Notes",
                        hintText: "more details for tracking etc",
                        labelStyle: GoogleFonts.comfortaa(color: purpleColor)),
                  ),
                  new SizedBox(
                    height: 24,
                  ),
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      new Container(
                        width: size.width * 0.25,
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
                  )
                ],
              ),
            ),
    );
  }

  void saveData() {
    String details = contollerNotes.text.toString();
    String status = selection_value;
    String previous = widget.data["status"];
    if (getIndex(previous) > getIndex(status) &&
        (details == "" || details == " " || details == null)) {
      _showMyDialog();
    } else {
      String key_es = data["key"];
      print(data["key"]);
      setState(() {
        isLoading = true;
      });
      FirebaseFirestore.instance
          .collection("request")
          .doc(key_es.toString())
          .update({"status": status}).then((value) {
        FirebaseFirestore.instance
            .collection("request")
            .doc(key_es.toString())
            .collection("tracking")
            .add({
          "date": DateTime.now().toIso8601String(),
          "details": details,
          "status": status
        }).then((value) {
          widget.callback();
          setState(() {
            isLoading = false;
            Navigator.of(context).pop();
          });
        });
      });
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('you must writes notes about the order.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int getIndex(string) {
    int index = 0;
    int count = 0;
    status.forEach((element) {
      if (element["code"] == string) {
        index = count;
        return;
      }
      count++;
    });
    return index;
  }
}

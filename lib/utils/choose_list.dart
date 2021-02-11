import 'package:flutter/material.dart';
import 'locations.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationList extends StatefulWidget {
  LocationList(this.MAIN_AREA);
  final int MAIN_AREA;
  @override
  _LocationListState createState() => new _LocationListState();
}

class _LocationListState extends State<LocationList> {
  int choosed_parent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      choosed_parent = widget.MAIN_AREA;
    });
  }

  String local = "en";
  @override
  Widget build(BuildContext context) {
    String subtitleMsg;
    if (local == null) {
      setState(() {
        print(local);
      });
    }
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
              local == "en" ? "List Of Places" : "قائمة الأماكن التي بها خدمة"),
          leading: new IconButton(
              icon: new Icon(Icons.clear),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          actions: <Widget>[
            widget.MAIN_AREA == choosed_parent
                ? new Container()
                : new FlatButton(
                    child: new Text(
                      local == "en" ? "clear" : "رجوع",
                      style: GoogleFonts.comfortaa(
                          fontSize: 14, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        choosed_parent = widget.MAIN_AREA;
                      });
                    })
          ],
        ),
        backgroundColor: Colors.white,
        body: new Container(
            child: new Container(
          padding: new EdgeInsets.all(10.0),
          child: new ListView(
            children: _buildList(),
          ),
        )));
  }

  List<Widget> _buildList() {
    List<Widget> list = [];

    locations.forEach((location) {
      String titleKey = "title " + local;
      if (location["parent"] == choosed_parent) {
        list.add(new ListTile(
          onTap: () {
            if (doIHaveChildren(location["code"])) {
              setState(() {
                choosed_parent = location["code"];
              });
            } else {
              // handleConfirm
              handleChoosing(location["code"]);
            }
          },
          title: new Text(location[titleKey]),
        ));
        list.add(new Divider(
          height: 1.0,
        ));
      }
    });

    return list;
  }

  void handleChoosing(int choose) {
    showDialog(
        context: context,
        child: new Container(
            child: new AlertDialog(
          content: new Text(local == "en"
              ? "Are you sure to select this area ?"
              : "هل أنت متأكد من اختيار هذه المنطقة؟"),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  saveArea(choose);
                },
                child: new Text(local == "en" ? "Yes" : "نعم")),
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text(local == "en" ? "No" : "لا")),
          ],
        )));
  }

  void saveArea(int area) {}

  bool doIHaveChildren(int parent) {
    bool doIHave = false;
    locations.forEach((location) {
      if (location["parent"] == parent) {
        doIHave = true;
      }
    });

    return doIHave;
  }
}

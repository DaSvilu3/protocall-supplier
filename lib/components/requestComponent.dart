import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/components/productslistItem.dart';
import 'package:supplier/components/serviceItem.dart';
import 'package:supplier/components/trackingComponent.dart';
import 'package:supplier/screens/chatImage.dart';
import 'package:supplier/screens/dashbaord/orders_request/requests.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

import 'package:supplier/utils/colors.dart';

class OrderRequestItem extends StatefulWidget {
  OrderRequestItem({this.item});
  Map item;
  @override
  _OrderRequestItemState createState() =>
      _OrderRequestItemState(item: this.item);
}

class _OrderRequestItemState extends State<OrderRequestItem> {
  _OrderRequestItemState({this.item});
  Map item;
  bool isSub = false;
  var firestoreInstance = FirebaseFirestore.instance;
  Map status = {
    "accepted": {"color": Color(0xff3366cc), "title": "Accepted"},
    "in-progress": {"color": Color(0xff990099), "title": "In Progress"},
    "completed": {"color": Color(0xff109618), "title": "Completed"},
    "canceled": {"color": Color(0xfffdbe19), "title": "Canceled"},
  };
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: new EdgeInsets.only(top: 8),
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ExpansionTile(
          onExpansionChanged: (v) {
            getDetailsData(item).then((value) {
              item = value;
              setState(() {});
            });
          },
          title: ListTile(
            onTap: () {},
            leading: Container(
              width: 60,
              height: 60,
              child: new Card(
                color: status[item["status"].toString()]["color"],
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white70, width: 1),
                  borderRadius: BorderRadius.circular(
                      item["type"] == "service" ? 30 : 10),
                ),
              ),
            ),
            title: new Text(
              "Order - " + item["key"].toString().substring(0, 10),
              style: GoogleFonts.comfortaa(),
            ),
            subtitle: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new SizedBox(
                  height: 16,
                ),
                new Row(
                  children: [
                    new Container(
                      width: 20,
                      height: 20,
                      decoration: new BoxDecoration(
                          color: status[item["status"].toString()]["color"],
                          shape: BoxShape.circle),
                    ),
                    new SizedBox(
                      width: 16,
                    ),
                    new Text(
                      status[item["status"].toString()]["title"],
                      style: GoogleFonts.comfortaa(),
                    )
                  ],
                ),
                new SizedBox(
                  height: 8,
                ),
                new Row(
                  children: [
                    new Icon(Icons.date_range),
                    new SizedBox(
                      width: 16,
                    ),
                    new Text(item["created_at"].toDate().toString(), style: GoogleFonts.comfortaa())
                  ],
                )
              ],
            ),
          ),
          children: _getExpandedList(item),
        ),
      ),
    );
  }

  Future<Map> getDetailsData(obj) async {
    // we want 3 things, customer info, services or products details, trackings

    print("getting tracking ");
    await firestoreInstance
        .collection("request")
        .doc(obj["key"])
        .collection("tracking")
        .get()
        .then((value) {
      List subcollection = [];
      value.docs.forEach((el) {
        subcollection.add(el.data());
      });
      subcollection.sort((a, b) {
        var adate = a['date']; //before -> var adate = a.expiry;
        var bdate = b['date']; //before -> var bdate = b.expiry;
        return bdate.compareTo(
            adate); //to get the order other way just switch `adate & bdate`
      });

      obj["tracking"] = subcollection;
    }).catchError((onError) => print(onError.toString()));
    print("done getting tracking" + obj["tracking"].length.toString());


    if(obj['location'] != null){
      print(obj['location']);
      DocumentReference loc = obj['location'];
      print("I am getting the data of locations");
      await loc.get().then((value) {
        print("I am getting the data of locations");
        obj['locationOBJ'] = value.data();
        print(value.data());
        obj['locationOBJ']['latitude'] = value.data().values.toList()[4];
        obj['locationOBJ']['longitude'] = value.data().values.toList()[5];
//        print();
//        print(value.data().values.toList()[5]);

      });
    }


    if (obj["type"] == "service") {
      String services;
      List servicesObjs = [];

      try {
        services = obj["products"];
      } catch (e) {
        print(e);
        services = "-";
      }
      if (services == null) {
        services = "-";
      }



      await FirebaseFirestore.instance
          .collection("services")
          .doc(services.toString().replaceAll("services/", ""))
          .get()
          .then((value) {
        print(value.data);
        Map tt = value.data();
        tt["key"] = value.id;
        servicesObjs.add(tt);
        setState(() {});
      });
      obj["servicesObj"] = servicesObjs;
    } else {
      List products = [];
      List productsObjs = [];

      try {
        products = obj["products"];
      } catch (e) {
        print(e);
        products = [];
      }
      if (products == null) {
        products = [];
      }

      await products.forEach((element) {
        FirebaseFirestore.instance
            .collection('products')
            .doc(element.toString())
            .get()
            .then((value) {
          print(value.data);
          Map tt = value.data();
          tt["key"] = value.id;
          productsObjs.add(tt);
          setState(() {});
        });
      });
      obj["productsObjs"] = productsObjs;
    }

    if (obj["customer"] != null) {
      print("getting customer");
      print(obj["customer"]);

      String document = obj["customer"];
//      print(document.documentID);
      await FirebaseFirestore.instance
          .collection("customers")
          .doc(document.toString())
          .get()
          .then((value) {
        print(value.data());
        obj["customerObj"] =
            obj["customerObj"] != null ? obj['customerObj'] : null;
        print("customer");
      });
    }
    return obj;
  }

  List<Widget> _getExpandedList(e) {
    Size size = MediaQuery.of(context).size;
    Timestamp timeStamp = item['created_at'];
//    print("my timestamp");
//    print(timeStamp.toDate());
    return [
      new SizedBox(
        height: 16,
      ),
      // controllers
      new Row(
        children: [
          SizedBox(
            width: 8,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: purpleColor)),
            onPressed: () {
              openChat(e);
            },
            color: purpleColor,
            textColor: Colors.white,
            child: new Row(
              children: [
                new Icon(Icons.chat),
                new SizedBox(
                  width: 8,
                ),
                Text("Chat".toUpperCase(),
                    style: GoogleFonts.comfortaa(fontSize: 12))
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: purpleColor)),
            onPressed: () {
              navigate(UpdateRequests(
                data: e,
                callback: getData,
              ));
            },
            color: purpleColor,
            textColor: Colors.white,
            child: new Row(
              children: [
                new Icon(Icons.update),
                new SizedBox(
                  width: 8,
                ),
                Text("Update", style: GoogleFonts.comfortaa(fontSize: 12))
              ],
            ),
          ),
          SizedBox(
            width: 4,
          ),
          item["locationOBJ"] != null
              ? RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: purpleColor)),
                  onPressed: () async {
                    String url =
                        "https://www.google.com/maps/search/?api=1&query=" +
                            item["locationOBJ"]['latitude'].toString() +
                            "," +
                            item["locationOBJ"]['longitude'].toString();
                    print(url);
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                        forceWebView: false,
                        headers: <String, String>{
                          'my_header_key': 'my_header_value'
                        },
                      );
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  color: purpleColor,
                  textColor: Colors.white,
                  child: new Row(
                    children: [
                      new Icon(Icons.location_on),
                      new SizedBox(
                        width: 8,
                      ),
                      Text("Location",
                          style: GoogleFonts.comfortaa(fontSize: 12))
                    ],
                  ),
                )
              : Container(
                  width: 0.0,
                ),
        ],
      ),
      new SizedBox(
        height: 16,
      ),
      buildRequestTile(
          'Payment Method',
          (item["Payment_Method"] == 1 ? 'Bank Transfer' : 'Cach').toString() ??
              " "),

      buildRequestTile(
          'Created At',timeStamp.toDate().toString().substring(0, 10)),
      buildRequestTile('Status', item['status'].toString()),
      item["details"].toString() != "null"
          ? new ListTile(title: new Text('Comments'),
              subtitle: new Text(item["details"].toString() != "null"
                  ? item["details"].toString()
                  : " ")
              )
          : new Container(
              height: 0,
            ),
      item["locationOBJ"] != null
          ? buildRequestTile(
          'Address',
          (item["locationOBJ"]['City'] +
              ', House: ' +
              item["locationOBJ"]['House_Number'] +
              ' ' +
              ', name: ' +
              item['locationOBJ']['name'])
              .toString() ??
              " ")
          : Container(
              height: 2,
            ),
//
      item["customerObj"] != null
          ? Container(
              margin: new EdgeInsets.all(16),
              child: Card(
                child: ListTile(
                  leading: new Icon(Icons.person),
                  title: new Text("Customer: " +
                      (item["customerObj"]["name"] != null
                          ? item["customerObj"]["name"]
                          : " ")),
                  subtitle: new Text("Phone: " +
                      (item["customerObj"]["phone"] != null
                          ? item["customerObj"]["phone"]
                          : "-")),
                ),
              ),
            )
          : Container(
              height: 0,
            ),
      new Container(
        width: MediaQuery.of(context).size.width,
        padding: new EdgeInsets.symmetric(horizontal: 16),
        child: new Text(
          item["type"] == "service" ? "Services List" : "Products List",
          textAlign: TextAlign.start,
          style:
              GoogleFonts.comfortaa(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ]
      ..addAll(_getItemsList(e))
      ..addAll(_createTrackingList(e));
  }

  List<Widget> _getItemsList(e) {
    List<Widget> _widgetss = [];

    if (e["type"] == "service") {
      List services;
      try {
        services = e["servicesObj"];
      } catch (e) {
        print(e);
        services = [];
      }
      if (services == null) {
        services = [];
      }

      services.forEach((element) {
        _widgetss.add(ServicesListItem(elemnt: element));
      });
    } else {
      List products;
      try {
        products = e["productsObjs"];
      } catch (e) {
        print(e);
        products = [];
      }
      if (products == null) {
        products = [];
      }

      products.forEach((element) {
        print("adding a product to request" + element["title"]);
        _widgetss.add(ProductListItem(element: element));
      });
    }
    return _widgetss;
  }

  List<Widget> _createTrackingList(item) {
    setState(() {
      isSub = false;
    });
    Size size = MediaQuery.of(context).size;
    List<Widget> _widgetss = [];

    List ooo = item["tracking"];
    if (ooo == null) return [];
    ooo.forEach((k) {
      print(k);
      _widgetss.add(TrackingComponent(
        track: k,
        size: size,
      ));
    });

    return _widgetss;
  }

  openChat(e) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    navigate(ChatPage(
      prefs: shared,
      title: "Chat",
      chatId: e["key"],
    ));
  }

  Widget buildRequestTile(title, details) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Column(
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              new Text(details)
            ],
          ),
          new Divider(
            height: 4,
            thickness: 1,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  getData() {}
  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/components/dashboardBtn.dart';
import 'package:supplier/components/dashboard_Bag.dart';
import 'package:supplier/components/requestComponent.dart';
import 'package:supplier/screens/dashbaord/products/add.dart';
import 'package:supplier/screens/dashbaord/products/list.dart';
import 'package:supplier/screens/dashbaord/services/add.dart';
import 'package:supplier/screens/dashbaord/services/list.dart';
import 'package:supplier/utils/colors.dart';
import 'package:supplier/utils/service_full_list.dart';
import 'package:supplier/widgets/customTab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardContentPage extends StatefulWidget {
  final VoidCallback openSlideView;
  DashboardContentPage({this.openSlideView});
  @override
  _DashboardContentPageState createState() => _DashboardContentPageState();
}

class _DashboardContentPageState extends State<DashboardContentPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  String user_uid = "NNextUser";
  var firestoreInstance = FirebaseFirestore.instance;
  bool isLoadingTop = false;
  bool isLeftOpened = false;
  int totalProdectsValue = 0;
  int totalServicesValue = 0;
  String scope = "all";
  QuerySnapshot query;
  Map status = {
    "accepted": {"color": Color(0xff3366cc), "title": "Accepted"},
    "in-progress": {"color": Color(0xff990099), "title": "In Progress"},
    "completed": {"color": Color(0xff109618), "title": "Completed"},
    "canceled": {"color": Color(0xfffdbe19), "title": "Canceled"},
  };
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    getData();
    iniate();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: new Color(0xffFAFAFA),
          leading: new IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  widget.openSlideView();
                });
              }),
//              backgroundColor: Colors.white,
          elevation: 0,
        ),
        key: _scaffoldkey,
        backgroundColor: new Color(0xffFAFAFA),
        body: new SingleChildScrollView(
          child: Container(
            padding: new EdgeInsets.all(8),
//        height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                new SizedBox(
                  height: 12,
                ),
                Container(
                  padding: new EdgeInsets.only(left: 16, right: 16),
                  child: new Row(
                    children: [
                      new Text(
                        "Summary Statistics",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.comfortaa(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      )
                    ],
                  ),
                ),
                new SizedBox(
                  height: 16,
                ),
                isLoadingTop
                    ? new Center(
                        child: new CircularProgressIndicator(),
                      )
                    : new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DashboardSummaryBtn(
                            context: context,
                            title: totalServicesValue,
                            description: "Services",
                            next: AddServicePage(
                              onAddedDone: getData,
                            ),
                            icon: Icons.add,
                            callback: getData,
                            press: ServicesListPage(
                              openSlideView: null,
                            ),
                          ),
                          DashboardSummaryBtn(
                            context: context,
                            title: totalProdectsValue,
                            description: "Products",
                            next: AddProductPage(
                              onAddedDone: getData,
                            ),
                            icon: Icons.add,
                            callback: getData,
                            press: ProductsListPage(
                              openSlideView: null,
                            ),
                          ),
                        ],
                      ),
                new SizedBox(
                  height: 24,
                ),
                Container(
                  padding: new EdgeInsets.symmetric(horizontal: 16),
                  child: new Row(
                    children: [
                      new Text(
                        "Services Statistics",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.comfortaa(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      )
                    ],
                  ),
                ),
                query == null
                    ? Container(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : StatisticsBag(query: this.query, scope: scope),
//            _buildStatisticsBag(),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffEEEEEE),
//                    border: new Border.all(color: purpleColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: new TabBar(
                    controller: _tabController,
                    onTap: (i) {
                      String scope = "";
                      switch (i) {
                        case 0:
                          {
                            scope = "all";
                            break;
                          }
                        case 1:
                          {
                            scope = "service";
                            break;
                          }
                        case 2:
                          {
                            scope = "product";
                            break;
                          }
                        default:
                          scope = "all";
                      }
                      getOrders(scope);
                    },
                    indicator: CustomTabIndicator(),
//                             indicatorPadding: EdgeInsets.all(30),
                    tabs: [
                      Tab(
                        child: new Text(
                          "All",
                          style: GoogleFonts.comfortaa(
                              color: _tabController.index == 0
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                      Tab(
                        child: new Text(
                          "Servcises",
                          style: GoogleFonts.comfortaa(
                              color: _tabController.index == 1
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                      Tab(
                        child: new Text(
                          "Products",
                          style: GoogleFonts.comfortaa(
                              color: _tabController.index == 2
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                new ListTile(
                  title: new Text(
                    "Services and Products Request",
                    style:
                        GoogleFonts.comfortaa(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ]..addAll(_buildList()),
            ),
          ),
        ));
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  List<Widget> _buildList() {
    List<Widget> list = [];
    int count = 0;
    if (query == null) return [];

    query.docs.sort((a, b) {
      var adate = a['created_at']; //before -> var adate = a.expiry;
      var bdate = b['created_at']; //before -> var bdate = b.expiry;
      return bdate.compareTo(
          adate); //to get the order other way just switch `adate & bdate`
    });

    query.docs.forEach((element) {
      if (count > 5) return;
      print(element.id);
      Map item = element.data();
      item["key"] = element.id;
      print(item);
      list.add(OrderRequestItem(
        item: item,
      ));
      count++;
    });
    return list;
  }

  iniate() {
    _tabController = TabController(vsync: this, length: 3);

    SharedPreferences.getInstance().then((sp) {
      var groupID = sp.get("groupID").toString();
      setState(() {
        print(user_uid);
        user_uid = groupID;
        getData();
      });
    });
  }

  void getData() async {
    setState(() {
      isLoadingTop = true;
      totalProdectsValue = 0;
      totalServicesValue = 0;
    });
    var products = await firestoreInstance
        .collection("products")
        .where("owner", isEqualTo: user_uid)
        .get();

    var services = await firestoreInstance
        .collection("services")
        .where("owner", isEqualTo: user_uid)
        .get();

    isLoadingTop = false;
    totalProdectsValue = products.docs.length;
    totalServicesValue = services.docs.length;
    getOrders("all");
  }

  getOrders(type) async {
    setState(() {
      query = null;
    });
    if (type == "all") {
      await firestoreInstance
          .collection("request")
          .where("supplier", isEqualTo: user_uid)
          .get()
          .then((value) {
        setState(() {
          query = value;
        });
      });
    } else {
      await firestoreInstance
          .collection("request")
          .where("supplier", isEqualTo: user_uid)
          .where("type", isEqualTo: type)
          .get()
          .then((value) {
        setState(() {
          query = value;
        });
      });
    }
  }
}

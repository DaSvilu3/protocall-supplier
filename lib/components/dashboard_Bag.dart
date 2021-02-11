import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/utils/colors.dart';

class StatisticsBag extends StatefulWidget {
  StatisticsBag({this.query, this.scope});
  String scope;
  QuerySnapshot query;

  @override
  _StatisticsBagState createState() =>
      _StatisticsBagState(query: this.query, scope: this.scope);
}

class _StatisticsBagState extends State<StatisticsBag> {
  _StatisticsBagState({this.query, this.scope});
  String scope;
  bool isLoadingStatistics = true;
  var totalOrdersValue = 0.0;
  final firestoreInstance = FirebaseFirestore.instance;
  List<charts.Series<Task, String>> _seriesPieData;
  QuerySnapshot query;
  var piedata = [
    new Task('Accepted', "accepted", 10, Color(0xff3366cc)),
    new Task('In Progress', "in-progress", 4, Color(0xff990099)),
    new Task('Completed', "canceled", 40, Color(0xff109618)),
    new Task('Canceled', "completed", 6, Color(0xfffdbe19)),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("I statistics bag");
//    print(query.)
    iniateStatistics(scope);
  }

  void iniateStatistics(scope) async {
    if (query == null) {
      print("query is null");
      return;
    }
    try {
      var _piedata = piedata;
      setState(() {
        isLoadingStatistics = true;
        totalOrdersValue = 0.0;
        piedata = null;
      });
      for (int i = 0; i < _piedata.length; i++) {
        _piedata[i].taskvalue =
            getCountSection(scope, _piedata[i].small, query.documents);
        totalOrdersValue += (_piedata[i].taskvalue ?? 0);
      }
      print("I am in stage 3");
      _seriesPieData = List<charts.Series<Task, String>>();
      _seriesPieData.add(
        charts.Series(
          domainFn: (Task task, _) => task.task,
          measureFn: (Task task, _) => task.taskvalue,
          colorFn: (Task task, _) =>
              charts.ColorUtil.fromDartColor(task.colorval),
          id: 'Air Pollution',
          data: _piedata,
          labelAccessorFn: (Task row, _) => '${row.taskvalue}',
        ),
      );
      print("I am in stage 4");

      setState(() {
        isLoadingStatistics = false;
        piedata = _piedata;
      });
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoadingStatistics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = 0.0;
    try {
      _seriesPieData[0].data.forEach((element) {
        total += element.taskvalue;
      });
    } catch (e) {
      print(e);
    }

    return new SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: isLoadingStatistics
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : _seriesPieData == null || total == 0.0
              ? Center(
                  child: new Text("No orders yet"),
                )
              : new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    new Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: charts.PieChart(_seriesPieData,
                              animate: false,
                              animationDuration: Duration(seconds: 3),
                              defaultRenderer: new charts.ArcRendererConfig(
                                  arcWidth: 25,
                                  arcRendererDecorators: [
                                    new charts.ArcLabelDecorator(
                                        labelPosition:
                                            charts.ArcLabelPosition.auto)
                                  ])),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: new Center(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Text(
                                  "Total",
                                  style: GoogleFonts.comfortaa(
                                      fontSize: 24, color: Colors.grey),
                                ),
                                new Text(
                                  totalOrdersValue.toStringAsFixed(0),
                                  style: GoogleFonts.comfortaa(
                                      fontSize: 39,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    piedata == null
                        ? Container(
                            height: MediaQuery.of(context).size.width * 0.5,
                            child: new Center(
                              child: new Text("Not Enough Data to display"),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Color(0xfff5f5f5),
                                borderRadius: BorderRadius.circular(25)),
//            height: MediaQuery.of(context).size.width * 0.5,
                            child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: piedata
                                  .map((e) =>
                                      _buildChartTile(e.colorval, e.task))
                                  .toList(),
                            ),
                          )
                  ],
                ),
    );
  }

  double getCountSection(scope, status, List doc) {
    double count = 0;
    doc.forEach((element) {
      print("checkking: " +
          status +
          " status " +
          element["status"] +
          " type : " +
          element["type"]);
      if (element["status"] == status && scope == "all") {
        count++;
      } else {
        if (element["status"] == status && element["type"] == scope) {
          count++;
        }
      }
    });

    return count;
  }

  Widget _buildChartTile(color, title) {
    return Container(
      margin: new EdgeInsets.only(top: 8),
      child: new Row(
        children: [
          new Container(
            height: 15,
            width: 15,
            decoration: new BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          new SizedBox(
            width: 4,
          ),
          new Text(
            title,
            style: GoogleFonts.comfortaa(fontSize: 17),
          )
        ],
      ),
    );
  }

  int getTotalOrders() {
    int total = 0;
    piedata.map((e) {
      total += e.taskvalue.toInt();
      print(e.taskvalue);
    });
    return total;
  }
}

class Task {
  String task;
  String small;
  double taskvalue;
  Color colorval;

  Task(this.task, this.small, this.taskvalue, this.colorval);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/utils/colors.dart';

class ReviewComponent extends StatelessWidget {
  ReviewComponent({this.map});
  var map;
  @override
  Widget build(BuildContext context) {
    print(map);
    DateTime time = DateTime.parse(map["date"]);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(width: 60, height: 60, child: new CircleAvatar()),
          Expanded(
            child: Container(
              margin: new EdgeInsets.only(bottom: 16, right: 16, left: 16),
              padding: new EdgeInsets.all(16),
              decoration: new BoxDecoration(
                  color: Color(0xffF5F5F5),
                  borderRadius: new BorderRadius.circular(16)),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Text(
                    map["customerObj"]["name"],
                    style:
                        GoogleFonts.comfortaa(fontSize: 16, color: purpleColor),
                  ),
                  new SizedBox(
                    height: 8,
                  ),
                  new Row(
                    children: [1, 2, 3, 4, 5]
                        .map((e) => Container(
                              child: int.parse(map["rate"].toString()) >= e
                                  ? Icon(
                                      Icons.star,
                                      color: Color(0xffE7E76B),
                                    )
                                  : Icon(Icons.star_border),
                            ))
                        .toList(),
                  ),
                  new SizedBox(
                    height: 16,
                  ),
                  new Text(
                    map["description"] ?? "-",
                    style: GoogleFonts.comfortaa(),
                  ),
                  new SizedBox(
                    height: 8,
                  ),
                  new Text(DateTime.now().difference(time).inHours < 24
                      ? DateTime.now().difference(time).inHours.toString() +
                          " hours ago"
                      : time.day.toString() +
                          "-" +
                          time.month.toString() +
                          "-" +
                          time.year.toString())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

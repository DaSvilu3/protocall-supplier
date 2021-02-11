import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TrackingComponent extends StatelessWidget {
  TrackingComponent({this.size, this.track});
  Size size;
  Map track;
  Map status = {
    "accepted": {"color": Color(0xff3366cc), "title": "Accepted"},
    "in-progress": {"color": Color(0xff990099), "title": "In Progress"},
    "completed": {"color": Color(0xff109618), "title": "Completed"},
    "canceled": {"color": Color(0xfffdbe19), "title": "Canceled"},
  };
  @override
  Widget build(BuildContext context) {
    String timestamp = track["date"];
    DateTime date = DateTime.parse(timestamp);
    print("date format");
    print(new DateFormat("hh:mm:ss a").format(date));

    return new Row(
      children: [
        new Container(
          width: size.width * 0.25 - 16,
          height: size.width * 0.25,
          color: Colors.transparent,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Text(
                date.day.toString(),
                style: GoogleFonts.comfortaa(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              new Text(
                (DateFormat.MMM().format(date)).toString(),
                style: GoogleFonts.comfortaa(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              new Text(
                date.year.toString(),
                style: GoogleFonts.comfortaa(),
              ),
            ],
          ),
        ),
        new Stack(
          children: [
            new Container(
                width: size.width * 0.75 - 16,
                height: size.width * 0.29,
                margin: new EdgeInsets.only(left: 8),
                decoration: new BoxDecoration(
                    border: new Border(
                        left: new BorderSide(
                            width: 2,
                            color: Colors.grey,
                            style: BorderStyle.solid))),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Container(
                      padding: new EdgeInsets.only(
                          left: 16, top: 16, bottom: 16, right: 32),
                      decoration: new BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: new BorderRadius.only(
                            topRight: Radius.circular(size.width * 0.25),
                            bottomRight: Radius.circular(size.width * 0.25),
                          )),
                      child: new Text(
                        status[track["status"]]["title"],
                        style: GoogleFonts.comfortaa(
                            fontWeight: FontWeight.bold,
                            color: status[track["status"]]["color"]),
                      ),
                    ),
                    new Container(
                      padding: new EdgeInsets.all(8),
                      child: new Text(
                        track["details"] ?? " ",
                        style: GoogleFonts.comfortaa(),
                      ),
                    ),
                    new Container(
                      padding: new EdgeInsets.all(8),
                      child: new Text(
                        new DateFormat("hh:mm:ss a").format(date),
                        style: GoogleFonts.comfortaa(),
                      ),
                    )
                  ],
                )),
            new Positioned(
                top: 16,
                left: 0,
                child: new Container(
                  width: 16,
                  height: 16,
                  decoration: new BoxDecoration(
                      color: status[track["status"]]["color"],
                      shape: BoxShape.circle),
                ))
          ],
        ),
      ],
    );
  }
}

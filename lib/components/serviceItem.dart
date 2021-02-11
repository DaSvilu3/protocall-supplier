import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/screens/dashbaord/services/edit.dart';
import 'package:supplier/screens/showImage.dart';
import 'package:supplier/utils/category_list.dart';
import 'package:supplier/utils/colors.dart';

class ServicesListItem extends StatefulWidget {
  ServicesListItem({this.elemnt, this.callback});
  final Map elemnt;
  VoidCallback callback;

  @override
  _ServicesListItemState createState() =>
      _ServicesListItemState(elemnt: this.elemnt);
}

class _ServicesListItemState extends State<ServicesListItem> {
  _ServicesListItemState({this.elemnt});
  final Map elemnt;
  @override
  Widget build(BuildContext context) {
    List cities = [];
    List photos = [];
    bool isDisabled =
        elemnt["disable"] != null && elemnt["disable"] == true ? true : false;
    try {
      cities = elemnt["locations"];
      photos = elemnt["photos"];

      if (photos == null) {
        photos = [];
      }
    } catch (e) {
      cities = [];
      photos = [];
    }
    DateTime createdDate = null;
    print("here is list");
    if (elemnt["time"] != null) {
      createdDate = DateTime.parse(elemnt["time"]);
      print(DateTime.now().difference(createdDate).inMinutes);
    }

    String url = CategoryClasses().getSubCategoryURL(elemnt['category']);

    try {
      return new Container(
          margin: new EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: new Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: new EdgeInsets.all(8),
                child: ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: new ListTile(
                      leading: new CachedNetworkImage(
                          imageUrl: url == null ? " " : url),
                      title: new Text(
                        isDisabled
                            ? elemnt["category"] + " (Disabled)"
                            : elemnt['category'],
                        style: GoogleFonts.comfortaa(),
                      ),
                      subtitle: new Text(elemnt["description"],
                          style: GoogleFonts.comfortaa()),
                      onTap: () {},
                    ),
                    children: [
                      new Text(
                        (elemnt['toBeQouted'] == null ||
                                elemnt['toBeQouted'] == false
                            ? elemnt["price"] + " OMR"
                            : "To be Qouted Later"),
                        style: GoogleFonts.comfortaa(fontSize: 20),
                      ),
                      new SizedBox(
                        height: 16,
                      ),
                      new Text(
                        "Offers / Contract",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.comfortaa(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      new Container(
                        child: new Text(elemnt["contract"],
                            style: GoogleFonts.comfortaa()),
                      ),
                      new SizedBox(
                        height: 16,
                      ),
                      new Text(
                        "Grantee",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.comfortaa(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      new Container(
                        child: new Text(elemnt["grantee"],
                            textAlign: TextAlign.start,
                            style: GoogleFonts.comfortaa()),
                      ),
                      new SizedBox(
                        height: 16,
                      ),
                      Container(
                        height: 60,
                        margin: new EdgeInsets.symmetric(horizontal: 16),
                        child: new ListView(
                          scrollDirection: Axis.horizontal,
                          children: cities
                              .map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Chip(
                                      backgroundColor:
                                          purpleColor.withOpacity(0.1),
                                      label: new Text(
                                        e,
                                        style: GoogleFonts.comfortaa(
                                            color: purpleColor),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      photos.length == 0
                          ? Container(
                              height: 0.1,
                            )
                          : Container(
                              height: 200,
                              margin: new EdgeInsets.symmetric(horizontal: 16),
                              child: new ListView(
                                scrollDirection: Axis.horizontal,
                                children: photos
                                    .map((e) => Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              120,
                                          margin: new EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: InkWell(
                                            onTap: () {
                                              navigate(ShowImage(
                                                type: 0,
                                                url: e,
                                              ));
                                            },
                                            child: new CachedNetworkImage(
                                              imageUrl: e["thumb"],
                                              progressIndicatorBuilder:
                                                  (context, url, progress) =>
                                                      CircularProgressIndicator(
                                                value: progress.progress,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                    ]),
              ),
            ),
            actions: elemnt["time"] != null &&
                    DateTime.now().difference(createdDate).inMinutes <= 10
                ? canDelete()
                : <Widget>[
                    editWidget(),
                  ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Edit',
                color: purpleColor,
                icon: Icons.edit,
                onTap: () {
                  navigate(EditServicePage(
                    callback: callbackAction,
                    data: elemnt,
                  ));
                },
              ),
            ],
          ));
    } catch (e) {
      return Container(
        height: 0.1,
      );
    }
  }

  List<Widget> canDelete() {
    print(elemnt["key"]);
    bool isDisabled =
        elemnt["disable"] != null && elemnt["disable"] == true ? true : false;
    return [
      editWidget(),
      IconSlideAction(
        caption: 'Delete',
        color: Colors.red,
        icon: Icons.delete,
        onTap: () {
          showDialog(
              context: context,
              child: AlertDialog(
                title: new Text("Delete"),
                content: new Text("Are you sure to delete this item?"),
                actions: [
                  new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FirebaseFirestore.instance
                            .collection("services")
                            .doc(elemnt["key"])
                            .delete()
                            .then((value) => widget.callback);
                      },
                      child: new Text("Yes")),
                  new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: new Text("No")),
                ],
              ));
        },
      )
    ];
  }

  Widget editWidget() {
    print(elemnt["key"]);
    bool isDisabled =
        elemnt["disable"] != null && elemnt["disable"] == true ? true : false;
    return IconSlideAction(
      caption: isDisabled ? 'Enable' : 'Disable',
      color: isDisabled ? Colors.yellow : Colors.blueAccent,
      icon: isDisabled ? Icons.do_not_disturb : Icons.do_not_disturb_on,
      onTap: () {
        showDialog(
            context: context,
            child: AlertDialog(
              title: new Text("Disable"),
              content: new Text("Are you sure to disable this item?"),
              actions: [
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      FirebaseFirestore.instance
                          .collection("services")
                          .doc(elemnt["key"])
                          .update({"disable": !isDisabled})
                          .then((value) => null)
                          .then((value) => widget.callback());
                    },
                    child: new Text("Yes")),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("No")),
              ],
            ));
      },
    );
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }

  void callbackAction() {
    widget.callback();
  }
}

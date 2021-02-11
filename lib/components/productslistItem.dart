import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/screens/dashbaord/products/edit.dart';
import 'package:supplier/screens/showImage.dart';
import 'package:supplier/utils/colors.dart';

class ProductListItem extends StatefulWidget {
  ProductListItem({this.element, this.callback});
  Map element;
  VoidCallback callback;
  @override
  _ProductListItemState createState() =>
      _ProductListItemState(elemnt: this.element);
}

class _ProductListItemState extends State<ProductListItem> {
  _ProductListItemState({this.elemnt});
  Map elemnt;
  @override
  Widget build(BuildContext context) {
    print(elemnt);
    List photos = [];
    try {
      photos = elemnt["photos"];
    } catch (e) {
      photos = [];
    }
    DateTime createdDate = null;
    print("here is list");
    print(elemnt["time"]);
    if (elemnt["time"] != null) {
      createdDate = DateTime.parse(elemnt["time"]);
    }

    if (photos == null) photos = [];
    return new Container(
        margin: new EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: new Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                padding: new EdgeInsets.all(8),
                child: ExpansionTile(
                    leading: photos.length > 0
                        ? new Container(
                            width: 80,
                            height: 80,
                            child: new CachedNetworkImage(
                                imageUrl: photos[0]["thumb"]),
                          )
                        : Container(
                            width: 2,
                          ),
                    title: new Text(
                      elemnt['title'],
                      style: GoogleFonts.comfortaa(),
                    ),
                    subtitle: new Text(
                      elemnt["category"],
                      style: GoogleFonts.comfortaa(),
                    ),
                    children: [
                      new Text((elemnt["price"] ?? "") + " OMR",
                          style: GoogleFonts.comfortaa(fontSize: 18)),
                      new SizedBox(
                        height: 16,
                      ),
                      new Text(elemnt["description"],
                          style: GoogleFonts.comfortaa()),
                      new SizedBox(
                        height: 16,
                      ),
                      photos.length == 0
                          ? Container(
                              height: 16,
                            )
                          : Container(
                              height: 150,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: photos.map((e) {
                                  return Container(
                                    height: 300,
                                    width:
                                        MediaQuery.of(context).size.width - 120,
                                    margin:
                                        new EdgeInsets.symmetric(horizontal: 8),
                                    child: InkWell(
                                      onTap: () {
                                        navigate(ShowImage(
                                          type: 0,
                                          url: e["url"],
                                        ));
                                      },
                                      child: new CachedNetworkImage(
                                        imageUrl: e["url"],
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                CircularProgressIndicator(
                                          value: progress.progress,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                    ]),
              )),
          actions: elemnt["time"] != null &&
                  DateTime.now().difference(createdDate).inMinutes <= 10
              ? canDelete()
              : <Widget>[editWidget()],
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Edit',
              color: purpleColor,
              icon: Icons.edit,
              onTap: () {
                navigate(
                    EditProductPage(data: elemnt, callBack: callbackAction));
              },
            ),
          ],
        ));
  }

  void callbackAction() {
    widget.callback();
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
                            .collection("products")
                            .doc(elemnt["key"])
                            .set({}).then((value) => widget.callback);
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
                          .collection("products")
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
}

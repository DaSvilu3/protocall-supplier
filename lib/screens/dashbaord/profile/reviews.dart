import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supplier/components/review.dart';

class ReviewsList extends StatefulWidget {
  ReviewsList({this.groupID});
  final String groupID;
  @override
  _ReviewsListState createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  List reviews = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.groupID != null) {
      getData();
    }
  }

  getData() async {
    setState(() {
      reviews = [];
    });
    var ref = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.groupID)
        .get();
    var rrr = ref.reference;
    print("users/" + widget.groupID);
    FirebaseFirestore.instance
        .collection("reviews")
        .where("supplier", isEqualTo: rrr)
        .get()
        .then((sps) {
      sps.docs.forEach((element) async {
        var data = element.data();
        DocumentReference cstm = element["customer"];
        await cstm.get().then((value) {
          data["customerObj"] = value.data();
          setState(() {
            reviews.add(data);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffFAFAFA),
      child: ListView(
        children: reviews.map((e) => ReviewComponent(map: e)).toList(),
      ),
    );
  }
}

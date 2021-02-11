import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

typedef IntCallback = Function(int index);

class MediaComponent extends StatelessWidget {
  MediaComponent({this.map, this.index, this.removeItem});
  Map map;
  final int index;
  final IntCallback removeItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Stack(
        children: [
          Container(
            color: Colors.red,
            width: 90,
            height: 90,
            margin: new EdgeInsets.all(8),
            child: new CachedNetworkImage(
              imageUrl: map["thumb"],
              fit: BoxFit.cover,
            ),
          ),
          new Positioned(
            top: 0,
            right: 0,
            height: 30,
            width: 30,
            child: InkWell(
              onTap: () {
                removeItem(index);
              },
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.red,
                    border: new Border.all(color: Colors.redAccent, width: 2),
                    shape: BoxShape.circle),
                child: Center(
                    child: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 15,
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}

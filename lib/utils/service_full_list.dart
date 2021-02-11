import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'testfile.dart';

class UploadAllServicePhotos {
  var list = [];

  void doUpload() async {
    var inst =
        FirebaseFirestore.instance.collection('services_category_second');
    file.forEach((element) {
      inst.doc(element['id']).set(element);
    });
  }

//  void doUpload() async {
//    var inst = FirebaseFirestore.instance.collection("product_category_second");
//    var mainCategory = new CategoryClasses().getMainCategory();
//    print(mainCategory);
//    Map mainCategoryUpdate = {
//      "Maintenance": "YRwyxXmnBJjt1TXzf60",
//      "Cleaning": "ZMZXb2ohe7eXiTBBaP8",
//      "Health": "ddOOR7cUqZJBi1X4JmU",
//      "Safety": "R73v4a2aGQxSp0svNsJ",
//      "Digital products": "hGSktKby7IkFFAVUwm4",
//      "Beauty Woman": "nKoozpcverIJNEKGu5p",
//      "Beauty Men": "T78cY7Mk0vEpEzQlw9N",
//      "Pest control": "9VK6kZpT4bKMY0v5ZXo",
//    };
////    Set<String> unique = new Set<String>();
////
////    list.forEach((element) {
////      unique.add(element['Main']);
////    });
////
////    print(unique);
//
////
////    await list.forEach((element) async {
////      String uuid = getRandomString(19);
//////      String url = await photoOption(map["url"]);
////      Map obj = {"main": element, "id": uuid};
////      await inst.document(uuid).setData({"main": element, "id": uuid});
////      mainCategoryUpdate[element] = uuid;
////      print(mainCategoryUpdate);
////    });
////    print(mainCategoryUpdate);
//////
//    list.forEach((element) async {
//      String uuid = getRandomString(10);
////      String url = await photoOption(element["url"]);
////      element["url"] = url;
//      element["id"] = uuid;
//      element["main"] = element["Main"];
//      element["sub"] = element["Sub"];
//      element["main_uid"] = mainCategoryUpdate[element["main"]];
//
//      inst.document(uuid).setData(element);
//    });
//  }

  Future<String> photoOption(url) async {
    String downloadableUrl = "";
//    try {
//    final StorageReference _storage =
//        FirebaseStorage().ref().child("new_icons/" + url);
//
//    return await _storage.getDownloadURL();

//    }
  }

  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

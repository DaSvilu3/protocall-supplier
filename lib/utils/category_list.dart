import 'package:flutter/material.dart';

class CategoryClasses {
  static List<Map> CATEGORY_LIST = [];
  static List<Map> PRODUCTS_LIST = [];

  Set<String> getMainCategory() {
    Set<String> unique = new Set<String>();
    List<Map> CATEGORY_LIST_temp = [];
    CATEGORY_LIST.sort((a, b) {
//      print(a);
      return a["main"].compareTo(b["main"]);
    });
    CATEGORY_LIST.forEach((element) {
      if (element["sub"] == null) {
        unique.add(element["main"]);
        CATEGORY_LIST_temp.add(element);
      }
    });

    CATEGORY_LIST_temp.sort((a, b) {
      return a["main"].compareTo(b["main"]);
    });
    return unique;
  }

  Set<String> getMainSubs(String category) {
    Set<String> items = new Set<String>();
    List<Map> CATEGORY_LIST_temp = [];
    CATEGORY_LIST.forEach((element) {
      if (element["sub"] != null) {
        CATEGORY_LIST_temp.add(element);
      }
    });
    CATEGORY_LIST_temp.sort((a, b) {
      return a["sub"].compareTo(b["sub"]);
    });
    CATEGORY_LIST_temp.forEach((element) {
      if (element['main'] == category) {
        items.add(element['sub']);
      }
    });

    return items;
  }

  String getSubId(obj) {
    String uid = "-";
    CATEGORY_LIST.forEach((element) {
      if (element["sub"] == obj) {
        uid = element["id"];
      }
    });
    return uid;
  }

  Set<String> getProductsMainCategory() {
    Set<String> unique = new Set<String>();
    List<Map> CATEGORY_LIST_temp = [];
    print("getting products main");
    PRODUCTS_LIST.sort((a, b) {
//      print(a);
      return a["main"].compareTo(b["main"]);
    });
    PRODUCTS_LIST.forEach((element) {
      if (element["sub"] == null) {
        unique.add(element["main"]);
        CATEGORY_LIST_temp.add(element);
      }
    });
//    CATEGORY_LIST_temp.forEach((element) {
//      CATEGORY_LIST.remove(element);
//    });

    CATEGORY_LIST_temp.sort((a, b) {
//      print(a);
      return a["main"].compareTo(b["main"]);
    });
    print(unique);
    return unique;
  }

  Set<String> getProductsMainSubs(String category) {
    Set<String> items = new Set<String>();

    PRODUCTS_LIST.forEach((element) {
      if (element['main'] == category && element["sub"] != null) {
        items.add(element['sub']);
      }
    });
//    PRODUCTS_LIST.sort((a, b) {
//      return a["sub"].compareTo(b["sub"]);
//    });
    return items;
  }

  String getSubCategoryURL(sub) {
    String url = "";
    CATEGORY_LIST.forEach((element) {
      if (element["sub"] == sub) {
        url = element["url"];
      }
    });

    return url;
  }

  String getSubProductId(obj) {
    String uid = "-";
    PRODUCTS_LIST.forEach((element) {
      if (element["sub"] != null && element["sub"] == obj) {
        uid = element["id"];
        return;
      }
    });
    return uid;
  }
}

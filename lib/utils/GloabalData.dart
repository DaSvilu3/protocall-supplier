import 'package:flutter/material.dart';

class GlobalData {
  static List<Map> ordersData = [];
  static List<Map> CATEGORY_LIST = [];
  static List<Map> products = [];
  static List<Map> services = [];

  Set<String> getMainCategory() {
    Set<String> unique = new Set<String>();
    CATEGORY_LIST.forEach((element) {
      unique.add(element['Main']);
    });
    return unique;
  }

  List<String> getMainSubs(String category) {
    List<String> items = [];
    CATEGORY_LIST.forEach((element) {
      if (element['Main'] == category) {
        items.add(element['Sub']);
      }
    });

    return items;
  }
}

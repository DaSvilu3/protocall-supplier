import 'package:flutter/material.dart';

List locations = [
  {
    "title_ar": "مسقط",
    "statear": "مسقط",
    "title_en": "Muscat",
    "stateen": "Muscat"
  },
  {
    "title_ar": "مطرح",
    "statear": "مسقط",
    "title_en": "Muttrah",
    "stateen": "Muscat"
  },
  {
    "title_ar": "بوشر",
    "statear": "مسقط",
    "title_en": "Bawshar",
    "stateen": "Muscat"
  },
  {
    "title_ar": "السيب",
    "statear": "مسقط",
    "title_en": "Seeb",
    "stateen": "Muscat"
  },
  {
    "title_ar": "العامرات",
    "statear": "مسقط",
    "title_en": "Al Amarat",
    "stateen": "Muscat"
  },
  {
    "title_ar": "قريات",
    "statear": "مسقط",
    "title_en": "Qurayyat",
    "stateen": "Muscat"
  },
  {
    "title_ar": "الخابورة",
    "statear": "شمال الباطنة",
    "title_en": "Al Khaburah",
    "stateen": "Al Batinah North"
  },
  {
    "title_ar": "صحم",
    "statear": "شمال الباطنة",
    "title_en": "Sohar",
    "stateen": "Al Batinah North"
  },
  {
    "title_ar": "صحار",
    "statear": "شمال الباطنة",
    "title_en": "Saham",
    "stateen": "Al Batinah North"
  },
  {
    "title_ar": "لوى",
    "statear": "شمال الباطنة",
    "title_en": "Liwa",
    "stateen": "Al Batinah North"
  },
  {
    "title_ar": "شناص",
    "statear": "شمال الباطنة",
    "title_en": "Shinas",
    "stateen": "Al Batinah North"
  },
  {
    "title_ar": "السويق",
    "statear": "شمال الباطنة",
    "title_en": "Suwayq",
    "stateen": "Al Batinah North"
  },
  {
    "title_ar": "بركاء",
    "statear": "جنوب الباطنة",
    "title_en": "Barka",
    "stateen": "Al Batinah South"
  },
  {
    "title_ar": "المصنعة",
    "statear": "جنوب الباطنة",
    "title_en": "Al Musanaah",
    "stateen": "Al Batinah South"
  },
  {
    "title_ar": "الرستاق",
    "statear": "جنوب الباطنة",
    "title_en": "Rustaq",
    "stateen": "Al Batinah South"
  },
  {
    "title_ar": "العوابي",
    "statear": "جنوب الباطنة",
    "title_en": "Al Awabi",
    "stateen": "Al Batinah South"
  },
  {
    "title_ar": "وادي المعاول",
    "statear": "جنوب الباطنة",
    "title_en": "Wadi Al Maawil",
    "stateen": "Al Batinah South"
  },
  {
    "title_ar": "نخل",
    "statear": "جنوب الباطنة",
    "title_en": "Nakhal",
    "stateen": "Al Batinah South"
  },
  {
    "title_ar": "سمائل",
    "statear": "الداخلية",
    "title_en": "Samail",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "بدبد",
    "statear": "الداخلية",
    "title_en": "Bidbid",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "نزوى",
    "statear": "الداخلية",
    "title_en": "Nizwa",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "الحمراء",
    "statear": "الداخلية",
    "title_en": "Al Hamra",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "بهلاء",
    "statear": "الداخلية",
    "title_en": "Bahla",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "منح",
    "statear": "الداخلية",
    "title_en": "Manah",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "إزكي",
    "statear": "الداخلية",
    "title_en": "Izki",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "أدم",
    "statear": "الداخلية",
    "title_en": "Adam",
    "stateen": "Ad Dakhiliyah"
  },
  {
    "title_ar": "عبري",
    "statear": "الظاهرة",
    "title_en": "Ibri",
    "stateen": "Ad Dhahirah"
  },
  {
    "title_ar": "ضنك",
    "statear": "الظاهرة",
    "title_en": "Dank ",
    "stateen": "Ad Dhahirah"
  },
  {
    "title_ar": "ينقل",
    "statear": "الظاهرة",
    "title_en": "Yanqul",
    "stateen": "Ad Dhahirah"
  },
  {
    "title_ar": "البريمي",
    "statear": "البريمي",
    "title_en": "Al Buraimi",
    "stateen": "Al Buraimi"
  },
  {
    "title_ar": "محضة",
    "statear": "البريمي",
    "title_en": "Mahdah",
    "stateen": "Al Buraimi"
  },
  {
    "title_ar": "السنينة",
    "statear": "البريمي",
    "title_en": "As Sunaynah",
    "stateen": "Al Buraimi"
  },
  {
    "title_ar": "مدحاء",
    "statear": "مسندم",
    "title_en": "Madha",
    "stateen": "Musandam"
  },
  {
    "title_ar": "دبا",
    "statear": "مسندم",
    "title_en": "Daba Al Bayah",
    "stateen": "Musandam"
  },
  {
    "title_ar": "خصب",
    "statear": "مسندم",
    "title_en": "Khasab",
    "stateen": "Musandam"
  },
  {
    "title_ar": "بخا",
    "statear": "مسندم",
    "title_en": "Bukha",
    "stateen": "Musandam"
  },
  {
    "title_ar": "صور",
    "statear": "جنوب الشرقية",
    "title_en": "Sur",
    "stateen": "Ash Sharqiyah South"
  },
  {
    "title_ar": "جعلان بني بوحسن",
    "statear": "جنوب الشرقية",
    "title_en": "Jalan Bani Bu Hassan",
    "stateen": "Ash Sharqiyah South"
  },
  {
    "title_ar": "جعلان بني بوعلي",
    "statear": "جنوب الشرقية",
    "title_en": "Jalan Bani Bu Ali",
    "stateen": "Ash Sharqiyah South"
  },
  {
    "title_ar": "الكامل والوافي",
    "statear": "جنوب الشرقية",
    "title_en": "Al Kamil Wal Wafi",
    "stateen": "Ash Sharqiyah South"
  },
  {
    "title_ar": "مصيرة",
    "statear": "جنوب الشرقية",
    "title_en": "Masirah",
    "stateen": "Ash Sharqiyah South"
  },
  {
    "title_ar": "وادي بني خالد",
    "statear": "شمال الشرقية",
    "title_en": "Wadi Bani Khaled",
    "stateen": "Ash Sharqiyah North"
  },
  {
    "title_ar": "دماء والطائيين",
    "statear": "شمال الشرقية",
    "title_en": "Dema Wa Thaieen",
    "stateen": "Ash Sharqiyah North"
  },
  {
    "title_ar": "القابل",
    "statear": "شمال الشرقية",
    "title_en": "Al Qabil",
    "stateen": "Ash Sharqiyah North"
  },
  {
    "title_ar": "إبرا",
    "statear": "شمال الشرقية",
    "title_en": "Ibra",
    "stateen": "Ash Sharqiyah North"
  },
  {
    "title_ar": "المضيبي",
    "statear": "شمال الشرقية",
    "title_en": "Al-Mudhaibi",
    "stateen": "Ash Sharqiyah North"
  },
  {
    "title_ar": "بدية",
    "statear": "شمال الشرقية",
    "title_en": "Bidiyah",
    "stateen": "Ash Sharqiyah North"
  },
  {
    "title_ar": "هيما",
    "statear": "الوسطى",
    "title_en": "Haima",
    "stateen": "Al Wusta"
  },
  {
    "title_ar": "محوت",
    "statear": "الوسطى",
    "title_en": "Mahout",
    "stateen": "Al Wusta"
  },
  {
    "title_ar": "الدقم",
    "statear": "الوسطى",
    "title_en": "Duqm",
    "stateen": "Al Wusta"
  },
  {
    "title_ar": "الجازر",
    "statear": "الوسطى",
    "title_en": "Al Jazer",
    "stateen": "Al Wusta"
  },
  {
    "title_ar": "شليم وجزر الحلانيات",
    "statear": "ظفار",
    "title_en": "Shalim and the Hallaniyat Islands",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "سدح",
    "statear": "ظفار",
    "title_en": "Sadah",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "مرباط",
    "statear": "ظفار",
    "title_en": "Mirbat",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "طاقة",
    "statear": "ظفار",
    "title_en": "Taqah",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "صلالة",
    "statear": "ظفار",
    "title_en": "Salalah",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "رخيوت",
    "statear": "ظفار",
    "title_en": "Rakhyut",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "ضلكوت",
    "statear": "ظفار",
    "title_en": "Dhalkut",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "ثمريت",
    "statear": "ظفار",
    "title_en": "Thumrait",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "المزيونة",
    "statear": "ظفار",
    "title_en": "Al-Mazyona",
    "stateen": "Dhofar"
  },
  {
    "title_ar": "مقشن",
    "statear": "ظفار",
    "title_en": "Muqshin",
    "stateen": "Dhofar"
  }
];

Set<String> getMainCategory() {
  Set<String> unique = new Set<String>();
  locations.forEach((element) {
    unique.add(element['stateen']);
  });
  return unique;
}

List<String> getMainSubs(String category) {
  List<String> items = [];
  locations.forEach((element) {
    if (element['stateen'] == category) {
      items.add(element['title_en']);
    }
  });
  return items;
}

import 'dart:convert';

import 'package:calq_abiturnoten/database/database.dart';
import 'package:flutter/cupertino.dart';

class JSONUtil {
  Future<void> loadDemoData(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/json/demo_data.json");
    final jsonResult = jsonDecode(data);

    DatabaseClass.Shared.hasFiveexams = false;
    DatabaseClass.Shared.rainbowEnabled = false;

    for (dynamic sub in jsonResult) {
      String name = tryCast(sub["name"]) ?? "???";
      String color = tryCast(sub["color"]) ?? "ededed";
      bool lk = tryCast(sub["lk"]) ?? false;
      String inactiveYears = tryCast(sub["inactiveYears"]) ?? "";

      await DatabaseClass.Shared.createSubject(name, color, lk ? 1 : 0,
              inactiveYears: inactiveYears)
          .then((subID) async {
        for (dynamic test in sub["subjecttests"]) {
          String name = tryCast(test["name"]) ?? "???";
          int points = tryCast(test["grade"]) ?? 0;
          int year = tryCast(test["year"]) ?? 0;
          bool big = tryCast(test["big"]) ?? false;
          String dateString = tryCast(test["date"]) ?? "";
          int date = int.parse(dateString);

          await DatabaseClass.Shared.createTest(subID, name, points, year,
              DateTime.fromMillisecondsSinceEpoch(date * 1000), big ? 1 : 0);
        }
      });
    }
  }
}

T? tryCast<T>(dynamic x, {T? fallback}) {
  try {
    return (x as T);
  } catch (e) {
    print('CastError when trying to cast $x to $T!');
    return fallback;
  }
}

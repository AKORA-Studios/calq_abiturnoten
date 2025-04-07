import 'package:flutter/material.dart';

const calqColor = Color(0xff428fe3);

Widget card(Widget content) {
  return Padding(
    padding: const EdgeInsets.all(4),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: SizedBox(
        width: double.infinity,
        child: Padding(padding: const EdgeInsets.all(5), child: content),
      ),
    ),
  );
}

ButtonStyle destructiveButton() {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(color: Colors.red))),
  );
}

ColorScheme customScheme() {
  return ColorScheme.fromSwatch(
      cardColor: Colors.green,
      accentColor: calqColor,
      backgroundColor: Colors.white);
}

class CalqTheme {
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: calqColor,
            background: Colors.white,
            error: Colors.red,
            onTertiary: Colors.teal),

        // cardTheme : ...,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                elevation: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return 5.0;
                  } else {
                    return 3.0;
                  }
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  } else {
                    return calqColor;
                  }
                }),
                shadowColor:
                    MaterialStateProperty.all<Color>(Colors.lightBlueAccent),
                foregroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return calqColor;
                  } else {
                    return Colors.white;
                  }
                }))),
        useMaterial3: true);
  }

  static ThemeData darkThemeData() {
    return ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: calqColor,
            background: Colors.black45,
            error: Colors.red,
            onTertiary: Colors.teal),

        //    cardTheme : ...,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                elevation: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return 5.0;
                  } else {
                    return 3.0;
                  }
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  } else {
                    return calqColor;
                  }
                }),
                shadowColor:
                    MaterialStateProperty.all<Color>(Colors.lightBlueAccent),
                foregroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return calqColor;
                  } else {
                    return Colors.white;
                  }
                }))),
        useMaterial3: true);
  }
}

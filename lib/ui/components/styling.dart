import 'package:flutter/material.dart';

const calqColor = Color(0xff428fe3);
const appbarColorLight = Color(0xffdde1f3);
const appbarColorDark = Color(0xff2D2D2D);

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

ButtonStyle calqSegmentedButtonStyle() {
  return ButtonStyle(
      side: MaterialStateBorderSide.resolveWith((states) {
        return BorderSide(color: Colors.grey.withOpacity(0.5));
      }),
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
}

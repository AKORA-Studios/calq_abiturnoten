import 'package:flutter/material.dart';

Widget card(Widget content) {
  return Container(
    decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(8))),
    child: SizedBox(
      width: double.infinity,
      child: Padding(padding: const EdgeInsets.all(5), child: content),
    ),
  );
}

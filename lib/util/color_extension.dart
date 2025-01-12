import 'package:flutter/material.dart';

Color fromHex(String str) {
  return Color(int.parse(str.replaceAll('#', '0xff'), radix: 16));
}

String toHex(Color col) {
  return '#${(col.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

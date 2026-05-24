import 'package:flutter/material.dart';

class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
}

class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphatic = Curves.easeOutBack;
  static const Curve smooth = Curves.easeInOut;
}

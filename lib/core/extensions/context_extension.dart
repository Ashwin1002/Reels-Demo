import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // media query size
  Size get sizeOf => MediaQuery.sizeOf(this);

  // device height
  double get height => MediaQuery.sizeOf(this).height;

  // device width
  double get width => MediaQuery.sizeOf(this).width;

  // pixel ratio
  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);

  //Theme
  ThemeData get theme => Theme.of(this);
}

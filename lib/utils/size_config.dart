import 'package:flutter/material.dart';

/// A utility class for handling responsive sizing throughout the app
class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    debugPrint('My Screen Width is : ${MediaQuery.of(context).size.width}');
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = (screenWidth! / 100);
    blockSizeVertical = (screenHeight! / 100);
  }

  static double getPercentSize(double percent) {
    return ((screenWidth ?? 0.0) * percent) / 100;
  }
}

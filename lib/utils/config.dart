//set constant config here
import 'package:flutter/material.dart';

class Config {
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  static String baseUrl = 'http://192.168.43.99/clinique/public/api';
  static String urlImage = 'http://192.168.43.99/clinique/public/assets';
  static String baseUrlImage = 'http://192.168.43.99/clinique/public/storage/images/';
  static String urlAsset = 'http://192.168.43.99/clinique/clinique/public/assets';

/*
   static String baseUrl = 'https://rimdevtols.com/api';
   static String urlImage = 'https://rimdevtols.com/assets';
   static String baseUrlImage = 'https://rimdevtols.com/storage/images/';
   static String urlAsset = 'https://rimdevtols.com/assets';
*/

  //width and height initialization
  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  static get widthSize {
    return screenWidth;
  }

  static get heightSize {
    return screenHeight;
  }

  //define spacing height
  static const spaceSmall = SizedBox(
    height: 25,
  );
  static final spaceMedium = SizedBox(
    height: screenHeight! * 0.05,
  );
  static final spaceBig = SizedBox(
    height: screenHeight! * 0.08,
  );

  //textform field border
  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.green,
      ));
  static const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.red,
      ));

  static const primaryColor = Colors.green;
}

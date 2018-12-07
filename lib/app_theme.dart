import 'package:flutter/material.dart';

const darkBlue = Color(0xFF292787);
const blue = Color(0xFF3E3C93);
const tealAccent = Color(0xFF10EDC5);
const darkGreen = Color(0xFF1B5E20);
const pinkAccent = Color(0xFFED1946);
const brightPink = Color(0xFFFF4081);
const blueGrey = Color(0xFF9A9AAC);
const brightGreen = Color(0xFF00FF00);

ThemeData appTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: MaterialColor(
        0xFF292787,
        <int, Color>{
          50: Color(0xff9493c3),
          100: Color(0xff7e7db7),
          200: Color(0xff6967ab),
          300: Color(0xff53529f),
          400: Color(0xff3e3c93),
          500: Color(0xff292787),
          600: Color(0xff242379),
          700: Color(0xff201f6c),
          800: Color(0xff1c1b5e),
          900: Color(0xff181751),
        }
    ),
    primaryColor: darkBlue,
//  primaryColorBrightness: Brightness.dark,
//    Color primaryColorLight,
    primaryColorDark: Color(0xFF181751),
    accentColor: tealAccent,
//    Brightness accentColorBrightness,
    canvasColor: Colors.white,
//    Color scaffoldBackgroundColor,
//    Color bottomAppBarColor,
//    Color cardColor,
//    Color dividerColor,
//    Color highlightColor,
//    Color splashColor,
//    InteractiveInkFeatureFactory splashFactory,
//    Color selectedRowColor,
//    Color unselectedWidgetColor,
//    Color disabledColor,
//    Color buttonColor,
//    ButtonThemeData buttonTheme,
//    Color secondaryHeaderColor,
//    Color textSelectionColor,
//    Color cursorColor,
//    Color textSelectionHandleColor,
//  backgroundColor: darkBlue,
//    Color dialogBackgroundColor,
//    Color indicatorColor,
//    Color hintColor,
//    Color errorColor,
//    Color toggleableActiveColor,
//    String fontFamily,
    textTheme : TextTheme(
        display1: TextStyle(color: Colors.white),
        display2: TextStyle(color: Colors.white),
        display3: TextStyle(color: Colors.white),
        display4: TextStyle(color: Colors.white),
        headline: TextStyle(color: Colors.white),
        button: TextStyle(color: Colors.white),
        body1: TextStyle(color: Colors.white),
        body2: TextStyle(color: Colors.white),
        title: TextStyle(color: Colors.white),
        caption: TextStyle(color: Colors.white),
        subtitle: TextStyle(color: Colors.white),
        subhead: TextStyle(color: Colors.white),
        overline: TextStyle(color: Colors.white)
    ),
    primaryTextTheme: TextTheme(
      display1: TextStyle(color: blueGrey),
      display2: TextStyle(color: blueGrey),
      display3: TextStyle(color: blueGrey),
      display4: TextStyle(color: blueGrey),
      headline: TextStyle(color: blueGrey),
      button: TextStyle(color: blueGrey),
      body1: TextStyle(color: blueGrey),
      body2: TextStyle(color: blueGrey),
      title: TextStyle(color: blueGrey),
      caption: TextStyle(color: blueGrey),
      subtitle: TextStyle(color: blueGrey),
      subhead: TextStyle(color: blueGrey),
      overline: TextStyle(color: blueGrey)
    )
//    TextTheme accentTextTheme,
//    InputDecorationTheme inputDecorationTheme,
//    IconThemeData iconTheme,
//    IconThemeData primaryIconTheme,
//    IconThemeData accentIconTheme,
//    SliderThemeData sliderTheme,
//    TabBarTheme tabBarTheme,
//    ChipThemeData chipTheme,
//    TargetPlatform platform,
//    MaterialTapTargetSize materialTapTargetSize,
//    PageTransitionsTheme pageTransitionsTheme,
//    ColorScheme colorScheme,
//    DialogTheme dialogTheme,
//    Typography typograph
);

int hexToInt(String hex)
{
  hex = hex.replaceFirst("#", "");
  if(hex.length < 8) hex = "FF$hex";

  int val = 0;
  int len = hex.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = hex.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      // 0..9
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw new FormatException("Invalid hexadecimal value");
    }
  }
  return val;
}
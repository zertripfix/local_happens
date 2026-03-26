import 'package:flutter/material.dart';

class AppButtonStyles {
  static final ButtonStyle elevated = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed))
        return const Color(0xFF222A25);
      return const Color(0xFF404F43);
    }),
    foregroundColor: WidgetStateProperty.all(const Color(0xFFFBFAF9)),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevation: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) return 4.0;
      return 0.0;
    }),
    shadowColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) return Color(0xFF79867D);
      return null;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.hovered))
        return const Color(0xFF79867D);
      if (states.contains(MaterialState.pressed))
        return const Color(0xFF79867D);
      return null;
    }),
  );

  static final ButtonStyle outlined = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.white),
    foregroundColor: WidgetStateProperty.all(const Color(0xFF222A25)),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    side: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed))
        return const BorderSide(color: Color(0xFF79867D));
      if (states.contains(MaterialState.hovered))
        return const BorderSide(color: Color(0xFF79867D));
      return const BorderSide(color: Color(0xFFE8E6E3));
    }),
    shadowColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) return Color(0xFF79867D);
      return null;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.hovered))
        return const Color(0xFF79867D);
      if (states.contains(MaterialState.pressed))
        return const Color(0xFFE8E6E3);
      return null;
    }),
  );
}

import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color pageBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF101918) : const Color(0xFFF4F8F7);
  }

  static Color surface(BuildContext context) {
    return isDark(context) ? const Color(0xFF1C2624) : Colors.white;
  }

  static Color primaryText(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF172B3A);
  }

  static Color secondaryText(BuildContext context) {
    return isDark(context) ? const Color(0xFFAAB5B3) : const Color(0xFF71807E);
  }

  static Color tertiaryText(BuildContext context) {
    return isDark(context) ? const Color(0xFF7C8886) : const Color(0xFF9AA5A3);
  }

  static Color iconChipBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF1F3B37) : const Color(0xFFE5F2EF);
  }
}
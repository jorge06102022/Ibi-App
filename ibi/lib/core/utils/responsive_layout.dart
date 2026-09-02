import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Utilidad para adaptar la vista a diferentes tamaños de pantalla
class ResponsiveLayout {
  ResponsiveLayout._();

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;
  }

  static double maxContainerWidth(BuildContext context) {
    return isTablet(context)
        ? AppConstants.maxContentWidthTablet
        : double.infinity;
  }
}

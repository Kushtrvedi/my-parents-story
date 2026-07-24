import 'package:flutter/material.dart';

class AdaptiveTypography {
  static MediaQueryData clampedMediaQuery(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.copyWith(
      textScaler:
          data.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 2.0),
    );
  }
}

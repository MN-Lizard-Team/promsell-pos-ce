import 'package:flutter/widgets.dart';

class AdaptiveBreakpoints {
  AdaptiveBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

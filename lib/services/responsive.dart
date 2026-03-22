import 'package:flutter/material.dart';

const double kMaxContentWidth = 600.0;
const double kBreakpointTablet = 600.0;

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= kBreakpointTablet;

Widget maxWidthBox({required Widget child}) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
      child: child,
    ),
  );
}

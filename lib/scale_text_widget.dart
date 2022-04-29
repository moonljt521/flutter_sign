import 'dart:math' as math;
import 'package:flutter/material.dart';

class MaxScaleTextWidget extends StatelessWidget {
  final double max;
  final Widget child;

  const MaxScaleTextWidget({
    this.max = 1.2,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);
    var scale = math.min(max, data.textScaleFactor);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}

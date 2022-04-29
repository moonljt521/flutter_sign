import 'package:flutter/material.dart';
import 'package:testsign/scale_text_widget.dart';

abstract class CommonBaseDialog extends StatelessWidget {
  Widget getWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return MaxScaleTextWidget(max: 1.0,
    child: getWidget(context));
  }
}

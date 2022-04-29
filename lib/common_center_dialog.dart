import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'common_base_dialog.dart';

class CommonCenterDialog extends CommonBaseDialog {
  // 标题
  String? _title;

  // 标题字体
  double _titleFontSize = 0;

  // 正文
  String? _message = "";

  // 正文字体
  double _messageFontSize = 0;

  // 确认按钮标题
  String? _confirmTitle;

  // 取消按钮标题
  String? _cancelTitle;

  Function? _confirmFunction;

  Function? _cancelFunction;

  CommonCenterDialog(
      {String? title,
      double titleFontSize = 18,
      String? message,
      double messageFontSize = 14,
      String? confirmTitle,
      String? cancelTitle,
      Function? confirmFunction,
      Function? cancelFunction}) {
    this._title = title;
    this._titleFontSize = titleFontSize;
    this._message = message;
    this._messageFontSize = messageFontSize;
    this._confirmFunction = confirmFunction;
    this._cancelFunction = cancelFunction;
    this._confirmTitle = confirmTitle;
    this._cancelTitle = cancelTitle;
  }

  List<Widget> itemsWidget(BuildContext context) {
    List<Widget> finalWidget = <Widget>[];
    double top = 24;
    if (_title != null) {
      Widget titleWidget = Padding(
        padding: EdgeInsets.fromLTRB(25, 24, 25, 12),
        child: Text(
          _title ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: _titleFontSize,
              color: const Color(0xFF171717),
              decoration: TextDecoration.none),
        ),
      );
      finalWidget.add(titleWidget);
      top = 0;
    }
    if (_message != null) {
      Widget messageWidget = Padding(
        padding: EdgeInsets.fromLTRB(25, top, 25, 12),
        child: Text(
          _message ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Color(0xFF444444),
              decoration: TextDecoration.none),
        ),
      );
      finalWidget.add(messageWidget);
    }

    ShapeBorder shape = RoundedRectangleBorder(
      side: BorderSide(
          color: Color(0xFF0599F6), width: 1.0, style: BorderStyle.solid),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );
    Widget actionWidget = Padding(
      padding: EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: Row(
        // mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: 24,
          ),
          Expanded(
            child: Container(
              height: 40,
              child: MaterialButton(
                shape: shape,
                onPressed: () {
                  if (_cancelFunction != null) {
                    _cancelFunction!();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  _cancelTitle ?? '取消',
                  style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0599F6),
                      decoration: TextDecoration.none),
                ),
              ),
            ),
          ),
          Container(
            width: 12,
          ),
          Expanded(
              child: Container(
            height: 40,
            child: MaterialButton(
              color: Color(0xFF0599F6),
              shape: shape,
              onPressed: () {
                Navigator.of(context).pop();
                if (_confirmFunction != null) {
                  _confirmFunction!(0);
                }
              },
              child: Text(
                _confirmTitle ?? '确认',
                style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFFFFFFF),
                    decoration: TextDecoration.none),
              ),
            ),
          )),
          Container(
            width: 24,
          ),
        ],
      ),
    );
    finalWidget.add(actionWidget);
    return finalWidget;
  }

  @override
  Widget getWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              decoration: ShapeDecoration(
                color: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
              ),
              margin: EdgeInsets.all(12.0),
              child: Column(
                children: itemsWidget(context),
              )),
        ],
      ),
    );
  }
}

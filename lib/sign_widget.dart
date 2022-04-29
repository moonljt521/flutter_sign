// import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show ImageByteFormat, Image;
// import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'common_center_dialog.dart';

/// 一张画布，可以跟随手指画线  例如用来做电子签名
final  double STROKEWIDTH = 8;
class Signature extends StatefulWidget {
  Function? noSign;
  double? strokeWith;

  Signature({this.noSign,this.strokeWith});

  @override
  State<StatefulWidget> createState() {
    return SignatureState(noSign! ,strokeWith ?? 1);
  }
}

class SignatureState extends State<Signature> {
  List<Offset?> _points = <Offset>[];
  GlobalKey _globalKey = GlobalKey();

  String _imageLocalPath = "";
  Function? noSign;
  double? mStrokeWidth;

  SignatureState(this.noSign,this.mStrokeWidth);

  @override
  void initState() {
    super.initState();
    //横屏
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _globalKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  _Image(),
                  _SignImage(),
                  signWidget(),
                ],
              ),
            ),
            Padding(
              child: bottom(noSign!),
              padding: EdgeInsets.only(right: 32),
            ),
          ],
        ),
      ));
  }

  Widget bottom(Function noSign) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            setState(() {
              _points.clear();
              _points = [];
              // _imageLocalPath = "";
            });
          },
          child: Text(
            '重写',
            style: TextStyle(color: Colors.white),
          ),
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            if(_points != null && _points.length > 0){
              File file = await _saveImageToFile();
              String toPath = await _capturePng(context ,file);
              print("path:${file.path}");
              setState(() {
                _imageLocalPath = toPath;
              });
            }else{
              noSign();
            }
          },
          child: Text(
            '保存',
            style: TextStyle(color: Colors.white),
          ),
        ),

        RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return CommonCenterDialog(
                  confirmTitle: "camera",
                  cancelTitle: "album",
                  message: "select a picture",
                  messageFontSize: 16,
                  confirmFunction: (int callback) {
                    _getCameraImage();
                  },
                  cancelFunction: (){
                    _getImage();
                  },
                );
              },
            );

          },
          child: Text(
            '选一张图',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget signWidget() {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                Offset? localPosition =
                renderBox?.globalToLocal(details.globalPosition);
                RenderBox? referenceBox =
                _globalKey.currentContext!.findRenderObject() as RenderBox?;

                //校验范围，防止超过外面
                if (((localPosition?.dx) ?? 0) <= 0 || ((localPosition?.dy) ?? 0) <= 0) return;
                if (((localPosition?.dx) ?? 0) > ((referenceBox?.size.width) ?? 0) ||
                    ((localPosition?.dy) ?? 0) > ((referenceBox?.size.height) ?? 0)) return;

                setState(() {
                  _points = List.from(_points)..add(localPosition!);
                });
              },
              onPanEnd: (DragEndDetails details) {
                _points.add(null);
              },
            ),
            Container(
              child:  CustomPaint(
                painter: SignatuePainter(_points, mStrokeWidth),
              ),
              color: Colors.red,
            )
            ,
            // Image.file(
            //   File(_imageLocalPath ?? ""),
            //   height: 100,
            //   width: 100,
            // )
          ],
        ),
      ),
    );
  }

  Future<File> _saveImageToFile() async {
    Directory tempDir = await getTemporaryDirectory();
    // Directory tempDir = await getExternalStorageDirectory();
    int curT = DateTime.now().millisecondsSinceEpoch;
    String toFilePath = "${tempDir.path}/$curT.png";
    File file = File(toFilePath);
    bool exists = await file.exists();
    if (!exists) {
      await file.create(recursive: true);
    }
    return file;
  }

  Future<String> _capturePng(BuildContext context , File file) async {
    //1.获取RenderRepaintBoundary
    RenderRepaintBoundary? boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    //2.生成Image  pixelRatio 不加上去，会很糊
    double pixratio = MediaQuery.of(context).devicePixelRatio;
    // ui.Image image = await boundary!.toImage(pixelRatio: (ui.window).devicePixelRatio);
    ui.Image image = await boundary!.toImage(pixelRatio: pixratio);
    //3.生成 Unit8List
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    //4.本地存储Image
    file.writeAsBytes(pngBytes);
    return file.path;
  }

  final ImagePicker picker = ImagePicker();

  //用户本地图片
  File? _userImage;

  Widget _Image() {
    if(_userImage != null){
      return  Container(
        padding: EdgeInsets.only(right: 10.0),
        alignment: Alignment.centerRight,
        // height: 300,
        // width: 700,
        child: Image.file(_userImage!),
      );
    }
    return Container(
      width: 10,
      height: 10,
    );
  }

  Widget _SignImage() {
    if(_imageLocalPath != null && _imageLocalPath != ""){
      return Row(
        children: [
          Expanded(flex: 1, child: Container(),),
          Column(
            children: [
              Expanded(flex: 1, child: Container(),),
              Container(
                padding: EdgeInsets.only(right: 10.0),
                // color: Colors.red,
                alignment: Alignment.bottomRight,
                height: 100,
                width: 200,
                child: Image.file(File(_imageLocalPath)),
              )
            ],
          )
        ],
      );
    }
    return Container(
      width: 10,
      height: 10,
    );
  }

  Future _getCameraImage() async {
    final cameraImages = await picker.getImage(source: ImageSource.camera);
    if (mounted) {
      setState(() {
        //拍摄照片不为空
        if (cameraImages != null) {
          _userImage = File(cameraImages.path);
          print('你选择的路径是：${_userImage.toString()}');
          //图片为空
        } else {
          print('没有照片可以选择');
        }
      });
    }
  }

  //选择相册
  Future _getImage() async {
    final pickerImages = await picker.getImage(source: ImageSource.gallery);
    if(mounted){
      setState(() {
        if(pickerImages != null){
          _userImage = File(pickerImages.path);
          print('你选择的本地路径是：${_userImage.toString()}');
        }else{
          print('没有照片可以选择');
        }
      });
    }
  }


}

class SignatuePainter extends CustomPainter {
  List<Offset?> points = <Offset?>[];
  double mStrokeWidth = 0 ;

  SignatuePainter(this.points,mStrokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    if(mStrokeWidth == null || mStrokeWidth == 0){
      mStrokeWidth = STROKEWIDTH;
    }
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.black
      ..isAntiAlias = true
      ..strokeWidth = mStrokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignatuePainter oldDelegate) {
    return points != oldDelegate.points;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

import 'common_center_dialog.dart';

// import 'dart:io'; // for File

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ImagePicker picker = ImagePicker();

  //用户本地图片
  File? _userImage;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20.0),
            ),
            FlatButton(
                color: const Color(0xFF0599F6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPressed: () {

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
                  "select a picture",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )),
            _Image(),
            FlatButton(
              color: const Color(0xFF0599F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(
                "SAVE",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onPressed: (){

              },
            )
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  final Key _repaintKey = GlobalKey();

  Widget _Image() {
    if(_userImage != null){
     return  Container(
       height: 300,
       width: 300,
       child: RepaintBoundary(
       key: _repaintKey,
       child: Stack(
         alignment: Alignment.bottomRight,
         children: <Widget>[
           Image.file(_userImage!),
           Icon(Icons.translate,),
         ],
       ),
     ),
     );
    }
    return Container(
      width: 10,
      height: 10,
    );
  }

  _clipSignImg(BuildContext context) {
    // RenderRepaintBoundary boundary =
    // // _repaintKey.currentContext.findRenderObject();
    // _repaintKey.currentContext.findRenderObject();
    // ui.Image image = await boundary.toImage();
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // Uint8List pngBytes = byteData.buffer.asUint8List();
    // File(tempPath).writeAsBytes(pngBytes);
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
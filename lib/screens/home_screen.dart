import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final picker = ImagePicker();
  File _image;
  bool _loading = false;
  List _output;
  bool _mask = true;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadModel().then((value) {});
  }

  @override
  void dispose() async {
    await Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF333333),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.06,
            ),
            Text(
              'Are you wearing a mask?',
              style: TextStyle(
                color: Color(0xFFE99600),
                fontWeight: FontWeight.w500,
                fontSize: size.height * 0.03,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Text(
              'Mask Detector',
              style: TextStyle(
                color: Color(0xFFEEDA28),
                fontSize: size.height * 0.06,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            _output == null
                ? Container(
                    height: 70,
                  )
                : _mask
                    ? Container(
                        child: Center(
                          child: Image.asset('assets/images/mask.png'),
                        ),
                      )
                    : Container(
                        child: Center(
                          child: Image.asset('assets/images/no-mask.png'),
                        ),
                      ),
            Center(
              child: Container(
                width: 550.0,
                child: Column(
                  children: [
                    _mask
                        ? Image.asset('assets/images/bear_mask.png')
                        : Image.asset('assets/images/bear_alone.png'),
                  ],
                ),
              ),
            ),
            Container(
              child: _output != null
                  ? Center(
                      child: Text(
                        _output[0]['label'] == '0 Mask'
                            ? 'Estás usando cubrebocas'
                            : (_output[0]['label'] == '1 No mask'
                                ? 'NO estás usando cubrebocas'
                                : ''),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    )
                  : Container(),
            ),
            Container(
              padding: EdgeInsets.only(top: 20.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Text(
                    'Take a photo',
                    style: TextStyle(
                      color: Color(0xFFE99600),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _openCamera();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        'From camera',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _pickGallery();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        'From gallery',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _pickGallery() async {
    PickedFile image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    _classifyImage(_image);
  }

  _openCamera() async {
    PickedFile image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    _classifyImage(_image);
  }

  _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  _classifyImage(File image) async {
    List output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _output = output;
      if (_output[0]['label'] == '0 Mask') {
        _mask = true;
      } else if (_output[0]['label'] == '1 No mask') {
        _mask = false;
      }
    });
  }
}

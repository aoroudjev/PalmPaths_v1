import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:static_image_test/services/object_detection.dart';

class DetectorWidget extends StatefulWidget {
  const DetectorWidget({super.key});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget> {
  final imagePicker = ImagePicker();
  ObjectDetection? objectDetection;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    objectDetection = ObjectDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDAD3C1),
      appBar: AppBar(
        title: Text('Detector'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      // Main result column
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFFDAD3C1),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF1D1B17), spreadRadius: 5)
                  ]),
              child: Text(
                "NOTE: If you are using your camera, TURN ON FLASH. Lighting is important for the model to work correctly.",
                style: TextStyle(fontSize: 25, color: Color(0xFF1D1B17)),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFDAD3C1),
                    boxShadow: [
                      BoxShadow(color: Color(0xFF1D1B17), spreadRadius: 5)
                    ]),
                child: Center(
                  child: (image != null)
                      ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.memory(image!),
                        const Icon(Icons.done,
                            size: 64, color: Color(0xFF525F61))
                      ])
                      : Container(
                    child: Text("Please select or take an image."),
                  ),
                ),
              ),

            ),
            // Image selection function buttons
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (Platform.isAndroid || Platform.isIOS)
                    IconButton(
                      onPressed: () async {
                        final result = await imagePicker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (result != null) {
                          image = objectDetection!
                              .analyseImage(result.path)
                              ?.imageDetected;
                          setState(() {});
                        }
                      },
                      icon: const Icon(
                        Icons.camera,
                        size: 64,
                        color: Color(0xFF1D1B17),
                      ),
                    ),
                  IconButton(
                    onPressed: () async {
                      final result = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (result != null) {
                        image = objectDetection!
                            .analyseImage(result.path)
                            ?.imageDetected;
                        setState(() {});
                      }
                    },
                    icon: const Icon(
                      Icons.photo,
                      size: 64,
                      color: Color(0xFF1D1B17),
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
}

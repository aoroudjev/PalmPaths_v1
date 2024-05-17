import 'dart:developer';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import '../services/object_detection.dart';

class ResultsWidget extends StatefulWidget {
  final Detection detectionResults;

  const ResultsWidget({Key? key, required this.detectionResults})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  bool _isLoading = true;
  late img.Image croppedImage;
  late Uint8List encodedImage;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    // Set state so widget loads
    setState(() {
      _isLoading = true;
    });

    img.Image originalImage = widget.detectionResults.image;
    img.Image? detectedImage = img.decodeImage(widget.detectionResults.imageDetected);
    List<int> boxCoords = widget.detectionResults.box;

    log("Original image dimensions: ${originalImage.width}x${originalImage.height}");
    log("Detected image dimensions: ${detectedImage!.width}x${detectedImage.height}");
    log("Box coordinates: $boxCoords");

    // Calculate the scaling factors
    double scaleX = originalImage.width / detectedImage.width;
    double scaleY = originalImage.height / detectedImage.height;

    // Scale the box coordinates
    int x1 = (boxCoords[0] * scaleX).round();
    int y1 = (boxCoords[1] * scaleY).round();
    int x2 = (boxCoords[2] * scaleX).round();
    int y2 = (boxCoords[3] * scaleY).round();

    int width = x2 - x1;
    int height = y2 - y1;


    log("Cropping image at: x=$x1, y=$y1, width=$width, height=$height");

    croppedImage = img.copyCrop(
        originalImage,
        x: x1,
        y: y1,
        width: width,
        height: height
    );

    encodedImage = Uint8List.fromList(img.encodeJpg(croppedImage));

    await Future.delayed(Duration(seconds: 1));

    // Update
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming Detection has fields like title, description, and maybe an image
    return Scaffold(
      appBar: AppBar(
        title: Text('Detection Results'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      backgroundColor: Color(0xFFDAD3C1),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1D1B17),
                    ),
                  )
                else
                  Image.memory(encodedImage)
              ],
            )),
      ),
    );
  }
}

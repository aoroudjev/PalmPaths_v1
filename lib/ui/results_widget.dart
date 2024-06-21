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
  late Uint8List encodedImage;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  img.Image toGrayscaleUsingBlueChannel(img.Image originalImage) {
    final grayImage =
        img.Image(width: originalImage.width, height: originalImage.height);
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        img.Pixel pixel = originalImage.getPixel(x, y);
        int blue = pixel.getChannel(img.Channel.blue).toInt();
        grayImage.setPixel(x, y, img.ColorRgb8(blue, blue, blue));
      }
    }
    return grayImage;
  }

  Future<void> _processImage() async {
    // Set state so widget loads
    setState(() {
      _isLoading = true;
    });

    img.Image originalImage = widget.detectionResults.image;
    img.Image? detectedImage =
        img.decodeImage(widget.detectionResults.imageDetected);
    List<int> boxCoords = widget.detectionResults.box;

    assert(detectedImage?.width == 320 && detectedImage?.height == 320,
        "Detected image dimensions are not 320x320");

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

    log("Scalars: x=$scaleX, y=$scaleY");
    log("Cropping image at: x=$x1, y=$y1, width=$width, height=$height");

    var croppedImage =
        img.copyCrop(originalImage, x: x1, y: y1, width: width, height: height);

    var resizedImage = img.copyResizeCropSquare(croppedImage, size: 300);
    var grayscaleImage = toGrayscaleUsingBlueChannel(resizedImage);
    var normalizedImage = img.normalize(grayscaleImage, min: 0, max: 300);

    img.Image img0 = normalizedImage;
    img.Image img45 = normalizedImage;
    img.Image img90 = normalizedImage;
    img.Image img135 = normalizedImage;
    img0 = img.gaussianBlur(img0, radius: 2);

    // croppedImage = img.grayscale(croppedImage);
    // croppedImage = img.contrast(croppedImage, contrast: 160);
    // croppedImage = img.gaussianBlur(croppedImage, radius: 1);

    // Other potential manipulations:

    // croppedImage = img.sobel(croppedImage, amount: 1);
    // croppedImage = img.luminanceThreshold(croppedImage, threshold: 0.76);

    encodedImage = Uint8List.fromList(img.encodeJpg(img0));

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

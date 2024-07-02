import 'dart:developer';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import '../services/detection_service.dart';
import '../services/inference_service.dart';

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
  ImageAlgorithms imgAlgorithms = ImageAlgorithms();

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
    img.Image? detectedImage =
        img.decodeImage(widget.detectionResults.imageDetected);
    List<int> boxCords = widget.detectionResults.box;

    assert(detectedImage?.width == 320 && detectedImage?.height == 320,
        "Detected image dimensions are not 320x320");

    log("Original image dimensions: ${originalImage.width}x${originalImage.height}");
    log("Detected image dimensions: ${detectedImage!.width}x${detectedImage.height}");
    log("Box coordinates: $boxCords");

    // Calculate the scaling factors
    double scaleX = originalImage.width / detectedImage.width;
    double scaleY = originalImage.height / detectedImage.height;

    // Scale the box coordinates
    int x1 = (boxCords[0] * scaleX).round();
    int y1 = (boxCords[1] * scaleY).round();
    int x2 = (boxCords[2] * scaleX).round();
    int y2 = (boxCords[3] * scaleY).round();

    int width = x2 - x1;
    int height = y2 - y1;

    log("Scalars: x=$scaleX, y=$scaleY");
    log("Cropping image at: x=$x1, y=$y1, width=$width, height=$height");

    var croppedImage =
        img.copyCrop(originalImage, x: x1, y: y1, width: width, height: height);

    // Begin palm line extraction
    var resizedImage = img.copyResizeCropSquare(croppedImage, size: 300);
    img.grayscale(resizedImage);
    // var grayscaleImage = imgAlgos.toGrayscaleUsingBlueChannel(resizedImage);
    img.normalize(resizedImage, min: 0, max: 255);
    img.contrast(resizedImage, contrast: 160);
    img.gaussianBlur(resizedImage, radius: 2);

    var f0FilterMatrix = [[0,0,0,0,0],
                          [0,0,0,0,0],
                          [1,1,1,1,1],
                          [0,0,0,0,0],
                          [0,0,0,0,0],];

    var f45FilterMatrix =  [[0,0,0,0,1],
                            [0,0,0,1,0],
                            [0,0,1,0,0],
                            [0,1,0,0,0],
                            [1,0,0,0,0],];

    var f90FilterMatrix =  [[0,0,1,0,0],
                            [0,0,1,0,0],
                            [0,0,1,0,0],
                            [0,0,1,0,0],
                            [0,0,1,0,0],];

    var f135FilterMatrix = [[1,0,0,0,0],
                            [0,1,0,0,0],
                            [0,0,1,0,0],
                            [0,0,0,1,0],
                            [0,0,0,0,1],];


    img.Image img0 = imgAlgorithms.fiFilter(resizedImage, f0FilterMatrix);
    img.Image img45 = imgAlgorithms.fiFilter(resizedImage, f45FilterMatrix);
    img.Image img90 = imgAlgorithms.fiFilter(resizedImage, f90FilterMatrix);
    img.Image img135 = imgAlgorithms.fiFilter(resizedImage, f135FilterMatrix);


    img0 = imgAlgorithms.bottomHatFilter(img0, f0FilterMatrix);
    img45 = imgAlgorithms.bottomHatFilter(img45, f45FilterMatrix);
    img90 = imgAlgorithms.bottomHatFilter(img90, f90FilterMatrix);
    img135 = imgAlgorithms.bottomHatFilter(img135, f135FilterMatrix);

    var combinedImage = imgAlgorithms.combineBottomHatResults([img0, img45, img90, img135]);
    var thresholdImage = img.luminanceThreshold(combinedImage, threshold: 0.1);


    // Other potential manipulations:
    img.sobel(resizedImage, amount: 1);

    encodedImage = Uint8List.fromList(img.encodeJpg(thresholdImage));



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

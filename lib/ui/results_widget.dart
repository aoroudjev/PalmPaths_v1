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
    setState(() {
      _isLoading = true;
    });

    //TODO: Image processing logic
    img.Image originalImage = widget.detectionResults.image;
    List<int> boxCoords = widget.detectionResults.box;

    log("Original image dimensions: ${originalImage.width}x${originalImage.height}");
    log("Box coordinates: $boxCoords");

    int x = boxCoords[0];
    int y = boxCoords[1];
    int width = boxCoords[2] - boxCoords[0];
    int height = boxCoords[3] - boxCoords[1];

    int xScalar = (originalImage.width/320) as int;
    int yScalar = (originalImage.height/320) as int;

    log("Cropping image at: x=$x, y=$y, width=$width, height=$height");

    croppedImage = img.copyCrop(
        originalImage,
        x: x * xScalar,
        y: y * yScalar,
        width: width * xScalar,
        height: height * yScalar
    );
    encodedImage = Uint8List.fromList(img.encodeJpg(croppedImage));

    await Future.delayed(Duration(seconds: 1));

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

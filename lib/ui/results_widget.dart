import 'package:flutter/material.dart';
import '../services/object_detection.dart';

class ResultsWidget extends StatefulWidget {
  final Detection detectionResults;
  const ResultsWidget({Key? key, required this.detectionResults}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // _processImage();
  }

  void _processImage() {


    setState(() {
      _isLoading =false;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(color: Color(0xFF1D1B17),),
              )
            else
              Image.memory(widget.detectionResults.image)
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/object_detection.dart';

class ResultsWidget extends StatefulWidget {
  final Detection detectionResults;
  const ResultsWidget({Key? key, required this.detectionResults}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
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
            Image.memory(widget.detectionResults.image),
          ],
        ),
      ),
    );
  }
}
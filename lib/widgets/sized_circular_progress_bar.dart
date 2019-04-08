import 'package:flutter/material.dart';

class SizedCircularProgressBar extends StatelessWidget {
  final double height;
  final double width;

  SizedCircularProgressBar({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: SizedBox(
        child: CircularProgressIndicator(),
        width: width,
        height: height,
      ),
    );
  }
}

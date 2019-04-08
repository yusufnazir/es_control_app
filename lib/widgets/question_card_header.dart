import 'package:flutter/material.dart';
import 'package:es_control_app/constants.dart';
class CardHeader extends StatelessWidget{

  final String name;

  CardHeader(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color:Constants.accentColorLight,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Constants.borderRadius),
              topRight: Radius.circular(Constants.borderRadius))),

      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            name,
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }


}
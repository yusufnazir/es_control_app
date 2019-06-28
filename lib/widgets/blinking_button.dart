import 'package:es_control_app/constants.dart';
import 'package:flutter/material.dart';

class BlinkingButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlinkingButtonState();
  }
}

class _BlinkingButtonState extends State<BlinkingButton>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Row(
        children: <Widget>[
          Text(
            "Scroll in table for more",
            style: TextStyle(color: Constants.primaryColor),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Constants.primaryColorLight,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

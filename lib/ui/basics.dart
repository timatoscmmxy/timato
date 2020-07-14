import 'package:flutter/material.dart';

//Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

class FloatingRaisedButton extends StatelessWidget{
  static final Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

  final void Function() _onPress;
  final String _text;

  FloatingRaisedButton(this._text, this._onPress);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Container(
        child: Text(
          _text,
          style: TextStyle(
            color: tomatoColor,
          ),
        ),
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 35, right: 35),
      ),
      onPressed: _onPress,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

}


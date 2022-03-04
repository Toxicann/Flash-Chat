import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final Color colors;
  final VoidCallback onpressed;
  final String buttonText;

  const Buttons(
      {Key? key,
      required this.colors,
      required this.onpressed,
      required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colors,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onpressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            buttonText,
          ),
          textColor: Colors.white,
        ),
      ),
    );
  }
}

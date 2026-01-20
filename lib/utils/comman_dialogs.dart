import 'package:flutter/material.dart';

class CustomAlertDialog {
  static Future<void> show(
    BuildContext context,
    String title,
    String content,
    String firstButtonText,
    VoidCallback onPressedFirstButton,
    String secondButtonText,
    VoidCallback onPressedSecondButton,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(content)]),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: onPressedFirstButton,
              child: Text(firstButtonText),
            ),
            TextButton(
              onPressed: onPressedSecondButton,
              child: Text(secondButtonText),
            ),
          ],
        );
      },
    );
  }
}

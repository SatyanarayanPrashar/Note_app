import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:todo/pages/Login_Page.dart';

class UIHelper {
  static void showLoadingAlertDialog(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 27),
              Text(title)
            ],
          )),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loadingDialog;
        });
  }

  static void showAlerDialog(BuildContext context, String title, String content,
      VoidCallback onPressed) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      content: Text(content, style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
            onPressed: onPressed,
            child: Text("Yes", style: TextStyle(color: Colors.white)))
      ],
    );

    showDialog(
      context: context,
      builder: (context) {
        return alertDialog;
      },
    );
  }
}

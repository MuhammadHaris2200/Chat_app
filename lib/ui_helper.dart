import 'dart:developer';

import 'package:chat_app/screen/login_class.dart';
import 'package:chat_app/screen/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Uihelper {
  // func for text field
  static customTextField(
    String text,
    String texts,
    TextEditingController controller,
    IconButton iconButton,
    bool toHide,
  ) {
    return TextField(
      controller: controller,
      obscureText: toHide,
      decoration: InputDecoration(
        suffixIcon: iconButton,
        labelText: text,
        hintText: texts,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  // func for btn
  static customBtn(VoidCallback voidCallBack, String text) {
    return SizedBox(
      width: 150,
      height: 40,
      child: ElevatedButton(
        onPressed: voidCallBack,
        child: Text(
          text,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  // func for alert box
  static customAlertBox(BuildContext context, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellowAccent,
          title: Center(child: Text(text, style: TextStyle(fontSize: 20))),
          //content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // func for snack bar
  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // func for circular indicator
  static void showCircularProgress(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            color: Colors.black,
          ),
        );
      },
    );
  }

  static Mq(BuildContext context){
    MediaQuery.of(context).size;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showProgressLoader(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ));
      });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class AuthService {
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

Widget buildLogoWidget(BuildContext context) {
  return RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 28),
      children: <TextSpan>[
        TextSpan(
          text: 'Create',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black54,
          ),
        ),
        TextSpan(
          text: 'Contacts',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.blue,
          ),
        ),
      ],
    ),
  );
}

Widget blueButton({BuildContext context, String label, buttonWidth}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(
      vertical: 18.0,
    ),
    width:
        buttonWidth != null ? buttonWidth : MediaQuery.of(context).size.width,
    alignment: Alignment.center,
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
        color: Colors.white,
      ),
    ),
  );
}

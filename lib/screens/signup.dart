import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:phonecontacts/others/email_validator.dart';
import 'package:phonecontacts/others/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:phonecontacts/screens/home.dart';
import 'package:phonecontacts/screens/signin.dart';
import 'package:phonecontacts/widgets/widgets.dart';
import 'package:random_string/random_string.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Build an alert to show some errors
  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Container(
            child: Text(error),
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close Dialog'),
            )
          ],
        );
      },
    );
  }

  Future<String> _createAccount() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password)
          .then(
            (currentUser) => FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.user.uid)
                .set(
              {
                "uid": currentUser.user.uid,
                "fname": _fname,
                "lname": _lname,
                "email": _email,
                "userImage":
                    "https://www.nicepng.com/png/detail/128-1280406_view-user-icon-png-user-circle-icon-png.png",
              },
            ).then(
              (value) => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(
                      uid: currentUser.user.uid,
                    ),
                  ),
                ),
              },
            ),
          );

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      }
      return e.message;
    } catch (e) {
      return (e.toString());
    }
  }

  void _submitForm() async {
    setState(() {
      _registerFormLoading = true;
    });
    showProgressLoader(context);
    String _createAccountFeedback = await _createAccount();
    if (_createAccountFeedback != null) {
      _alertDialogBuilder(_createAccountFeedback);
      setState(() {
        _registerFormLoading = false;
      });
    } else {
      // Navigator.pop(context);

    }
  }

  bool _registerFormLoading = false;

  // Register email & password
  String _email = "";
  String _password = "";
  String _fname = "";
  String _lname = "";

  // Focus Node for input fields
  FocusNode _passwordFocusNode;

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Center(child: buildLogoWidget(context)),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 34,
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "First Name",
                              ),
                              onChanged: (val) {
                                _fname = val;
                              },
                            ),
                          ),

                          SizedBox(width: 20),

                          // Last name field
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 34,
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "Last Name",
                              ),
                              onChanged: (val) {
                                _lname = val;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      // SizedBox(height: 6.0),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Email field can\'t be empty";
                          } else if (!val.isValidEmail()) {
                            return "Invalid Email";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                        ),
                        onChanged: (val) {
                          _email = val;
                        },
                      ),
                      SizedBox(height: 6.0),
                      TextFormField(
                        obscureText: true,
                        validator: (val) {
                          if (val.trim().isEmpty) {
                            return "Please enter password";
                          } else if (val.trim().length < 6) {
                            return "Password must be at least 6 characters long";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
                        ),
                        onChanged: (val) {
                          _password = val;
                        },
                      ),
                      SizedBox(height: 24.0),

                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            _submitForm();
                          }
                        },
                        child: blueButton(context: context, label: "Sign Up"),
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignIn(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonecontacts/others/utils.dart';
import 'package:phonecontacts/screens/home.dart';
import 'package:phonecontacts/screens/signup.dart';
import 'package:phonecontacts/widgets/widgets.dart';
import 'package:phonecontacts/others/email_validator.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Container(
            child: Text(error),
          ),
          actions: [
            FlatButton(
              child: Text("Close Dialog"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  // Create a new user account
  Future<String> _loginAccount() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _loginEmail, password: _loginPassword)
          .then(
            (currentUser) => FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.user.uid)
                .get()
                .then(
                  (value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(
                        uid: currentUser.user.uid,
                      ),
                    ),
                  ),
                ),
          );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  void _submitForm() async {
    // Set the form to loading state
    setState(() {
      _loginFormLoading = true;
    });
    showProgressLoader(context);

    String _loginFeedback = await _loginAccount();
    Navigator.pop(context);
    // If the string is not null, we got error while create account.
    if (_loginFeedback != null) {
      _alertDialogBuilder(_loginFeedback);

      // Set the form to regular state [not loading].
      setState(() {
        _loginFormLoading = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  // Default Form Loading State
  bool _loginFormLoading = false;

  // Form Input Field Values
  String _loginEmail = "";
  String _loginPassword = "";

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
//      appBar: AppBar(
//        title: Center(child: appBar(context)),
//        backgroundColor: Colors.transparent,
//        elevation: 0.0,
//      ),
      body: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildLogoWidget(context),
                          // Spacer(),
                          SizedBox(height: 30),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val.isEmpty) {
                                return "This field can\'t be empty";
                              }
                              if (!val.isValidEmail()) {
                                return "Invalid Email";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Email",
                            ),
                            onChanged: (val) {
                              _loginEmail = val;
                            },
                          ),
                          SizedBox(height: 6.0),
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              return val.isEmpty
                                  ? "Please enter password"
                                  : null;
                            },
                            decoration: InputDecoration(
                              labelText: "Password",
                            ),
                            onChanged: (val) {
                              _loginPassword = val;
                            },
                          ),
                          SizedBox(height: 24.0),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState.validate()) {
                                _submitForm();
                              }
                            },
                            child:
                                blueButton(context: context, label: "Sign In"),
                          ),
                          SizedBox(height: 18.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dont\'t have an account? ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUp(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 36.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

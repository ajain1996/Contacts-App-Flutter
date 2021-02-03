import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonecontacts/screens/create_contact.dart';
import 'package:phonecontacts/screens/edit_profile.dart';
import 'package:phonecontacts/screens/home.dart';
import 'package:phonecontacts/widgets/constants.dart';
import 'package:phonecontacts/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  bool _registerFormLoading = false;

  ProfilePage({this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('Users');

  final User _user = FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Center(
            child: Container(
          margin: EdgeInsets.only(right: 60),
          child: Text(
            'User Profile',
            style: TextStyle(color: Colors.black87),
          ),
        )),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _usersRef.doc(_user.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                // Firebase Document Data Map
                Map<String, dynamic> documentData = snapshot.data.data();

                return Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: ListView(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            // color: Color(0xffdcdcdc),
                            child: Center(
                              child: Image.network(
                                "${documentData['userImage']}",
                                height: 280,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 40),
                        child: Row(
                          children: [
                            Text(
                              "${documentData['fname']}" ?? 'First Name',
                              style: Constants.boldHeading,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "${documentData['lname']}" ?? 'Last Name',
                              style: Constants.boldHeading,
                            ),
                          ],
                        ),
                      ),

                      // Display Email
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Email:",
                          style: Constants.normal,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        child: Text(
                          "${documentData['email']}" ?? 'Email',
                          style: Constants.boldHeading,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 42),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                      userId: _user.uid,
                                      fname: documentData['fname'],
                                      lname: documentData['lname'],
                                      email: documentData['email'],
                                      userImage: documentData['userImage'],
                                    ),
                                  ),
                                );
                              },
                              child: blueButton(
                                label: 'Edit Contact',
                                context: context,
                                buttonWidth:
                                    MediaQuery.of(context).size.width / 2 - 28,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }

              // Loading state
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

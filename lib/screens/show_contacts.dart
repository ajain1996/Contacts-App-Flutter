import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonecontacts/screens/create_contact.dart';
import 'package:phonecontacts/screens/home.dart';
import 'package:phonecontacts/widgets/constants.dart';
import 'package:phonecontacts/widgets/widgets.dart';

class ShowContact extends StatefulWidget {
  final String contactId;
  bool _registerFormLoading = false;

  ShowContact({this.contactId});

  @override
  _ShowContactState createState() => _ShowContactState();
}

class _ShowContactState extends State<ShowContact> {
  bool _isLoading = false;

  final CollectionReference contactsRef =
      FirebaseFirestore.instance.collection('Contacts');

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('Users');

  final databaseReference = FirebaseFirestore.instance;

  deleteContact() async {
    await databaseReference
        .collection("Contacts")
        .doc(widget.contactId)
        .delete()
        .then((value) {
      setState(() {
        _isLoading = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Center(child: buildLogoWidget(context)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: contactsRef.doc(widget.contactId).get(),
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
                                "${documentData['contactImage']}",
                                height: 320,
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
                              "${documentData['firstName']}" ?? 'First Name',
                              style: Constants.boldHeading,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "${documentData['middleName']}" ?? 'Middle Name',
                              style: Constants.boldHeading,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "${documentData['lastName']}" ?? 'Last Name',
                              style: Constants.boldHeading,
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              margin: const EdgeInsets.only(left: 125),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Display Mobile Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Text(
                                  "${documentData['mobileNumber']}" ??
                                      'Mobile Number',
                                  style: Constants.boldHeading,
                                ),
                              ),
                              Text(
                                'Mobile | India',
                                style: Constants.text2,
                              )
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50)),
                            margin: const EdgeInsets.only(top: 30, left: 60),
                            child: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50)),
                            margin: const EdgeInsets.only(top: 30, right: 12),
                            child: Center(
                              child: Icon(
                                Icons.message_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Display Email
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Email: ${documentData['email']}" ?? 'Email',
                          style: Constants.boldHeading,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Landline number: ${documentData['landlineNumber']}" ??
                              'Landline Number',
                          style: Constants.boldHeading,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "${documentData['notes']}",
                          style: Constants.regularHeading,
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
                                    builder: (context) => CreateContact(
                                      contactId: widget.contactId,
                                      document: documentData,
                                      userId: documentData['userId'],
                                      contactImage:
                                          documentData['contactImage'],
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
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  deleteContact();
                                  // Scaffold.of(context)
                                  //     .showSnackBar(_snackBarAddToCard);
                                },
                                child: blueButton(
                                  label: 'Delete Contact',
                                  context: context,
                                  buttonWidth:
                                      MediaQuery.of(context).size.width / 2 - 4,
                                ),
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

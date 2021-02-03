import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phonecontacts/screens/home.dart';
import 'package:phonecontacts/widgets/widgets.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateContact extends StatefulWidget {
  final String contactId;
  final String userId;
  final String contactImage;

  final Map<String, dynamic> document;

  CreateContact(
      {this.contactId, this.document, this.userId, this.contactImage});

  @override
  _CreateContactState createState() => _CreateContactState();
}

class _CreateContactState extends State<CreateContact> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final User _user = FirebaseAuth.instance.currentUser;

  TextEditingController firstNameController;
  TextEditingController middleNameController;
  TextEditingController lastNameController;
  TextEditingController emailController;
  TextEditingController mobileNumberController;
  TextEditingController landLineNumberController;
  TextEditingController notesController;

  File _image;
  final selected = ImagePicker();

  final databaseReference = FirebaseFirestore.instance;

  Future getImage() async {
    final selectedImage = await selected.getImage(source: ImageSource.gallery);

    setState(() {
      if (selectedImage != null) {
        _image = File(selectedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Add contact data
  createContactOnline() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (_image != null) {
        // Uploading Images to Firestore
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('ContactImages')
            .child("${randomAlphaNumeric(9)}.jpg");

        final firebase_storage.UploadTask uploadTask = ref.putFile(_image);

        final link = await (await uploadTask).ref.getDownloadURL();
        print('This is url: ${link}');

        var contactId = randomAlphaNumeric(16);
        Map<String, String> contactMap = {
          "userId": _user.uid,
          "contactId": contactId,
          "contactImage": link != null ? link : "No Image",
          "firstName": firstNameController.value.text ?? "",
          "middleName": middleNameController.value.text ?? "",
          "lastName": lastNameController.value.text ?? "",
          "email": emailController.value.text ?? "",
          "mobileNumber": mobileNumberController.value.text ?? "",
          "landlineNumber": landLineNumberController.value.text ?? "",
          "notes": notesController.value.text ?? "",
        };
        databaseReference
            .collection("Contacts")
            .add(contactMap)
            .then((results) {
          if (mounted) {
            setState(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
              );
            });
          }
        });
      } else {
        // _alertDialogBuilder();
      }
    }
  }

  // Add contact data
  editContactOnline() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (_image != null) {
        // Uploading Images to Firestore
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('ContactImages')
            .child("${randomAlphaNumeric(9)}.jpg");

        final firebase_storage.UploadTask uploadTask = ref.putFile(_image);

        final link = await (await uploadTask).ref.getDownloadURL();
        // print('This is url: ${link}');

        var contactId = randomAlphaNumeric(16);
        Map<String, String> contactMap = {
          "userId": _user.uid,
          "contactId": contactId,
          "contactImage": link != null ? link : "No Image",
          "firstName": firstNameController.value.text ?? "",
          "middleName": middleNameController.value.text ?? "",
          "lastName": lastNameController.value.text ?? "",
          "email": emailController.value.text ?? "",
          "mobileNumber": mobileNumberController.value.text ?? "",
          "landlineNumber": landLineNumberController.value.text ?? "",
          "notes": notesController.value.text ?? "",
        };
        databaseReference
            .collection("Contacts")
            .doc(widget.contactId)
            .update(contactMap)
            .then((results) {
          setState(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          });
        });
      } else {
        // _alertDialogBuilder();
      }
    }
  }

  Future<void> _alertDialogBuilder() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Container(
            child: Text('Please select an Image'),
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

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(
        text: widget.document != null ? widget.document["firstName"] : "");
    middleNameController = TextEditingController(
        text: widget.document != null ? widget.document["middleName"] : "");
    lastNameController = TextEditingController(
        text: widget.document != null ? widget.document["lastName"] : "");
    emailController = TextEditingController(
        text: widget.document != null ? widget.document["email"] : "");
    mobileNumberController = TextEditingController(
        text: widget.document != null ? widget.document["mobileNumber"] : "");
    landLineNumberController = TextEditingController(
        text: widget.document != null ? widget.document["landlineNumber"] : "");
    notesController = TextEditingController(
        text: widget.document != null ? widget.document["notes"] : "");
  }

  @override
  Widget build(BuildContext context) {
    String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp mobileExp = new RegExp(mobilePattern);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Create New Contact",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              child: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  margin: EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ListView(
                      // shrinkWrap: true,
                      children: [
                        if (widget.contactImage == null)
                          // Actual Image not available
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: _image != null
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200.0,
                                    child: Image.file(_image),
                                  )
                                : Container(
                                    height: 120,
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 60.0,
                                    ),
                                  ),
                          ),

                        if (widget.contactImage != null)
                          Stack(
                            children: [
                              if (_image == null)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 240.0,
                                  child: Image.network(
                                    widget.contactImage,
                                    height: 140,
                                  ),
                                ),
                              GestureDetector(
                                onTap: () {
                                  if (_image != null)
                                    setState(() {
                                      _image == widget.contactImage;
                                    });
                                  getImage();
                                },
                                child: _image != null
                                    ? Stack(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 200.0,
                                            child: Image.file(_image),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 150, left: 220),
                                            child: GestureDetector(
                                              onTap: () {
                                                getImage();
                                              },
                                              child: Center(
                                                child: Icon(
                                                  Icons.add_a_photo,
                                                  size: 40.0,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(
                                            top: 150, left: 220),
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff2f2f2),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 34.0,
                                        ),
                                      ),
                              ),
                            ],
                          ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            validator: (val) {
                              if (val.isEmpty) {
                                return "Cannot be empty";
                              } else {
                                return null;
                              }
                            },
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: "First name",
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            controller: middleNameController,
                            decoration: InputDecoration(
                              labelText: "Middle name",
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            validator: (val) {
                              if (val.isEmpty) {
                                return "Cannot be empty";
                              } else {
                                return null;
                              }
                            },
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: "Last name",
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            validator: (value) => EmailValidator.validate(value)
                                ? null
                                : "Please enter a valid email",
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            validator: (val) {
                              if (!mobileExp.hasMatch(val)) {
                                return 'Please enter valid mobile number';
                              } else {
                                return null;
                              }
                            },
                            controller: mobileNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                              labelText: "Mobile Number",
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            validator: (val) {
                              if (val.length < 6) {
                                return 'Please enter valid mobile number';
                              } else {
                                return null;
                              }
                            },
                            controller: landLineNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: "LandLine Number",
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            controller: notesController,
                            decoration: InputDecoration(
                              labelText: "Notes (optional)",
                              isDense: true,
                            ),
                          ),
                        ),

                        // Create contact button
                        if (widget.userId != _user.uid)
                          GestureDetector(
                            onTap: () {
                              if (_image == null) {
                                _alertDialogBuilder();
                              } else {
                                createContactOnline();
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: blueButton(
                                context: context,
                                label: "Create Contact",
                              ),
                            ),
                          ),

                        // Edit Contact Button hqJV7uIlnPYXodM6PWZMCsGXXcT2
                        if (widget.userId == _user.uid)
                          GestureDetector(
                            onTap: () {
                              if (_image == null) {
                                _alertDialogBuilder();
                              } else {
                                editContactOnline();
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: blueButton(
                                context: context,
                                label: "Edit Contact",
                              ),
                            ),
                          ),
                        SizedBox(height: 36.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

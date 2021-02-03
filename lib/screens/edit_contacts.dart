//import 'dart:io';
//
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:contacts/screens/home.dart';
//import 'package:contacts/widgets/custom_input.dart';
//import 'package:contacts/widgets/validate_input.dart';
//import 'package:contacts/widgets/widgets.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:random_string/random_string.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//
//class EditContact extends StatefulWidget {
//  final String contactId;
//  final String firstName;
//  final String middleName;
//  final String lastName;
//  final String mobileNumber;
//  final String landlineNumber;
//  final String email;
//  final String contactImage;
//  final String notes;
//  EditContact({
//    this.contactId,
//    this.contactImage,
//    this.email,
//    this.firstName,
//    this.landlineNumber,
//    this.lastName,
//    this.middleName,
//    this.mobileNumber,
//    this.notes,
//  });
//  @override
//  _EditContactState createState() => _EditContactState();
//}
//
//class _EditContactState extends State<EditContact> {
//  final _formKey = GlobalKey<FormState>();
//  bool _isLoading = false;
//
//  File _image;
//  final selected = ImagePicker();
//
//  String firstName,
//      middleName,
//      lastName,
//      email,
//      mobileNumber,
//      landlineNumber,
//      notes;
//
//  Future<void> _alertDialogBuilder(String error) async {
//    return showDialog(
//      context: context,
//      barrierDismissible: false,
//      builder: (context) {
//        return AlertDialog(
//          title: Text('Error'),
//          content: Container(
//            child: Text(error),
//          ),
//          actions: [
//            FlatButton(
//              onPressed: () {
//                Navigator.pop(context);
//              },
//              child: Text('Close Dialog'),
//            )
//          ],
//        );
//      },
//    );
//  }
//
//  final databaseReference = FirebaseFirestore.instance;
//  final User _user = FirebaseAuth.instance.currentUser;
//
//  Future getImage() async {
//    final selectedImage = await selected.getImage(source: ImageSource.gallery);
//
//    setState(() {
//      if (selectedImage != null) {
//        _image = File(selectedImage.path);
//      } else {
//        print('No image selected.');
//      }
//    });
//  }
//
//  // Add contact data
//  editContact() async {
//    if (_formKey.currentState.validate()) {
//      setState(() {
//        _isLoading = true;
//      });
//      if (_image != null) {
//        // Uploading Images to Firestore
//        firebase_storage.Reference ref = firebase_storage
//            .FirebaseStorage.instance
//            .ref()
//            .child('ContactImages')
//            .child("${randomAlphaNumeric(9)}.jpg");
//
//        final firebase_storage.UploadTask uploadTask = ref.putFile(_image);
//
//        final link = await (await uploadTask).ref.getDownloadURL();
//        print('This is url: ${link}');
//
//        Map<String, String> contactMap = {
//          "userId": _user.uid,
//          "contactId": widget.contactId,
//          "contactImage": link != null ? link : "No Image",
//          "firstName": widget.firstName,
//          "middleName": widget.middleName != null ? widget.middleName : "",
//          "lastName": widget.lastName,
//          "email": widget.email != null ? widget.email : '',
//          "mobileNumber":
//              widget.mobileNumber != null ? widget.mobileNumber : "",
//          "landlineNumber":
//              widget.landlineNumber != null ? widget.landlineNumber : "",
//          "notes": widget.notes != null ? widget.notes : '',
//        };
//        databaseReference
//            .collection("Contacts")
//            .doc(widget.contactId)
//            .update(contactMap)
//            .then((value) {
//          setState(() {
//            // _isLoading = false;
//            Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) => Home(),
//              ),
//            );
//          });
//        });
//      } else {
//        return showDialog(
//          context: context,
//          builder: (ctx) => AlertDialog(
//            title: Text("Alert Dialog Box"),
//            content: Text("You have raised a Alert Dialog Box"),
//            actions: <Widget>[
//              FlatButton(
//                onPressed: () {
//                  Navigator.of(ctx).pop();
//                },
//                child: Text("okay"),
//              ),
//            ],
//          ),
//        );
//      }
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      resizeToAvoidBottomPadding: false,
//      appBar: AppBar(
//        title: Center(child: buildLogoWidget(context)),
//        backgroundColor: Colors.transparent,
//        elevation: 0.0,
//        brightness: Brightness.light,
//        iconTheme: IconThemeData(color: Colors.black87),
//      ),
//      body: _isLoading
//          ? Container(
//              child: Center(child: CircularProgressIndicator()),
//            )
//          : Form(
//              key: _formKey,
//              child: Container(
//                margin: EdgeInsets.only(top: 10),
//                child: ListView(
//                  children: [
//                    GestureDetector(
//                      onTap: () {
//                        getImage();
//                      },
//                      child: _image != null
//                          ? Container(
//                              width: MediaQuery.of(context).size.width,
//                              height: 200.0,
//                              child: Image.file(_image),
//                            )
//                          : Container(
//                              height: 120,
//                              margin: EdgeInsets.all(15),
//                              decoration: BoxDecoration(
//                                color: Color(0xfff2f2f2),
//                                borderRadius: BorderRadius.circular(10),
//                              ),
//                              child: Icon(
//                                Icons.add_a_photo,
//                                size: 60.0,
//                              ),
//                            ),
//                    ),
//
//                    // custom input
//                    ValidateInput(
//                      controlText: widget.firstName,
//                      hintText: "First name",
//                      onChanged: (val) {
//                        firstName = val;
//                      },
//                    ),
//
//                    CustomInput(
//                      controlText: widget.middleName,
//                      hintText: "Middle name",
//                      onChanged: (val) {
//                        middleName = val;
//                      },
//                    ),
//
//                    ValidateInput(
//                      controlText: widget.lastName,
//                      hintText: "Last name",
//                      onChanged: (val) {
//                        lastName = val;
//                      },
//                    ),
//
//                    CustomInput(
//                      controlText: widget.email,
//                      hintText: "email",
//                      onChanged: (val) {
//                        email = val;
//                      },
//                    ),
//
//                    CustomInput(
//                      controlText: widget.mobileNumber,
//                      hintText: "Mobile number",
//                      onChanged: (val) {
//                        mobileNumber = val;
//                      },
//                    ),
//
//                    CustomInput(
//                      controlText: widget.landlineNumber,
//                      hintText: "Landline number",
//                      onChanged: (val) {
//                        landlineNumber = val;
//                      },
//                    ),
//
//                    CustomInput(
//                      controlText: widget.notes,
//                      hintText: "Enter notes",
//                      onChanged: (val) {
//                        notes = val;
//                      },
//                    ),
//
//                    GestureDetector(
//                      onTap: () {
//                        editContact();
//                      },
//                      child: Container(
//                        margin: EdgeInsets.all(15),
//                        child: blueButton(
//                          context: context,
//                          label: "Edit Contact",
//                        ),
//                      ),
//                    ),
//                    SizedBox(height: 36.0),
//                  ],
//                ),
//              ),
//            ),
//    );
//  }
//}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phonecontacts/screens/profile_page.dart';
import 'package:phonecontacts/widgets/widgets.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditProfile extends StatefulWidget {
  final String userId;
  final String fname;
  final String lname;
  final String email;
  final String userImage;

  EditProfile({
    this.userId,
    this.email,
    this.fname,
    this.lname,
    this.userImage,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final User _user = FirebaseAuth.instance.currentUser;

  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController emailController;

  File _image;
  final selected = ImagePicker();
  String link;

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
  editProfileData() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (_image != null) {
        // Uploading Images to Firestore
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('UserImages')
            .child("${randomAlphaNumeric(9)}.jpg");

        final firebase_storage.UploadTask uploadTask = ref.putFile(_image);

        link = await (await uploadTask).ref.getDownloadURL();

        // print('This is url: ${link}');

        Map<String, String> userMap = {
          "userImage": link != null ? link : "No Image",
          "fname": firstNameController.value.text ?? "",
          "lname": lastNameController.value.text ?? "",
          "email": emailController.value.text ?? "",
        };
        databaseReference
            .collection("Users")
            .doc(widget.userId)
            .update(userMap)
            .then((results) {
          if (mounted) {
            setState(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            });
          }
        });
      }
    } else {}
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
    firstNameController =
        TextEditingController(text: widget.fname != null ? widget.fname : "");

    lastNameController =
        TextEditingController(text: widget.lname != null ? widget.lname : "");
    emailController =
        TextEditingController(text: widget.email != null ? widget.email : "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
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
                    child: Center(
                      child: ListView(
                        children: [
                          if (widget.userImage == null)
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
                          if (widget.userImage != null)
                            Stack(
                              children: [
                                if (_image == null)
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 240.0,
                                    child: Image.network(
                                      widget.userImage,
                                      height: 140,
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () {
                                    if (_image != null)
                                      setState(() {
                                        _image == widget.userImage;
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
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 40),
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
                              validator: (value) =>
                                  EmailValidator.validate(value)
                                      ? null
                                      : "Please enter a valid email",
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                isDense: true,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_image == null && widget.userImage == null) {
                                _alertDialogBuilder();
                              } else {
                                editProfileData();
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: blueButton(
                                context: context,
                                label: "Edit Profile",
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
            ),
    );
  }
}

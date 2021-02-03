import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonecontacts/screens/create_contact.dart';
import 'package:phonecontacts/screens/profile_page.dart';
import 'package:phonecontacts/screens/show_contacts.dart';
import 'package:phonecontacts/screens/signin.dart';
import 'package:phonecontacts/widgets/widgets.dart';

class Home extends StatefulWidget {
  final String uid;
  Home({this.uid});
  @override
  _HomeState createState() => _HomeState();
}

final User _user = FirebaseAuth.instance.currentUser;

class _HomeState extends State<Home> {
  final CollectionReference _contactsRef =
      FirebaseFirestore.instance.collection('Contacts');

  AuthService authService = new AuthService();

  logout() async {
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  Widget contactList() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: FutureBuilder<QuerySnapshot>(
        future: _contactsRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // display data in listview User
            return ListView(
              children: [
                // Display search User
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(12.0)),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Results',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                    ),
                  ),
                ),

                // Display all Contacts
                ListView(
                  shrinkWrap: true,
                  children: snapshot.data.docs.map((document) {
                    return ContactTile(
                      contactId: document.id,
                      userId: document.data()['userId'],
                      imgUrl: document.data()['contactImage'],
                      fname: document.data()['firstName'],
                      mname: document.data()['middleName'],
                      lname: document.data()['lastName'],
                      email: document.data()['email'],
                      mnumber: document.data()['mobileNumber'],
                      lnumber: document.data()['landlineNumber'],
                      notes: document.data()['notes'],
                    );
                  }).toList(),
                ),
              ],
            );
          }

          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: buildLogoWidget(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: widget.uid,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Image(
                image: AssetImage("assets/images/user.png"),
                width: 25,
                height: 25,
              ),
            ),
          ),
          SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              logout();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.logout,
                color: Colors.black45,
              ),
            ),
          ),
          SizedBox(width: 4),
        ],
      ),
      body: contactList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateContact()),
          );
        },
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String imgUrl,
      contactId,
      fname,
      lname,
      mname,
      mnumber,
      lnumber,
      email,
      notes,
      userId;
  ContactTile({
    @required this.fname,
    @required this.imgUrl,
    @required this.lname,
    @required this.mname,
    @required this.mnumber,
    @required this.lnumber,
    @required this.email,
    @required this.notes,
    @required this.userId,
    @required this.contactId,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == _user.uid) {
      return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(top: 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowContact(
                  contactId: contactId,
                ),
              ),
            );
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  imgUrl,
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              // Text('${userId}'),
              Container(
                margin: EdgeInsets.only(left: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          fname,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          mname,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          lname,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        mnumber,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

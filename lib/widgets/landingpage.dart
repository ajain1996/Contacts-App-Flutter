import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:phonecontacts/screens/home.dart';
import 'package:phonecontacts/screens/signin.dart';

class LandingPage extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Connection made to firebase Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, streamSnapshot) {
              // If Stream snapshot has error
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${streamSnapshot.error}"),
                  ),
                );
              }

              // Connection state active
              if (streamSnapshot.connectionState == ConnectionState.active) {
                // Get the user
                User _user = streamSnapshot.data;
                // If user not logged in, head to login
                if (_user == null) {
                  return SignIn();
                } else {
                  return Home();
                }
              }

              // Checking the auth state - loading page
              return Scaffold(
                body: Center(
                  child: Text(
                    'Checking Authentication...',
                    // style: Constants.regularHeading,
                  ),
                ),
              );
            },
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(
          body: Container(
            child: Center(
              child: Text(
                'FirebaseApp Initializing',
                // style: Constants.regularHeading,
              ),
            ),
          ),
        );
      },
    );
  }
}

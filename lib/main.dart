import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'screens/auth/register.dart';

void main() async {
//  var credential = Credential.applicationDefault();
//
//  // when no credentials found, login using openid
//  // the credentials are stored on disk for later use
//  credential ??= await Credentials.login();
//
//  // create an app
//  var app = FirebaseAdmin.instance.initializeApp(AppOptions(
//      credential: credential ?? Credentials.applicationDefault(),
//      projectId: 'some-project'));

  runApp(Phoenix(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return new Scaffold(
            body: new Center(
              child: new Text("Error"),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Protacall',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: Colors.white,
                brightness: Brightness.light,
                accentColor: Colors.blueAccent,
//          fontFamily: GoogleFonts.c,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                canvasColor: Colors.white,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: AppBarTheme(color: Colors.white, elevation: 0)),
            home: new RegisterPage(),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container(
          color: Colors.white,
          child: new Center(
            child: new CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

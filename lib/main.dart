import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vcr/home.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beautiful Images',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        // Initialize FlutterFire
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(
            child: SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}


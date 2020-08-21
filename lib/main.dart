// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('SomethingWentWrong');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: AppBar(
                  title: Text("Toets Bravo Een"),
                  backgroundColor: Colors.lightGreen[500],
                  centerTitle: true),
              body: Center(
                child: Location(),
              ),
              backgroundColor: Colors.lightGreen[300],
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: Text("Add"),
                backgroundColor: Colors.lightGreen[800],
              ));
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Text('Loading');
      },
    );
  }
}

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  bool _locationRetrieved = false;
  double _rating = 0.0;

  CollectionReference sessions =
      FirebaseFirestore.instance.collection('sessions');

  void fetchWeather() async {
    GeolocationStatus locationsPermissions =
        await Geolocator().checkGeolocationPermissionStatus();
    if (locationsPermissions == GeolocationStatus.denied) {
      await LocationPermissions().requestPermissions();
      PermissionStatus permission =
          await LocationPermissions().checkPermissionStatus();
      ServiceStatus serviceStatus =
          await LocationPermissions().checkServiceStatus();

      print("PERMISSION IS:");
      print(permission);
      print("SERVICE STATUS IS:");
      print(serviceStatus);
    } else {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      var weatherData = await http.get(
          'http://api.openweathermap.org/data/2.5/weather?q=johannesburg&appid=3532bb18cbc62c9b858fe06cec8b2d4e');
      this.addSession(position, weatherData.body);
    }
  }

  void addSession(Position pos, weatherData) {
    // Call the user's CollectionReference to add a new user
    sessions
        .add({
          'latitude:': pos.latitude,
          'longitude:': pos.longitude,
          'weatherData': weatherData,
          'rating': _rating
        })
        .then((value) => print("Session data Added"))
        .catchError((error) => print("Failed to add session data: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
          Expanded(
            child: Container(
              width: 200,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.fromLTRB(0, 100, 0, 10),
              color: Colors.brown[500],
              alignment: Alignment.center,
              child: Text("Hiking", style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 100),
              width: 200,
              padding: EdgeInsets.all(20),
              color: Colors.blue[400],
              alignment: Alignment.center,
              child: RaisedButton(
                  child: Text("Surfing"),
                  onPressed: () {
                    fetchWeather();
                  }),
            ),
          ),
          Expanded(
              child: RatingBar(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ))
        ]));
  }
}

class TextContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Toets Bravo Een"),
            backgroundColor: Colors.lime[900],
            centerTitle: true),
        body: Center(
            child: Text("Body text",
                style: TextStyle(
                    color: Colors.teal[300],
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontFamily: 'FOne'))),
        backgroundColor: Colors.lightGreen[200],
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Text("Add"),
          backgroundColor: Colors.lightGreen[800],
        ));
  }
}

class ImageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Toets Bravo Een"),
            backgroundColor: Colors.lime[900],
            centerTitle: true),
        body: Center(
            child: Image.network(
                "https://images.unsplash.com/photo-1508811555397-58b4347a7cf4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80")),
        backgroundColor: Colors.lightGreen[200],
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Text("Add"),
          backgroundColor: Colors.lightGreen[800],
        ));
  }
}

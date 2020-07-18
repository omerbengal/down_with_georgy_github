import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/services.dart';
import 'georgyAwakeIcon.dart';
import 'georgyAsleepIcon.dart';
import 'package:share/share.dart';
import 'package:photo_view/photo_view.dart';

class ParkPage extends StatefulWidget {
  @override
  _ParkPageState createState() => _ParkPageState();
}

class _ParkPageState extends State<ParkPage> {

  double xPoint = -20.0;
  double yPoint = -20.0;
  Timer timer;

  @override
  initState() {
    getXAndYCoordinates(context);
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      getXAndYCoordinates(context);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery
        .of(context)
        .size
        .height);
    double screenwidth = (MediaQuery
        .of(context)
        .size
        .width);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Stack(
      children: <Widget>[
        Container(
          color: Colors.blue[100],
          child: Center(
              child: Image.asset(
                'images/BorochovAirMap.png',
                width: screenwidth,
                height: screenHeight,
                fit: BoxFit.fill,
              )
          ),
        ),
        Positioned(
            top: yPoint - (screenHeight / 17)/2,
            left: xPoint - (screenHeight / 17)/2,
            child: Icon(Icons.directions_car, color: Colors.blue,
              size: screenHeight / 17,)
        ),
        Container(
          width: screenwidth,
          height: screenHeight,
          child: GestureDetector(
            onTapUp: (TapUpDetails details) => _onTap(details, context),
          ),
        ),
      ],
    );
  }

  Future<void> getXAndYCoordinates(BuildContext context) async {
    await Firestore.instance
        .collection('booleans')
        .document('Parking')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values
          .toList()
          .length; i++) {
        if (value.data.keys.toList()[i] == "xCoordinates") {
          setState(() {
            xPoint = (value.data.values.toList()[i].toDouble() * (MediaQuery
                .of(context)
                .size
                .width)) / 100;
          });
        }

        if (value.data.keys.toList()[i] == "yCoordinates") {
          setState(() {
            yPoint = (value.data.values.toList()[i].toDouble() * (MediaQuery
                .of(context)
                .size
                .height)) / 100;
          });
        }
      }
    });
  }

  _onTap(TapUpDetails details, BuildContext context) {
    Firestore.instance
        .collection('booleans')
        .document('Parking')
        .updateData({
      "xCoordinates": (details.localPosition.dx * 100) / (MediaQuery
          .of(context)
          .size
          .width)
    });

    Firestore.instance
        .collection('booleans')
        .document('Parking')
        .updateData({
      "yCoordinates": (details.localPosition.dy * 100) / (MediaQuery
          .of(context)
          .size
          .height)
    });

  }
}

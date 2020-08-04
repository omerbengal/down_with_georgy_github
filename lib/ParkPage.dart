import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';


class ParkPage extends StatefulWidget {
  @override
  _ParkPageState createState() => _ParkPageState();
}

class _ParkPageState extends State<ParkPage> {

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

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('booleans').snapshots(),
      builder: (context, snapshot) {

        if(!snapshot.hasData) {
          return Text('Loading...');
        }

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
                top: snapshot.data.documents[3]['yCoordinates'].toDouble() * (MediaQuery.of(context).size.height) / 100 - (screenHeight / 17)/2,
                left: snapshot.data.documents[3]['xCoordinates'].toDouble() * (MediaQuery.of(context).size.width) / 100 - (screenHeight / 17)/2,
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
    );
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


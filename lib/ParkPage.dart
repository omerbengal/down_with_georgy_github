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

  double xPoint;
  double yPoint;
  Timer timer;

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
        getXAndYCoordinates();
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
            child: PhotoView(
              imageProvider: AssetImage('images/BorochovAirMap.png'),
              backgroundDecoration: BoxDecoration(color: Colors.blue[100]),
            ),
          ),
        ),
        Positioned(
          top: yPoint,
          left: xPoint,
          child: Container(
            color: Colors.green,
            width: 20.0,
            height: 20.0,
          ),
        ),
        Container(
          width: screenwidth,
          height: screenHeight,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) => _onTap(details),
          ),
        ),
      ],
    );

  }

  Future<void> getXAndYCoordinates() async {
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
            xPoint = value.data.values.toList()[i].toDouble();
          });
        }

        if (value.data.keys.toList()[i] == "yCoordinates") {
          setState(() {
            yPoint = value.data.values.toList()[i].toDouble();
          });
        }
      }
    });
  }

  _onTap(TapDownDetails details) {
    Firestore.instance
        .collection('booleans')
        .document('Parking')
        .updateData({
      "xCoordinates": details.localPosition.dx
    });

    Firestore.instance
        .collection('booleans')
        .document('Parking')
        .updateData({
      "yCoordinates": details.localPosition.dy
    });
  }
}


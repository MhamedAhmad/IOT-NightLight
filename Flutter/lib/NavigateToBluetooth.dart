import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'BTConnect.dart';

class BluetoothButtonPage extends StatefulWidget {
  const BluetoothButtonPage({super.key});

  @override
  State<BluetoothButtonPage> createState() => _BluetoothButtonPageState();
}

class _BluetoothButtonPageState extends State<BluetoothButtonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        title: Text(
          'Night Light',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child:
            Container(
              height: 100,
              width: 350,
              color: Colors.amber[600],
              child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  //leading: Icon(icons[index], color: Colors.teal,size: 40,)
                  title:Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth, color: Colors.teal,size: 35,),
                        SizedBox(width: 8),
                        Text(
                          'Connect',
                          style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ) ),
            ),
          ),
          onTap: ()  {
          FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => FindDevicesScreen()),
          );
          }
          ,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}



import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:synchronized/extension.dart';
import 'HomePage.dart';
import 'package:synchronized/synchronized.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';



class SeekWifiMessage extends StatefulWidget {


  @override
  _SeekWifiMessageState createState() => _SeekWifiMessageState();
}

class _SeekWifiMessageState extends State<SeekWifiMessage> {
  static const String WIFI_SIGNAL_UUID = "be31c4e4-c3f7-4b6f-83b3-d9421988d355";


  Future<int> receiveDataFromESP() async {
      BluetoothCharacteristic? ch=characteristicDictionary[WIFI_SIGNAL_UUID];
      if (ch == null) {
        return -1;
      }

      int x=-1;
      try{
        await ch.setNotifyValue(true);
      }
      catch(err){
        x=-1;
      }
      ch.value.listen((value) {
        if(value.isNotEmpty) {
          x=value[0];
        }
      });
      await Future.delayed(const Duration(milliseconds:500));
      if(x==-1){
        return await receiveDataFromESP();
      }
      return x;

    /*
      await Future.delayed(const Duration(seconds:8));
      List<int>? value = await ch.read();
      List<int>? value = await ch.read();
      return value[0];
      */



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        centerTitle: true,
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Colors.teal,
        title: Text('Night Light',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Center(
        child: FutureBuilder(
          future: receiveDataFromESP(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              int receivedData = snapshot.data as int;
              if (receivedData == 0) {
                return Text('Faild To Connect \nPlease Try Again');
              } else if (receivedData == 1) {
                return Text('Connected Successfully');
              }
              return Container();


            }
          },
        ),
      ),
    );
  }
}

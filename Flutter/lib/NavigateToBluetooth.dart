import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'BTConnect.dart';
import 'HomePage.dart';
late BluetoothDevice targetDevice;
late BluetoothCharacteristic targetCharacteristic;
bool connected = false;
bool inside = true;

class BluetoothButtonPage extends StatefulWidget {
  const BluetoothButtonPage({super.key});
  @override
  State<BluetoothButtonPage> createState() => _BluetoothButtonPageState();
}
connectToDevice() async {
  if (targetDevice == null) {
    return;
  }
  await targetDevice.connect(autoConnect: false);
  discoverServices();
}
discoverServices() async {
  if (targetDevice == null) {
    return;
  }

  List<BluetoothService> services = await targetDevice.discoverServices();
  for (var service in services) {
    if (service.uuid.toString() == "cfdfdee4-a53c-47f4-a4f1-9854017f3817") {
      for (var characteristics in service.characteristics) {
        characteristicDictionary[characteristics.uuid.toString()]=characteristics;
      }
    }
  }
  connected = true;
}

class _BluetoothButtonPageState extends State<BluetoothButtonPage> {
  @override
  Widget build(BuildContext context) {
    inside = true;
    connected = false;
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
          onTap: () async {
            connected = false;
            showDialog(context: context, builder: (context) {
              return Center(child: CircularProgressIndicator());
            },);
            FlutterBlue BT = FlutterBlue.instance;
            BT.scan(timeout: Duration(seconds: 5)).listen((scanResult) async {
              if (scanResult.device.name.contains("ESP32")) {
                targetDevice = scanResult.device;
                await connectToDevice();
              }
            });
            for(int i=0; i <10; i++)
            {
              await Future.delayed(const Duration(milliseconds:500));
              if(connected)
                {
                  inside = false;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),)
                  );
                  return;
                }
            }
            if (!connected) {
              Navigator.of(context).pop();
              targetDevice.disconnect();
            }
            else {
              inside = false;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),)
              );
            }
          }
          ,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}



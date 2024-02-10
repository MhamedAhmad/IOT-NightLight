import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'LightColorPage.dart';
import 'LightIntensityPage.dart';
import 'TimeSettingsPage.dart';
import 'WIFISettingsPage.dart';
import 'BTConnect.dart';


Map<String, BluetoothCharacteristic?> characteristicDictionary = {};

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  String title;



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
writeDataWithCharacteristic(String c, String data) async {
  BluetoothCharacteristic? bc=characteristicDictionary[c];
  if (bc == null)
    return;

  List<int> bytes = utf8.encode(data);
  await bc.write(bytes);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  static const String SERVICE_UUID = "cfdfdee4-a53c-47f4-a4f1-9854017f3817";
  static const String TIME_UUID = "125f4480-415c-46e0-ab49-218377ab846a";
  static const String COLOR_UUID = "81b703d5-518a-4789-8133-04cb281361c3";
  static const String INTENSITY_UUID = "3ca69c2c-0868-4579-8fa8-91a203a5b931";
  static const String WIFI_UUID = "006e3a0b-1a72-427b-8a00-9d03f029b9a9";
  static const String TARGET_DEVICE_NAME = "ESP32";


  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult>? scanSubscription;
  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;
  String connectionText = "";

  void initState() {
    super.initState();
    //startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubscription = flutterBlue.scan().listen((scanResult) {
      print(scanResult.device.name);
      if (scanResult.device.name.contains(TARGET_DEVICE_NAME)) {
        stopScan();

        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }
  stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
  }
  connectToDevice() async {
    if (targetDevice == null) {
      return;
    }

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice.connect();

    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }
  discoverServices() async {
    if (targetDevice == null) {
      return;
    }

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristics) {
          characteristicDictionary[service.uuid.toString()]=characteristics;
            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopScan();
  }

  final List<String> entries = ['Time Settings', 'Light Color','Light Intensity', 'WiFi Settings'/*,'Connect'*/];
  final List<IconData> icons = [Icons.access_time, Icons.lightbulb,Icons.brightness_6, Icons.wifi/*, Icons.bluetooth*/];
  final List<int> colorCodes = [600, 600,600, 600,600];


  void _onColorChanged(Color color) {
    setState(() => widget._currentColor = color);
  }

  void _showTimePicker(bool setStart) {
    showTimePicker(
      context: context,
      initialTime: setStart? (widget._startTime ?? TimeOfDay.now()) : (widget._endTime ?? TimeOfDay.now()),
    ).then((value) {
      setState(() {
        if(value != null)
          {
            if(setStart)
              widget._startTime = value!;
            else
              widget._endTime = value!;
          }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Colors.teal,
        title: Text(widget.title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              // Handle the action for each menu item
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeSettingsPage(TIME_UUID)),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LightColorPage(COLOR_UUID)),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LightIntensityPage(INTENSITY_UUID)),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WIFISettingsPage(WIFI_UUID)),
                  );
                  break;
                  /*
                case 4:

                  await FlutterBluePlus.startScan(
                      timeout: Duration(seconds:4));

                  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindDevicesScreen()),
                  );

                  break;
                  */

              }
            },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child:
            Container(
              height: 130,
              color: Colors.amber[colorCodes[index]],
              child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  //leading: Icon(icons[index], color: Colors.teal,size: 40,)
                  title:Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[index], color: Colors.teal,size: 35,),
                    SizedBox(width: 8),
                    Text(
                      entries[index],
                      style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ) ),
            ),
           )
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),    );
  }
}

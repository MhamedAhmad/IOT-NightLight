import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ColorsPages/StartColorPage.dart';
import 'ColorsPages/EndColorPage.dart';
import 'NavigateToBluetooth.dart';
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
writeDataWithCharacteristic(String c, String data, BuildContext context) async {
  BluetoothCharacteristic? bc=characteristicDictionary[c];
  if (bc == null)
    return;

  List<int> bytes = utf8.encode(data);
  try{
    await bc.write(bytes);
  }
  catch(error)
  {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () { Navigator.of(context).pop();
      targetDevice.disconnect();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>BluetoothButtonPage())
      );},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Bluetooth Disconnected"),
      content: Text("Connect to Bluetooth again"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {

  static const String SERVICE_UUID = "cfdfdee4-a53c-47f4-a4f1-9854017f3817";
  static const String TIME_UUID = "125f4480-415c-46e0-ab49-218377ab846a";
  static const String START_COLOR_UUID = "81b703d5-518a-4789-8133-04cb281361c3";
  static const String END_COLOR_UUID = "3ca69c2c-0868-4579-8fa8-91a203a5b931";
  static const String WIFI_UUID = "006e3a0b-1a72-427b-8a00-9d03f029b9a9";
  static const String WIFI_SIGNAL_UUID = "be31c4e4-c3f7-4b6f-83b3-d9421988d355";
  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2"; //todo: CHANGE THIS
  static const String TARGET_DEVICE_NAME = "ESP32";


  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult>? scanSubscription;
  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;
  String connectionText = "";

  void initState() {
   // super.initState();
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
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristics in service.characteristics) {
          characteristicDictionary[characteristics.uuid.toString()]=characteristics;
            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    //stopScan();
  }

  final List<String> entries = ['Time Settings', 'Start Color','End Color', 'WiFi Settings'/*,'Connect'*/];
  final List<IconData> icons = [Icons.access_time, Icons.color_lens_outlined,Icons.color_lens_rounded, Icons.wifi/*, Icons.bluetooth*/];
  final List<int> colorCodes = [600, 600,600, 600,600];

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
                    //print('hello');
                    var data = '${1}';
                    writeDataWithCharacteristic(COLOR_MODE_UUID,data,context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StartColorPage(START_COLOR_UUID)),
                    );
                    break;
                  case 2:
                    var data = '${1}';
                    writeDataWithCharacteristic(COLOR_MODE_UUID,data,context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EndColorPage(END_COLOR_UUID)),
                    );
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WIFISettingsPage(WIFI_UUID)),
                    );
                    break;
                /*case 4:
                  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindDevicesScreen()),
                  );*/

                  break;


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

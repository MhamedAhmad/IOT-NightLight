import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'BTConnect.dart';
import 'HomePage.dart';

late BluetoothDevice targetDevice;
late BluetoothCharacteristic targetCharacteristic;
bool connected = false;
bool inside = true;
bool initialized = false;

class BluetoothButtonPage extends StatefulWidget {
  const BluetoothButtonPage({super.key});
  @override
  State<BluetoothButtonPage> createState() => _BluetoothButtonPageState();
}

connectToDevice() async {
  if (targetDevice == null) {
    return;
  }
  await targetDevice.connect(autoConnect: true);
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
        characteristicDictionary[characteristics.uuid.toString()] = characteristics;
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
    return PopScope(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgroundpic.jpg'), // Replace with your image asset path
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' Welcome To \n Night Light',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    // Add any additional text styling as needed
                  ),textAlign: TextAlign.center,
                ),
                SizedBox(height: 70),

              Container(
              width: 300,
                height: 100,// Set your custom width
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white), // White background
                  foregroundColor: MaterialStateProperty.all(Colors.teal.shade800), // Text color
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.greenAccent), // Neon border color
                    ),
                  ),
                ),
                onPressed: () async {
                  connected = false;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );
                  FlutterBlue BT = FlutterBlue.instance;
                  BT.scan(timeout: Duration(seconds: 5)).listen((scanResult) async {
                    if (scanResult.device.name.contains("ESP32")) {
                      targetDevice = scanResult.device;
                      initialized = true;
                      await connectToDevice();
                    }
                  });
                  for (int i = 0; i < 10; i++) {
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (connected) {
                      inside = false;
                      BT.stopScan();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),),
                      );
                      return;
                    }
                  }
                  if (!connected) {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    if (initialized) targetDevice.disconnect();
                  } else {
                    inside = false;
                    BT.stopScan();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),),
                    );
                  }
                },
                  child: Container(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth, color: Colors.teal.shade800, size: 35,),
                          SizedBox(width: 8),
                          Text(
                            'CONNECT',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onBackButtonPressed(context);
      },
    );
  }

  Future<void> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Closing App"),
          content: const Text("Do you Want to close the app?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                if (initialized) targetDevice.disconnect();
                SystemNavigator.pop();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
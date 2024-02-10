import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';



class WifiSetter extends StatefulWidget {
  @override
  _WifiSetterState createState() => _WifiSetterState();
}

class _WifiSetterState extends State<WifiSetter> {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32 THAT PROJECT";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult?>? scanSubscription;
  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;
  String connectionText = "";

  @override
  void initState() {
    super.initState();
    startScan();
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
          if (characteristics.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristics;
            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
          }
        });
      }
    });
  }
  writeDataWithCharacteristic(BluetoothCharacteristic bc, String data) async {
    if (bc == null)
      return;

    List<int> bytes = utf8.encode(data);
    await bc.write(bytes);
  }

  @override
  void dispose() {
    super.dispose();
    stopScan();
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nightlight/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ColorsPages/StartColorPage.dart';
import 'ColorsPages/EndColorPage.dart';
import 'NavigateToBluetooth.dart';
import 'TimeSettingsPage.dart';
import 'WIFISettingsPage.dart';
import 'BTConnect.dart';
import 'InstructionsPage.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';


Map<String, BluetoothCharacteristic?> characteristicDictionary = {};
bool exiting = false;

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
      onPressed: () { Navigator.of(context).pop();popup=false;
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
    popup = true;
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
  //late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;
  String connectionText = "";

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TimeSettingsPage(TIME_UUID),
    StartColorPage(START_COLOR_UUID),
    EndColorPage(END_COLOR_UUID),
    WIFISettingsPage(WIFI_UUID),
  ];

  void _onItemTapped(int index) {
    print('here');
    if ((_selectedIndex == 1 && index != 1)) {
      if(startSaved==false && startApplied==true) {
        showWarningDialog('StartColorPage', index);
      }
      var data = '${0}';
      writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
    }else if((_selectedIndex == 2 && index != 2)){
      if(endSaved==false && endApplied==true) {
        showWarningDialog('EndColorPage', index);
      }
      print('here11');
      print('here11');

      var data = '${0}';
      writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
    }
    if(index==1 || index==2){
      var data = '${1}';
      writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
    }
      setState(() {
        _selectedIndex = index;
      });

  }

  void showWarningDialog(String pageName,int index) {
    Widget saveButton = TextButton(
      child: Text("Save and Continue",),
      onPressed: () {
        if(pageName=='StartColorPage') {
          startApplied=false;
          startSaved=true;
          saveStartChanges(true,context,START_COLOR_UUID,currentStartColor);
        }
        else{
          endApplied=false;
          startApplied=true;
          saveEndChanges(true,context,END_COLOR_UUID,motionDetectionValue,currentEndColor);
        }
        Navigator.of(context).pop();

      },
    );

    Widget discardButton = TextButton(
      child: Text("Discard Changes and Continue"),
      onPressed: () {
        if(pageName=='StartColorPage') {
          startApplied=false;
          startSaved=true;
        }
        else{
          endApplied=false;
          startApplied=true;
        }

        Navigator.of(context).pop();

      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Do you want to save your changes before leaving?"),
      actions: [
        saveButton,
        discardButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> saveStartChanges(bool save,BuildContext context, String c_uid,Color color) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('startColor', color.value);

      print('djs');
      print(color);

      HSVColor hsvDecode = HSVColor.fromColor(currentStartColor);
      var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}';
      writeDataWithCharacteristic(c_uid, data, context);

  }

  Future<void> saveEndChanges(bool save,BuildContext context, String c_uid,double motionDetectionValue ,Color color) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('endColor', color.value);
    prefs.setDouble('motionDetectionValue', motionDetectionValue);
    print('ahc');
    print(motionDetectionValue);

    HSVColor hsvDecode = HSVColor.fromColor(currentEndColor);
    var data =
        '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}+${motionDetectionValue}';
    writeDataWithCharacteristic(c_uid, data, context);

  }







  @override
  Widget build(BuildContext context) {
    return PopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _pages[_selectedIndex],
          bottomNavigationBar: ConvexAppBar(
            style: TabStyle.reactCircle,
            color: Colors.white,
            backgroundColor: Colors.teal.shade800,
            items: [
              TabItem(icon: Icons.access_time, title: 'Time'),
              TabItem(icon: Icons.color_lens_outlined, title: 'StandBy'),
              TabItem(icon: Icons.color_lens_rounded, title: 'End Color'),
              TabItem(icon: wifi_connected ? Icons.wifi : Icons.wifi_off,
                  title: 'WiFi'),
            ],
            onTap: _onItemTapped,
          ),
        )
        , canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop)
            return;
          _onBackButtonPressed(context);
        });
  }

    Future<void> _onBackButtonPressed(BuildContext context) async{
      await showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text("Closing App"),
              content: const Text("Do you Want to close the app?"),
              actions: <Widget> [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text("No")),
                TextButton(onPressed: (){
                  exiting = true;
                  SystemNavigator.pop();
                }, child: const Text("Yes")),
              ],);
          });
    }

}

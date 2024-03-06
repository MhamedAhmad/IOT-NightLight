import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nightlight/ColorPicker.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:nightlight/ColorsPages/StartColorPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage.dart';

Color currentEndColor = Colors.blue;
double motionDetectionValue = 0;
bool endSaved=false;
bool endApplied=false;

void _saveColorAndMotionDetection(Color color, double motionDetectionValue) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('endColor', color.value);
  prefs.setDouble('motionDetectionValue', motionDetectionValue);
}

void ApplyColor(bool save, BuildContext context,String c_uid) {
  HSVColor hsvDecode = HSVColor.fromColor(currentEndColor);
  var data =
      '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}+${motionDetectionValue}';
  writeDataWithCharacteristic(c_uid, data, context);
}

class EndColorPage extends StatefulWidget {
  EndColorPage(this.c_uid, {super.key});

  late String c_uid;
  bool isLoading = true; // Add a loading indicator
  String loadingMessage = 'Loading Data...'; // Add a loading message

  @override
  State<EndColorPage> createState() => EndColorPageState();
}

class EndColorPageState extends State<EndColorPage> {
  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2";

  @override
  void initState() {
    super.initState();
    _loadColorAndMotionDetection(); // Load the saved color and motion detection value when the page is initialized.
  }

  void _onColorChanged(Color color) {
    setState(() => currentEndColor = color);
  }

  void _loadColorAndMotionDetection() async {
    widget.isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('endColor') ?? Colors.blue.value;
    double motionDetectionValue = prefs.getDouble('motionDetectionValue') ?? 0;

    setState(() {
      currentEndColor = Color(colorValue);
      motionDetectionValue = motionDetectionValue;
      widget.isLoading = false; // Set loading to false after data is loaded
    });
  }
/*
  void _saveColorAndMotionDetection(Color color, double motionDetectionValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('endColor', color.value);
    prefs.setDouble('motionDetectionValue', motionDetectionValue);
  }

  void ApplyColor(bool save, BuildContext context) {
    HSVColor hsvDecode = HSVColor.fromColor(currentEndColor);
    var data =
        '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}+${widget.motionDetectionValue}';
    writeDataWithCharacteristic(widget.c_uid, data, context);
  }

 */

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Text(
            "1. Set the start and end times for the night light.\n"
                "2. Adjust delay, rise time, and fade time as desired.\n"
                "3. Click 'Apply Changes' to save the settings.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white70,
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.teal.shade800,
      title: Text(
        'Night Light',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    body:PopScope(
    canPop: true,
    onPopInvoked: (didPop) {
      print('object');
      var data = '${0}';
      writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
    },
    child: Center(
      child: widget.isLoading
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            widget.loadingMessage,
            style: TextStyle(fontSize: 16),
          ),
        ],
      )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Please Choose the End Color',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20,),
                    IconButton(
                      icon: Icon(Icons.help),
                      onPressed: () {
                        _showInstructions();
                      },
                    ),
                  ],
                ),
                ColorPicker(
                  color: currentEndColor,
                  onChanged: (value) => _onColorChanged(value),
                  initialPicker: Picker.paletteValue,
                ),
                Divider(
                  height: 15,
                  color: Colors.teal.shade800,
                  thickness: 2,
                ),
                Text(
                  'Motion Detection Intensity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: motionDetectionValue,
                  onChanged: (value) {
                    setState(() {
                      motionDetectionValue = value;
                    });
                  },
                  min: 0,
                  max: 200,
                  divisions: 20,
                  label: motionDetectionValue.round().toString(),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                ElevatedButton(
                  onPressed: () {
                    endApplied = true;
                    endSaved = false;
                    ApplyColor(false, context, widget.c_uid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                  ),
                  child: Text('Apply Changes', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 8,),
                ElevatedButton(
                  onPressed: () {
                    endApplied = false;
                    endSaved = true;
                    _saveColorAndMotionDetection(currentEndColor, motionDetectionValue);
                    ApplyColor(true, context, widget.c_uid);
                    Widget okButton = TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                       /* Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light')),
                        );*/
                      },
                    );

                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: Text("Night Color Settings Changed"),
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                  ),
                  child: Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 30),
    ]
                )
              ],
            ),
      ),
    ),
  );

  }

}
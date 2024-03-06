import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nightlight/ColorPicker.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage.dart';


class StartColorPage extends StatefulWidget {
  StartColorPage(this.c_uid, {super.key});

  late String c_uid;
  bool isLoading = true; // Add a loading indicator
  String loadingMessage = 'Loading Data...'; // Add a loading message

  @override
  State<StartColorPage> createState() => StartColorPageState();
}

Color currentStartColor=Colors.blue;
bool startSaved=false;
bool startApplied=false;

void _saveStartColor(Color color) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('startColor', color.value);
}

void ApplyStartColor(bool save,BuildContext context, String c_uid) {

  HSVColor hsvDecode = HSVColor.fromColor(currentStartColor);
  var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}';
  writeDataWithCharacteristic(c_uid, data, context);

}

class StartColorPageState extends State<StartColorPage> {
  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2";

  @override
  void initState() {
    super.initState();
    _loadColor(); // Load the saved color when the page is initialized.
  }

  void _onColorChanged(Color color) {
    setState(() => currentStartColor = color);
  }

  void _loadColor() async {
    widget.isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('startColor') ?? Colors.blue.value;

    setState(() {
      currentStartColor = Color(colorValue);
      widget.isLoading = false; // Set loading to false after data is loaded
    });
  }
/*
  void _saveStartColor(Color color) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('startColor', color.value);


  }

  void ApplyStartColor(bool save,BuildContext context) {

    HSVColor hsvDecode = HSVColor.fromColor(widget._currentStartColor);
    var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}';
    writeDataWithCharacteristic(widget.c_uid, data, context);

  }
  */

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        title: Text(
          'Night Light',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: PopScope(
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
              SizedBox(height: 15),
              Text(
                'Please Choose the Start Color',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              ),
              ColorPicker(
                color: currentStartColor,
                onChanged: (value) => _onColorChanged(value),
                initialPicker: Picker.paletteValue,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  startApplied=true;
                  startSaved=false;
                  ApplyStartColor(false,context,widget.c_uid);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                ),
                child: Text('Apply Changes',style: TextStyle(color:Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  startApplied=false;
                  startSaved=true;
                  _saveStartColor(currentStartColor); // Save the current color
                  ApplyStartColor(true,context,widget.c_uid);
                  Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                   /* Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),)
                    );*/
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text("Day Color Settings Changed"),
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
                child: Text('Save Changes',style: TextStyle(color:Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

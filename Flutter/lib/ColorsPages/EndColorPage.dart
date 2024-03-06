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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        centerTitle: true,
<<<<<<< HEAD
        backgroundColor: Colors.teal.shade800,
        title: Text(
          'Night Light',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
              color: Colors.white

=======
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Colors.teal,
        title: Text('Night Light',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          var data = '${0}';
          await writeDataWithCharacteristic(COLOR_MODE_UUID,data,context);
          await showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
            title: const Text("Exiting Page"),
            content: const Text("Do you Want to Save changes?"),
            actions: <Widget> [
            TextButton(onPressed: (){
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),)
            );
            }, child: const Text("No")),
            TextButton(onPressed: (){
              ApplyColor(true, context);
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),)
              );
            }, child: const Text("Yes")),
            ],);
            });
          //print('hi');
        },
        child: Center(
          child:
          Column(
            children:[
              Text(
                'Please Choose the End Color',
                style: TextStyle(fontSize: 20),
              ),
              ColorPicker(
                color: Colors.blue,
                onChanged: (value) => _onColorChanged(value),
                initialPicker: Picker.paletteValue,
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 30,
                color: Colors.orange,
                thickness: 2,
              ),
              Text(
                'Motion Detection Intensity',
                style: TextStyle(fontSize: 20),
              ),
              Slider(
                value: widget.motionDetectionValue,
                onChanged: (value) {
                  setState(() {
                    widget.motionDetectionValue = value;
                  });
                },
                min: 0,
                max: 200,
                divisions: 20,
                label: widget.motionDetectionValue.round().toString(),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(onPressed: () {
                ApplyColor(false, context);
              }, style: ElevatedButton.styleFrom(
                primary: Colors.orange,),
                  child: Text('Apply Changes')),
              ElevatedButton(onPressed: () {
                ApplyColor(true, context);
                // set up the button
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light'),)
                    );
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
              }, style: ElevatedButton.styleFrom(
                primary: Colors.orange,),
                  child: Text('Save Changes'))
            ],
>>>>>>> 1823f09ade0edb9ea77b761241947c8f0846a18e
          ),
        ),
      ),
      body: SingleChildScrollView(
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
            :Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Text(
              'Please Choose the End Color',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
             ColorPicker(
                color: currentEndColor,
                onChanged: (value) => _onColorChanged(value),
                initialPicker: Picker.paletteValue
            ),
            Divider(
              height: 30,
              color: Colors.teal.shade800,
              thickness: 2,
            ),
            Text(
              'Motion Detection Intensity',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
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
            ElevatedButton(
              onPressed: () {
                endApplied=true;
                endSaved=false;
                ApplyColor(false, context,widget.c_uid);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
              ),
              child: Text('Apply Changes',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                endApplied=false;
                endSaved=true;
                _saveColorAndMotionDetection(currentEndColor, motionDetectionValue);
                ApplyColor(true, context,widget.c_uid);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
              ),
              child: Text('Save Changes',style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 30,)
          ],
      ),
      ),

    );
  }
}
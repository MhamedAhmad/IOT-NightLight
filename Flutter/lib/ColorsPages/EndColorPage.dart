import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nightlight/ColorPicker.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

import '../HomePage.dart';

class EndColorPage extends StatefulWidget {
  EndColorPage(this.c_uid, {super.key});
  late String c_uid;
  Color _currentColor = Colors.blue;
  double motionDetectionValue = 0;


  @override
  State<EndColorPage> createState() => EndColorPageState();
}



class EndColorPageState extends State<EndColorPage> {

  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2";

  void _onColorChanged(Color color) {
    setState(() => widget._currentColor = color);
  }

  void ApplyColor(bool save) {
    HSVColor hsvDecode = HSVColor.fromColor(widget._currentColor);
    var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save?'0':'1'}';
    writeDataWithCharacteristic(widget.c_uid,data);
  }



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
      body: SingleChildScrollView(
        child: PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            var data = '${0}';
            writeDataWithCharacteristic(COLOR_MODE_UUID,data);
            //print('hi');
          },
          child: Center(
            child:
            Column(
              children:[
                SizedBox(height: 15,),
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
                  height: 30,
                ),
                ElevatedButton(onPressed: () {
                  ApplyColor(false);
                }, style: ElevatedButton.styleFrom(
                  primary: Colors.orange,),
                    child: Text('Apply Changes')),
                ElevatedButton(onPressed: () {
                  ApplyColor(true);
                }, style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,),
                    child: Text('Save Changes')),
                Divider(
                  height: 100,
                  color: Colors.orange,
                  thickness: 2,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                  ],
                ),
                SizedBox(height: 20,),
                ElevatedButton(onPressed: () {
                  var data = '${widget.motionDetectionValue}';
                  writeDataWithCharacteristic(widget.c_uid,data);
                }, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange
                ), child: Text('Apply Changes')),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/*
        CircleColorPicker(
          strokeWidth: 16,
          initialColor: widget._currentColor,
          onChanged: _onColorChanged,
          colorCodeBuilder: (context, color) {
            return Text(
              'rgb(${color.red}, ${color.green}, ${color.blue})',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          },
        ),
        */

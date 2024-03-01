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
  State<EndColorPage> createState() => StartColorPageState();
}




class StartColorPageState extends State<EndColorPage> {

  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2";


  void _onColorChanged(Color color) {
    setState(() => widget._currentColor = color);
  }

  void ApplyColor(bool save) {
    print('hi');
    HSVColor hsvDecode = HSVColor.fromColor(widget._currentColor);
    var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${widget.motionDetectionValue}+${save? '1' : '0'}';
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
      body: PopScope(
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
                ApplyColor(false);
              }, style: ElevatedButton.styleFrom(
                primary: Colors.orange,),
                  child: Text('Apply Changes')),
              ElevatedButton(onPressed: () {
                ApplyColor(true);
              }, style: ElevatedButton.styleFrom(
                primary: Colors.orange,),
                  child: Text('Save Changes'))
            ],
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

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

  void ApplyColor(bool save, BuildContext context) {
    print('hi');
    HSVColor hsvDecode = HSVColor.fromColor(widget._currentColor);
    var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save? '1' : '0'}+${widget.motionDetectionValue}';
    writeDataWithCharacteristic(widget.c_uid,data,context);
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

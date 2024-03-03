import 'package:flutter/material.dart';
import 'package:nightlight/ColorPicker.dart';
import 'HomePage.dart';

class LightIntensityPage extends StatefulWidget {
  LightIntensityPage(this.c_uid, {super.key});
  late String c_uid;
  double motionDetectionValue = 0;


  @override
  State<LightIntensityPage> createState() => _LightIntensityPageState();
}

class _LightIntensityPageState extends State<LightIntensityPage> {


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
      body: Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(
              height: 100,
              color: Colors.orange,
              thickness: 2,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Motion Detection',
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
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
            SizedBox(height: 50,),
            ElevatedButton(onPressed: () {
              var data = '${widget.motionDetectionValue}';
              writeDataWithCharacteristic(widget.c_uid,data,context);
            }, style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange
            ), child: Text('Save Changes'))
          ],
        ),

      ),
    );
  }





}

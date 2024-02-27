import 'package:flutter/material.dart';
import 'package:nightlight/ColorPicker.dart';
import 'package:nightlight/SeekWifiMessage.dart';
import 'HomePage.dart';

class WIFISettingsPage extends StatefulWidget {
  WIFISettingsPage(this.c_uid, {super.key});
  late String c_uid;
  String password='';
  String ssid = '';

  @override
  State<WIFISettingsPage> createState() => _WIFISettingsPageState();
}

class _WIFISettingsPageState extends State<WIFISettingsPage> {


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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SSID',
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 250.0, // Set the desired width
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.ssid = value;
                      });

                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),

                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Password',
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 250.0, // Set the desired width
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.password = value;
                      });
                      // Update the userSSID variable when the text changes
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust internal padding
                    ),
                    obscureText: true, // Hide entered characters

                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: () {
              var data = '${widget.ssid}+${widget.password}';
              writeDataWithCharacteristic(widget.c_uid,data);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SeekWifiMessage()));
            }, style: ElevatedButton.styleFrom(
              primary: Colors.orange,),
                child: Text('Save Changes'))
          ],
        ),
      ),
    );
  }





}

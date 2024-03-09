import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nightlight/ColorPicker.dart';
import 'package:nightlight/SeekWifiMessage.dart';
import 'package:nightlight/main.dart';
import 'HomePage.dart';
import 'NavigateToBluetooth.dart';



class WIFISettingsPage extends StatefulWidget {
  WIFISettingsPage(this.c_uid, {super.key});
  late String c_uid;
  String password='';
  String ssid = '';
  @override
  State<WIFISettingsPage> createState() => _WIFISettingsPageState();
}

Future<int> receiveDataFromESP(String UUID) async {
  BluetoothCharacteristic? ch = characteristicDictionary[UUID];
  if (ch == null) {
    return -1;
  }

  int x = -1;
  try {
    await ch.setNotifyValue(true);
  }
  catch (err) {
    if (err.toString().contains("no instance of BluetoothGatt")) {
      return -100;
    }
    x = -1;
  }
  ch.value.listen((value) {
    if (value.isNotEmpty) {
      x = value[0];
    }
  });
  //print(x);
  await Future.delayed(const Duration(milliseconds: 500));
  if (x == -1) {
    return await receiveDataFromESP(UUID);
  }
  return x;
}

class _WIFISettingsPageState extends State<WIFISettingsPage> {

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Text(
            "1. Enter WiFi Network Name and Password\n"
                "2. Press on \"Connect to Wifi\" to connect\n"
                "3. *If configuring Time fails a message will pop up that asks you if you want to configure it with the phone's time",
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
        automaticallyImplyLeading: false,
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Colors.teal.shade800,
        title: Text('Night Light',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold, color: Colors.white

            )),
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
        child:
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.help),
                  onPressed: () {
                    _showInstructions();
                  },
                ),
              ],
            ),
            SizedBox(height: 200,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SSID',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
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
            ElevatedButton(onPressed: () async {
              var data = '${widget.ssid}+${widget.password}';
              writeDataWithCharacteristic(widget.c_uid,data,context);
              showDialog(context: context, builder: (context) {
                return Center(child: CircularProgressIndicator());
              },);
              int x = await receiveDataFromESP("be31c4e4-c3f7-4b6f-83b3-d9421988d355");
              if(x == 0)
              {
                Navigator.of(context).pop();
                  // set up the button
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: const Text("Connection Failed"),
                        content: const Text("Do you Want to configure time with phone clock instead?"),
                        actions: <Widget> [
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("No")),
                          TextButton(onPressed: (){
                            var data = '${TimeOfDay.now().hour}+${TimeOfDay.now().minute}+${0},${DateTime.now().day}+${DateTime.now().month}+${DateTime.now().year}';
                            writeDataWithCharacteristic("6d6fb840-ed2b-438f-8375-9220a5164be8", data, context);
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Time Configured"),
                                  content: Text(
                                    "",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        manually_configured = true;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }, child: const Text("Yes")),
                        ],);
                    });
              }
              else if (x == 1)
              {
                Navigator.of(context).pop();
                  // set up the button
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  );

                  // set up the AlertDialog
                  AlertDialog alert = AlertDialog(
                    title: Text("Connection Failed"),
                    content: Text("Time is already configured"),
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
              }
              else if(x == 2)
              {
                wifi_connected = true;
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: const Text("Connection Succeeded but failed to configure time"),
                        content: const Text("Do you Want to configure time with phone clock instead?"),
                        actions: <Widget> [
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("No")),
                          TextButton(onPressed: (){
                            var data = '${TimeOfDay.now().hour}+${TimeOfDay.now().minute}+${0},${DateTime.now().day}+${DateTime.now().month}+${DateTime.now().year}';
                            writeDataWithCharacteristic("6d6fb840-ed2b-438f-8375-9220a5164be8", data, context);
                            Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Time Configured"),
                                    content: Text(
                                      "",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          manually_configured = true;
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                          }, child: const Text("Yes")),
                        ],);
                    });
              }
              else if (x == 3)
              {
                wifi_connected = true;
                configured = true;
                Navigator.of(context).pop();
                // set up the button
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text("Connection Succeeded"),
                  content: Text("Time Configured"),
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
              }
              else if (x == 5)
              {
                Navigator.of(context).pop();
                // set up the button
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text("Connection Failed"),
                  content: Text("Time is already configured"),
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
              }
              else if(x == -100)
              {
                Navigator.of(context).pop();
                  // set up the button
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
              else
              {
                Navigator.of(context).pop();
                  // set up the button
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: () {Navigator.of(context).pop();popup=false;},
                  );

                  // set up the AlertDialog
                  AlertDialog alert = AlertDialog(
                    title: Text("Unexpected Error"),
                    content: Text("Try Connecting again"),
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
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SeekWifiMessage()));
            }, style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade800,),
                child: Text('Connect to Wifi',style: TextStyle(color: Colors.white),))
          ],
        ),
      )),
    );
  }

  void _configuredmessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Time Configured"),
          content: Text(
            "",
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



}

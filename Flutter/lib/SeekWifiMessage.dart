import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'HomePage.dart';

class SeekWifiMessage extends StatefulWidget {


  @override
  _SeekWifiMessageState createState() => _SeekWifiMessageState();
}

class _SeekWifiMessageState extends State<SeekWifiMessage> {
  static const String WIFI_SIGNAL_UUID = "be31c4e4-c3f7-4b6f-83b3-d9421988d355";


  Future<int> receiveDataFromESP() async {
    // Your Bluetooth logic using flutter_blue to receive data from ESP
    try {
      // Replace the following with your actual logic
      //FlutterBlue flutterBlue = FlutterBlue.instance;
     // BluetoothDevice device = (await flutterBlue.connectedDevices).first;
      //Guid characteristicUuid = Guid("placeholder");

      BluetoothCharacteristic? ch=characteristicDictionary[WIFI_SIGNAL_UUID];
      if (ch == null) {
        return -1;
      }

      /* BluetoothCharacteristic charcteristic =
      await device.characteristics.firstWhere(
            (char) => char.uuid == characteristicUuid,
      );*/

      List<int>? value = await ch.read();
      return value.isNotEmpty ? value[0] : -1; // Assuming received data is a single byte
    } catch (e) {
      print("Error receiving data: $e");
      return -1;
    }
  }

  @override
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
        child: FutureBuilder(
          future: receiveDataFromESP(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              int receivedData = snapshot.data as int;
              if (receivedData == 0) {
                return Text('Faild To Connect \nPlease Try Again');
              } else if (receivedData == 1) {
                return Text('Connected Successfully');
              }
              return Container();


            }
          },
        ),
      ),
    );
  }
}

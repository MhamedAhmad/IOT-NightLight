import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'BTConnect.dart';
import 'HomePage.dart';
import 'NavigateToBluetooth.dart';
/*
void main() {
  runApp(const MyApp());
}
*/
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Night Light',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
        //home: MyHomePage(title: 'Night light'),
     home: StartPage(),
    ),
  );
}
class StartPage extends StatelessWidget {
  const StartPage({super.key}) ;
    @override
    Widget build(BuildContext context) {
      /*return FutureBuilder<List<BluetoothDevice>>(
        future: FlutterBlue.instance.connectedDevices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Stream is still loading
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle error
            return Text('Error: ${snapshot.error}');
          } else {
            // Check if there is at least one connected device
            List<BluetoothDevice> connectedDevices = snapshot.data!;
            for (var device in connectedDevices) {
              if (device.name.contains("ESP32")) {
                return MyHomePage(title: 'Night light');
              }
            }
            return BluetoothButtonPage();
            //return MyHomePage(title: 'Night light');
          }
        }
      );*/
      return BluetoothButtonPage();
    }
  }



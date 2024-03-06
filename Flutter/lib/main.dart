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
bool popup = false;
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Night Light',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,

      ),
        home: MyHomePage(title: 'Night light'),
     //home: StartPage(),
    ),
  );
}
class StartPage extends StatefulWidget {
  const StartPage({super.key}) ;
    @override
    _MyAppState createState() => _MyAppState();
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
      return MyHomePage(title: 'Night light');
    }
  }

class _MyAppState extends State<StartPage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
      // --
        if(!connected && !inside && !popup) {
          showDialog(context: context, builder: (context) {
            return Center(child: CircularProgressIndicator());
          },);
          await targetDevice.connect(autoConnect: false);
          await discoverServices();
          Navigator.of(context).pop();
          connected = true;
        }
        print('Resumed');
        break;
      case AppLifecycleState.inactive:
      // --
        print('Inactive');
        break;
      case AppLifecycleState.paused:
      // --
        await targetDevice.disconnect();
        connected = false;
        print('Paused');
        break;
      case AppLifecycleState.detached:
      // --
        print('Detached');
        break;
      case AppLifecycleState.hidden:
      // A new **hidden** state has been introduced in latest flutter version
        print('Hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BluetoothButtonPage();
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'HomePage.dart';

/*
class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map((e) => Column(
      children: [
        ListTile(
          title: Text("OFF"),
          onTap: () {
            print(e.characteristics);
            e.characteristics[0].write([0]);
          },
        ),
        ListTile(
          title: Text("ON"),
          onTap: () {
            print(e.characteristics);
            e.characteristics[0].write([1]);
          },
        ),
      ],
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context).primaryTextTheme.button?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading:
                (snapshot.data == BluetoothDeviceState.connected) ? Icon(Icons.bluetooth_connected) : Icon(Icons.bluetooth_disabled),
                title: Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      TextButton(
                        child: Text("Show Services"),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: Colors.teal.shade50,
        body:SingleChildScrollView(
          child: Column(
              children:[
                Text(
                  'Please Choose ESP32',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 8),

                Column(
                  children: <Widget>[
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBlue.instance.scanResults,
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .where((result) => result.device.name.isNotEmpty)
                            .map((result) => ListTile(
                            title: Text(/*result.device.name == "" ? "Not relevant " : */ result.device.name),
                            subtitle: Text(result.device.id.toString()),
                            onTap: ()  async {
                              await result.device.connect();
                              List<BluetoothService> services = await result.device.discoverServices();
                              var SERVICE_UUID = "cfdfdee4-a53c-47f4-a4f1-9854017f3817";
                              for (var service in services) {
                                if (service.uuid.toString() == SERVICE_UUID) {
                                  for (var characteristics in service.characteristics) {
                                    characteristicDictionary[characteristics.uuid.toString()]=characteristics;
                                  }
                                }
                              }
                              FlutterBlue.instance.stopScan();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(title: 'Night Light'),
                                ),
                              );

                              //Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              //return DeviceScreen(device: result.device);
                              //}));
                            }),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),]),
        ));
  }
}
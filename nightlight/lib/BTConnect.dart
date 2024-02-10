import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';


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
    return Container();
    /*return Scaffold(
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
    );*/
  }
}


class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BluetoothDevice aa;
    /*return Scaffold(
        backgroundColor: Colors.teal.shade50,
        appBar: AppBar(
          title: Text('WIFI Settings'),
        ),
        body:SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((result) => ListTile(
                      title: Text(result.device.name == "" ? "Not relevant " : result.device.name),
                      subtitle: Text(result.device.id.toString()),
                      onTap: ()  {
                        result.device.connect();
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        //result.device.connect();
                        //return DeviceScreen(device: result.device);
                        //}));
                      }),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ));*/
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text('WIFI Settings'),
      ),
        body:SingleChildScrollView(
      child: Column(
        children: <Widget>[
          StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data!
                  .map((result) => ListTile(
                title: Text(result.device.name == "" ? "Not relevant " : result.device.name),
                subtitle: Text(result.device.id.toString()),
                onTap: ()  {
                  result.device.connect();
                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //result.device.connect();
    //return DeviceScreen(device: result.device);
    //}));
                }),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    ));
  }
}
/*
class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return FindDevicesScreen();
              }
              return BluetoothOffScreen(state: state);
            })
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: const Text('Error',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth/Location Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
            ),
          ],
        ),
      ),
    );
  }
}*/
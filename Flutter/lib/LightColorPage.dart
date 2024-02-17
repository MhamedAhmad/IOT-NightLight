import 'package:flutter/material.dart';
import 'package:nightlight/widgets/ColorPicker.dart';
import 'HomePage.dart';

class LightColorPage extends StatefulWidget {
  LightColorPage(this.c_uid, {super.key});
  late String c_uid;
  Color _currentColor = Colors.blue;

  @override
  State<LightColorPage> createState() => _LightColorPageState();
}



class _LightColorPageState extends State<LightColorPage> {

  void _onColorChanged(Color color) {
    setState(() => widget._currentColor = color);
    var data = '${widget._currentColor.red}+${widget._currentColor.green}+${widget._currentColor.blue}';
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
      body: Center(
        child:
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

      ),
    );
  }





}

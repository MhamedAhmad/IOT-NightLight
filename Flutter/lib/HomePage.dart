import 'package:flutter/material.dart';
import 'package:nightlight/widgets/ColorPicker.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  String title;

  Color _currentColor = Colors.blue;
  TimeOfDay? _startTime = null;
  TimeOfDay? _endTime = null;
  double motionDetectionValue = 1;
  double standbyValue = 1;
  int selectedDropdownValue = 0;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onColorChanged(Color color) {
    setState(() => widget._currentColor = color);
  }

  void _showTimePicker(bool setStart) {
    showTimePicker(
      context: context,
      initialTime: setStart? (widget._startTime ?? TimeOfDay.now()) : (widget._endTime ?? TimeOfDay.now()),
    ).then((value) {
      setState(() {
        if(value != null)
          {
            if(setStart)
              widget._startTime = value!;
            else
              widget._endTime = value!;
          }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title ,
          style: TextStyle(fontSize: 35,
          fontWeight: FontWeight.bold,)
        ),
      ),
      body: SingleChildScrollView(child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30,),
            Text(
              'Time', style: TextStyle(
                fontSize: 30,fontWeight: FontWeight.w500
            ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => _showTimePicker(true),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'Start Time',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\n" + (widget._startTime != null ? widget._startTime!.format(context) : TimeOfDay.now().format(context)),
                            style: TextStyle(fontSize: 14, color: Colors.grey,),
                          ),
                        ],
                      ),
                    )
                    ,
                  ),
                ),
                SizedBox(width: 20,),
                OutlinedButton(
                  onPressed: () => _showTimePicker(false),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'End Time',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\n" + (widget._endTime != null ? widget._endTime!.format(context) : TimeOfDay.now().format(context)),
                            style: TextStyle(fontSize: 14, color: Colors.grey,),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Divider(height: 45,thickness: 2, color: Colors.teal,),
            CircleColorPicker(
              strokeWidth: 16,
              initialColor: widget._currentColor,
              onChanged: _onColorChanged, colorCodeBuilder: (context, color) {
              return Text(
                'rgb(${color.red}, ${color.green}, ${color.blue})',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
            ),
            Divider(height: 45,thickness: 2, color: Colors.teal,),
            Text(
              'Intensity', style: TextStyle(
                fontSize: 30,fontWeight: FontWeight.w500
            ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Standby Mode',
                      style: TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: widget.standbyValue,
                      onChanged: (value) {
                        setState(() {
                          widget.standbyValue = value;
                        });
                      },
                      min: 1,
                      max: 100,
                      divisions: 100,
                      label: widget.standbyValue.round().toString(),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Motion Detection',
                      style: TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: widget.motionDetectionValue,
                      onChanged: (value) {
                        setState(() {
                          widget.motionDetectionValue = value;
                        });
                      },
                      min: 1,
                      max: 100,
                      divisions: 100,
                      label: widget.motionDetectionValue.round().toString(),
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 45, thickness: 2, color: Colors.teal),
            Text(
              'Delay Time', style: TextStyle(
                fontSize: 30,fontWeight: FontWeight.w500
            ),
            ),
            DropdownButton<int>(
              value: widget.selectedDropdownValue,
              onChanged: (int? newValue) {
                setState(() {
                  widget.selectedDropdownValue = newValue!;
                });
              },
              items: List.generate(251, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(index.toString()),
                );
              }),
            ),


          ],
        ),
      ),),
    );
  }
}

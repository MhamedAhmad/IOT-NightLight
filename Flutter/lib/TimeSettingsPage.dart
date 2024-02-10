import 'package:flutter/material.dart';
import 'HomePage.dart';

class TimeSettingsPage extends StatefulWidget {
  TimeSettingsPage(String time_uuid, {Key? key});
  late String c_uid;
  TimeOfDay? _startTime = null;
  TimeOfDay? _endTime = null;
  int delayTime = 0;
  int riseTime = 0;
  int fadeTime = 0;

  @override
  State<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

class _TimeSettingsPageState extends State<TimeSettingsPage> {
  void _showTimePicker(bool setStart) {
    showTimePicker(
      context: context,
      initialTime: setStart
          ? (widget._startTime ?? TimeOfDay.now())
          : (widget._endTime ?? TimeOfDay.now()),
    ).then((value) {
      setState(() {
        if (value != null) {
          if (setStart)
            widget._startTime = value!;
          else
            widget._endTime = value!;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(characteristicDictionary.length);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => _showTimePicker(true),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'Start Time',
                        style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\n" +
                                (widget._startTime != null
                                    ? widget._startTime!.format(context)
                                    : TimeOfDay.now().format(context)),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                OutlinedButton(
                  onPressed: () => _showTimePicker(false),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'End Time',
                        style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\n" +
                                (widget._endTime != null
                                    ? widget._endTime!.format(context)
                                    : TimeOfDay.now().format(context)),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 100,
              color: Colors.orange,
              thickness: 2,
            ),
            Text(
              'Delay Time',
              style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: widget.delayTime,
              onChanged: (int? newValue) {
                setState(() {
                  widget.delayTime = newValue!;
                });
              },
              items: List.generate(11, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(index.toString()),
                );
              }),
            ),
            Divider(
              height: 100,
              color: Colors.orange,
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rise Time',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: widget.riseTime,
                      onChanged: (int? newValue) {
                        setState(() {
                          widget.riseTime = newValue!;
                        });
                      },
                      items: List.generate(11, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(index.toString()),
                        );
                      }),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fade Time',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: widget.fadeTime,
                      onChanged: (int? newValue) {
                        setState(() {
                          widget.fadeTime = newValue!;
                        });
                      },
                      items: List.generate(11, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(index.toString()),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: () {
              var start = widget._startTime ?? TimeOfDay.now();
              var end = widget._endTime ?? TimeOfDay.now();
              var data = '${start.hour+start.minute + end.hour+end.minute
                  + widget.riseTime+widget.fadeTime + widget.delayTime}';
              writeDataWithCharacteristic(widget.c_uid,data);
            }, style: ElevatedButton.styleFrom(
            primary: Colors.orange, // Change this to the color you want
            ),child: Text('Apply Changes'))
          ],
        ),
      ),
    );
  }
}
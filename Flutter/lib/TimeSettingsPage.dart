import 'package:flutter/material.dart';
import 'package:nightlight/ColorsPages/EndColorPage.dart';
import 'package:nightlight/ColorsPages/StartColorPage.dart';
import 'HomePage.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Import the package
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


class TimeSettingsPage extends StatefulWidget {
  TimeSettingsPage(this.c_uid, {Key? key});

  late String c_uid;
  TimeOfDay? _startTime = TimeOfDay.now();
  TimeOfDay? _endTime = TimeOfDay.now();
  int delayTime = 0;
  int transitionTime = 0;
  int riseTime = 0;
  int fadeTime = 0;
  bool isLoading = true;
  String loadingMessage = 'Loading Time Settings...';

  @override
  State<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

class _TimeSettingsPageState extends State<TimeSettingsPage> {

  @override
  void initState() {
    super.initState();
    _loadTimeSettings();

  }

  bool get _isFadingIn {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day, widget._startTime!.hour, widget._startTime!.minute);
    DateTime fadeInEndTime = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      (startTime.hour * 60 + startTime.minute - widget.fadeTime) ~/ 60, // Extracting hours
      (startTime.hour * 60 + startTime.minute - widget.fadeTime) % 60,  // Extracting minutes
    );

    return now.isBefore(startTime) && now.isAfter(fadeInEndTime);
  }

  bool get _isNightMode {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day, widget._startTime!.hour, widget._startTime!.minute);
    DateTime endTime = DateTime(now.year, now.month, now.day, widget._endTime!.hour, widget._endTime!.minute);
    DateTime tranistion = DateTime(
      endTime.year,
      endTime.month,
      endTime.day,
      (endTime.hour * 60 + endTime.minute - widget.transitionTime) ~/ 60, // Extracting hours
      (endTime.hour * 60 + endTime.minute - widget.transitionTime) % 60,  // Extracting minutes
    );

    return now.isBefore(tranistion) && now.isAfter(startTime);
  }

  bool get _isTransitioning {

    DateTime now = DateTime.now();
    DateTime endTime = DateTime(now.year, now.month, now.day, widget._endTime!.hour, widget._endTime!.minute);
    DateTime tranistion = DateTime(
      endTime.year,
      endTime.month,
      endTime.day,
      (endTime.hour * 60 + endTime.minute - widget.transitionTime) ~/ 60, // Extracting hours
      (endTime.hour * 60 + endTime.minute - widget.transitionTime) % 60,  // Extracting minutes
    );
    return now.isBefore(endTime) && now.isAfter(tranistion);
  }

  bool get _isFadingOut {
    DateTime now = DateTime.now();
    DateTime endTime = DateTime(now.year, now.month, now.day, widget._endTime!.hour, widget._endTime!.minute);
    DateTime fadeOutEndTime = DateTime(
      endTime.year,
      endTime.month,
      endTime.day,
      (endTime.hour * 60 + endTime.minute + widget.fadeTime) ~/ 60, // Extracting hours
      (endTime.hour * 60 + endTime.minute + widget.fadeTime) % 60,  // Extracting minutes
    );
    print(fadeOutEndTime);


    return now.isAfter(endTime) && now.isBefore(fadeOutEndTime);
  }


  Widget _buildCenterText() {
    if (_isFadingIn) {
      return Text(
        "Fading In",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else if (_isNightMode) {
      return Text(
        "Night Running",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else if (_isTransitioning) {
      return Text(
        "Transitioning",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else if (_isFadingOut) {
      return Text(
        "Fading Out",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else {
      return Text(
        "OFF",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    }
  }


  double _calculateProgress() {
    if (widget._startTime == null || widget._endTime == null) {
      return 0.0;
    }

    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day, widget._startTime!.hour, widget._startTime!.minute)
        .subtract(Duration(minutes: widget.riseTime));
    DateTime endTimeWithFadeOut = DateTime(now.year, now.month, now.day, widget._endTime!.hour, widget._endTime!.minute)
        .add(Duration(minutes: widget.fadeTime));

    Duration totalDuration = endTimeWithFadeOut.difference(startTime);
    Duration elapsedTime = now.difference(startTime);
    double progress = elapsedTime.inMilliseconds / totalDuration.inMilliseconds;

    // Ensure progress is between 0 and 1
    progress = progress.clamp(0.0, 1.0);
    return progress;
  }




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

  int limitRTime() {
    // Convert string times to DateTime objects
    if (widget._startTime == null || widget._endTime == null) return 0;
    int startTimeInMinutes =
        widget._startTime!.hour * 60 + widget._startTime!.minute;
    int endTimeInMinutes = widget._endTime!.hour * 60 + widget._endTime!.minute;

    // Calculate available time for the light to be on
    int availableTime = (startTimeInMinutes > endTimeInMinutes)
        ? 24 * 60 - (startTimeInMinutes - endTimeInMinutes)
        : endTimeInMinutes - startTimeInMinutes;

    // Calculate maximum allowed rise time and fade time (capped at 10 minutes)
    return availableTime.clamp(0, 10);
  }

  int limitFTime() {
    // Convert string times to DateTime objects
    if (widget._startTime == null || widget._endTime == null) return 0;
    int startTimeInMinutes =
        widget._startTime!.hour * 60 + widget._startTime!.minute;
    int endTimeInMinutes = widget._endTime!.hour * 60 + widget._endTime!.minute;

    // Calculate available time for the light to be on
    int availableTime = (startTimeInMinutes > endTimeInMinutes)
        ? (startTimeInMinutes - endTimeInMinutes)
        : 24 * 60 - (startTimeInMinutes - endTimeInMinutes);

    // Calculate maximum allowed rise time and fade time (capped at 10 minutes)
    return availableTime.clamp(0, 10);
  }

  void _loadTimeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int startHour = prefs.getInt('startHour') ?? TimeOfDay.now().hour;
    int startMinute = prefs.getInt('startMinute') ?? TimeOfDay.now().minute;
    int endHour = prefs.getInt('endHour') ?? TimeOfDay.now().hour;
    int endMinute = prefs.getInt('endMinute') ?? TimeOfDay.now().minute;

    setState(() {
      widget._startTime = TimeOfDay(hour: startHour, minute: startMinute);
      widget._endTime = TimeOfDay(hour: endHour, minute: endMinute);
      widget.delayTime = prefs.getInt('delayTime') ?? 0;
      widget.riseTime = prefs.getInt('riseTime') ?? 0;
      widget.fadeTime = prefs.getInt('fadeTime') ?? 0;
      widget.transitionTime = prefs.getInt('transitionTime') ?? 0;
      widget.isLoading = false;
    });
  }

  void _saveTimeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('startHour', widget._startTime!.hour);
    prefs.setInt('startMinute', widget._startTime!.minute);
    prefs.setInt('endHour', widget._endTime!.hour);
    prefs.setInt('endMinute', widget._endTime!.minute);
    prefs.setInt('delayTime', widget.delayTime);
    prefs.setInt('riseTime', widget.riseTime);
    prefs.setInt('fadeTime', widget.fadeTime);
    prefs.setInt('transitionTime', widget.transitionTime);

  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. Set sleep and wake up times for the night light.\n"
                    "2. Set motion delay time, rise time, and fade time (in minutes) as desired.\n"
                    "3. Press 'Apply Changes' to save the settings.",
              ),
              SizedBox(height: 10), // Adjust spacing between text and image
              Image.asset(
                'assets/graph.jpg', // Replace this with your image asset path
                width: 400, // Adjust width as needed
                height: 300, // Adjust height as needed
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal.shade800,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Night Light',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
    physics: BouncingScrollPhysics(),
    child: Center(
        child: widget.isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              widget.loadingMessage,
              style: TextStyle(fontSize: 16),
            ),
          ],
        )
            : Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => _showTimePicker(true),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 25.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'Sleep Time',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\n" +
                                (widget._startTime != null
                                    ? widget._startTime!
                                    .format(context)
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 25.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'Wake Up Time',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\n" +
                                (widget._endTime != null
                                    ? widget._endTime!
                                    .format(context)
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
              color: Colors.teal.shade800,
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fade In',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: widget.fadeTime,
                      onChanged: (int? newValue) {
                        setState(() {
                          widget.fadeTime = newValue!;
                        });
                      },
                      items: List.generate(
                          //limitFTime() + 1,
                        121,
                              (index) {
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
                      'Fade Out',
                      style: TextStyle(
                          fontSize: 20,
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
                      items: List.generate(
                          //limitRTime() + 1,
                         121,
                              (index) {
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
            Divider(
              height: 100,
              color: Colors.teal.shade800,
              thickness: 2,
            ),
            Text(
              'Motion Delay Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alef',
              ),
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
              color: Colors.teal.shade800,
              thickness: 2,
            ),
            Text(
              'Transition Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alef',
              ),
            ),
            DropdownButton<int>(
              value: widget.transitionTime,
              onChanged: (int? newValue) {
                setState(() {
                  widget.transitionTime = newValue!;
                });
              },
              items: List.generate(11, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(index.toString()),
                );
              }),
            ),

            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                _saveTimeSettings(); // Save the time settings
                var start = widget._startTime ?? TimeOfDay.now();
                var end = widget._endTime ?? TimeOfDay.now();
                var data =
                    '${start.hour}+${start.minute}+${end.hour}+${end.minute}+${widget.riseTime}+${widget.fadeTime}+${widget.delayTime}+${widget.transitionTime}';
                writeDataWithCharacteristic(
                    widget.c_uid, data, context);
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'Night Light'),
                    ));
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text("Time Cycle Settings Changed"),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),


            SizedBox(
              height: 30,
            ),


            new CircularPercentIndicator(
              radius: 100.0,
              animation: true,
              animationDuration: 2000,
              lineWidth: 15.0,
              percent: _calculateProgress(),
              center: _buildCenterText(),
              circularStrokeCap: CircularStrokeCap.butt,
              backgroundColor: Colors.grey.shade300,
              progressColor: _calculateProgress()==1?  currentStartColor: currentEndColor,
            ),

            SizedBox(
              height: 30,
            ),

          ],
        ),
      )),
    );
  }
}

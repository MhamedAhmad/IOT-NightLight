import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Use This App:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. Step one instruction goes here.',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '2. Step two instruction goes here.',
              style: TextStyle(fontSize: 18),
            ),
            // Add more instructions as needed
          ],
        ),
      ),
    );
  }
}

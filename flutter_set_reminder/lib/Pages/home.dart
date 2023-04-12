import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_set_reminder/Pages/reminder.dart';
import 'package:flutter_set_reminder/services/notify_service.dart';
import 'package:intl/intl.dart';

DateTime scheduleTime = DateTime.now();

class Home extends StatefulWidget {
  final User user;

  const Home({Key? key, required this.user}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String dateText = "";

  String formatCurrentDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  getCurrentLiveTime() {
    final String liveDate = formatCurrentDate(DateTime.now());

    if (this.mounted) {
      setState(() {
        dateText = liveDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    //date
    dateText = formatCurrentDate(DateTime.now());

    Timer.periodic(Duration(seconds: 1), (timer) {
      getCurrentLiveTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hey hii'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Welcome today is ${DateFormat('EEEE').format(DateTime.now())}!!',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderPage(user: widget.user),
                  ),
                );
              },
              child: Text('Go to Reminder Page'),
            ),
            ElevatedButton(
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  onChanged: (date) => scheduleTime = date,
                  onConfirm: (date) {
                    setState(() {
                      scheduleTime = date;
                    });
                  },
                  currentTime: scheduleTime,
                );
              },
              child: Text('Select Date and Time'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('Notification Scheduled for $scheduleTime');
                NotificationService().scheduleNotification(
                  title: 'Scheduled Notification',
                  body: '$scheduleTime',
                  scheduledNotificationDateTime: scheduleTime,
                );
              },
              child: Text('Schedule Notifications'),
            ),
            const SizedBox(height: 20), // add some vertical space
          ],
        ),
      ),
    );
  }
}

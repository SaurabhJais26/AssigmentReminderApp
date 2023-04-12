import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_set_reminder/Pages/welcome.dart';
import 'package:flutter_set_reminder/signIn.dart';
import 'package:intl/intl.dart';

import '../services/notify_service.dart';

DateTime scheduleTime = DateTime.now();

class ReminderPage extends StatefulWidget {
  final User user;

  const ReminderPage({Key? key, required this.user}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _firestore;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _firestore = FirebaseFirestore.instance;
    //date
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CollectionReference docRef = _firestore.collection('reminders');
    //  int a = docRef.snapshots().length as int;
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Lane'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance
                    .signOut(); // this will sign out the current user
                print('User signed out');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WelcomePage()));
              } catch (e) {
                print('Error signing out: $e');
              }
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reminders')
                  .where('user_id', isEqualTo: _user!.uid)
                  .orderBy('created_at')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          return ListTile(
                            title: Text(document['title']),
                            subtitle: Text(document['description']),
                            leading: Container(
                              child: DatePickerTxt(
                                title: document['title'],
                                description: document['description'],
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteReminder(document.id),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                }
              },
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Please provide a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Please provide a description';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  ElevatedButton(
                    onPressed: _addReminder,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'user_id': _user!.uid,
        'created_at': Timestamp.now(),
      };
      await _firestore.collection('reminders').add(reminder);
      _titleController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder added')),
      );
    }
  }

  void _deleteReminder(String reminderId) async {
    await _firestore.collection('reminders').doc(reminderId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder deleted')),
    );
  }
}

class DatePickerTxt extends StatefulWidget {
  String title;
  String description;
  DatePickerTxt({
    Key? key,
    required String this.title,
    required String this.description,
  }) : super(key: key);

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) => scheduleTime = date,
          onConfirm: (date) {},
        );
        debugPrint('Notification Scheduled for $scheduleTime');
        NotificationService().scheduleNotification(
          title: widget.title,
          body: widget.description,
          scheduledNotificationDateTime: scheduleTime,
        );
      },
      child: const Icon(Icons.add_alarm),
    );
  }
}

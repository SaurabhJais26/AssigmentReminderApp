import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_set_reminder/Pages/home.dart';
import 'package:flutter_set_reminder/Pages/reminder.dart';
import 'package:flutter_set_reminder/Pages/sign_up.dart';
import 'package:flutter_set_reminder/signIn.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser == null
        ? Scaffold(
            appBar: AppBar(
              title: Text('Remind Me'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: navigateToSignIn,
                    child: Text('Sign in'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: navigateToSignUp,
                    child: Text('Sign up'),
                  ),
                ],
              ),
            ),
          )
        : Home(
            user: FirebaseAuth.instance.currentUser!,
          );
  }

  void navigateToSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
        fullscreenDialog: true,
      ),
    );
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(),
        fullscreenDialog: true,
      ),
    );
  }
}

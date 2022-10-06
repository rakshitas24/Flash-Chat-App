// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flash_chat/welcome_screen.dart';
import 'package:flash_chat/login_screen.dart';
import 'package:flash_chat/registration_screen.dart';
import 'package:flash_chat/chat_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'welcome_screen',
      routes: {
        'welcome_screen':(context) => WelcomeScreen(),
        'login_screen':(context) => LoginScreen(),
        'registration_screen':(context) => RegistrationScreen(),
        'chat_screen':(context) => ChatScreen(),
      },
    );
  }
}
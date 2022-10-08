// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, await_only_futures, avoid_print, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  String messageText = '';
  
  @override 
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if(user != null) {
        loggedInUser = user;
      }
    } catch(e) {
      print(e);
    }
  }

 void messageStream() async {
  await for (var snapshot in _firestore.collection('message').snapshots()) {
    for (var message in snapshot.docs) {
      print(message.data());
    }
  }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () { 
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _firestore.collection('message').snapshots(), 
              builder: (context, snapshot) {
                if(!snapshot.hasData)
                {
                  return Center(
                    child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
                  );
                }

                final messages = snapshot.data!.docs.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages) {
                  final messageText = message.data()['text'];
                  final messageSender = message.data()['sender'];
                  final currentUser = loggedInUser.email;
                  final messageBubble = MessageBubble(sender: messageSender, text: messageText, isMe: currentUser==messageSender);
                  messageBubbles.add(messageBubble);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageBubbles,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('message').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({required this.sender, required this.text, required this.isMe});

  final String sender;
  final String text;
  final bool isMe; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
          Material(
            elevation: 5.0,
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ) : BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                text, 
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white: Colors.black54,
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}
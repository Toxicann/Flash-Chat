// ignore_for_file: deprecated_member_use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final _fireStore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late User loggedInUser;
  late String messageText;
  final myKeyboardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(currentUser: loggedInUser.email),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: myKeyboardController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                      onSubmitted: (none) {
                        _fireStore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'timeStamp': FieldValue.serverTimestamp(),
                        });
                        myKeyboardController.clear();
                      },
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _fireStore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'timeStamp': FieldValue.serverTimestamp(),
                      });
                      myKeyboardController.clear();
                    },
                    child: const Text(
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

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key, required this.currentUser}) : super(key: key);
  final currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection("messages")
          .orderBy('timeStamp', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data.docs.reversed;
          List<MessageBubbles> messageBubble = [];
          for (var message in messages) {
            final messageText = message['text'];
            final senderEmail = message['sender'];
            final bubble = MessageBubbles(
              messageText: messageText,
              senderEmail: senderEmail,
              isMe: currentUser == senderEmail,
            );
            messageBubble.add(bubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              children: messageBubble,
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class MessageBubbles extends StatelessWidget {
  const MessageBubbles({
    Key? key,
    required this.messageText,
    required this.senderEmail,
    required this.isMe,
  }) : super(key: key);

  final messageText;
  final senderEmail;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderEmail,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Material(
            color: isMe
                ? Color.fromARGB(255, 50, 185, 248)
                : Color.fromARGB(255, 240, 234, 234),
            elevation: 5.0,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            child: Padding(
              child: Text(
                '$messageText ',
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
              padding: const EdgeInsets.all(15.0),
            ),
          ),
        ],
      ),
    );
  }
}

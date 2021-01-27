import 'package:chewie/chewie.dart';
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
      title: 'WhatsApp Saver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'WhatsApp Saver'),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  Future userFuture;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    getFilePath();
    super.initState();
  }

  List<FileSystemEntity> videosList;
  List<FileSystemEntity> imagesList;
  bool loading = true;
  bool emptyState = false;
  Future<void> getFilePath() async {
    await checkPermission();
    setState(() {
      loading = true;
    });
    // Directory appDocDir1 = await getExternalStorageDirectory();
    // String appDocPath1 = appDocDir1.path;
    // String path = appDocPath1.toString();
    // var theIndex = path.indexOf('/Android/data/com.example.whatsappsave/files');
    // var subStr = path.substring(1, theIndex);
    var newDir = '/storage/emulated/0//WhatsApp/Media/.Statuses';
    var directory = Directory(newDir);

    try {
      List<dynamic> theFile1 = directory.listSync();
      if (theFile1.isNotEmpty) {
        List<FileSystemEntity> videos =
        theFile1.where((f) => f.path.endsWith('.mp4')).toList();
        List<FileSystemEntity> videos1 =
        theFile1.where((f) => f.path.endsWith('.gif')).toList();
        List<FileSystemEntity> jpgImage =
        theFile1.where((f) => f.path.endsWith('.jpg')).toList();
        List<FileSystemEntity> pngImage =
        theFile1.where((f) => f.path.endsWith('.png')).toList();
        setState(() {
          videosList = videos + videos1;
          imagesList = jpgImage + pngImage;
          loading = false;
        });
      } else {
        setState((){
          emptyState = true;
          loading = false;
        });
      }
    } catch (e){
      setState((){
        emptyState = true;
        loading = false;
      });
    }
  }

  checkPermission() async {
    var storageStatus = await Permission.storage.status;
    print(storageStatus);
    if (storageStatus.isDenied) {
      await Permission.storage.request();
    }
    print(storageStatus);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              onTap: (index) {},
              tabs: [
                Tab(icon: Icon(Icons.image)),
                Tab(icon: Icon(Icons.video_library)),
              ],
            ),
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: null,
              ),
              IconButton(
                icon: Icon(Icons.help, color: Colors.white),
                onPressed: null,
              ),
            ],
            backgroundColor: Color.fromRGBO(18, 140, 126, 1),
          ),
          drawer: Drawer(),
          body: TabBarView(
            children: [
              loading
                  ? Center(child: CircularProgressIndicator())
                  : emptyState
                      ? Container(
                          child: Center(child: Text('No Content')),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          children: List.generate(imagesList.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(
                                      File(imagesList[index].path),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
              loading
                  ? Center(child: CircularProgressIndicator())
                  : emptyState
                      ? Container(
                          child: Center(child: Text('No Content')),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          children: List.generate(videosList.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Container(
                                height: 20,
                                width: 20,
                                child: Stack(
                                  children: [
                                    // Container(color:Colors.red, height:200.0, width:200.0),
                                    Positioned.fill(
                                      child: Chewie(
                                        controller: ChewieController(
                                          fullScreenByDefault: false,
                                          autoInitialize: true,
                                          errorBuilder:
                                              (context, errorMessage) {
                                            return Center(
                                              child: Text(
                                                errorMessage,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            );
                                          },
                                          videoPlayerController:
                                              VideoPlayerController.file(File(
                                                  '/${videosList[index].path}')),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

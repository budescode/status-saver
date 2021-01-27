import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Status Saver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratAlternatesTextTheme()
      ),
      home: MyHomePage(title: 'WhatsApp Status Saver'),
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

  final key = GlobalKey<ScaffoldState>();

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
    /*Directory appDocDir1 = await getExternalStorageDirectory();
    String appDocPath1 = appDocDir1.path;
    String path = appDocPath1.toString();
    var theIndex = path.indexOf('/Android/data/com.example.whatsappsave/files');
    var subStr = path.substring(1, theIndex);*/
    var newDir = '/storage/emulated//0/WhatsApp Business/Media/.Statuses';
    var directory = Directory(newDir);
    print(directory);
    print('${!directory.existsSync() ? 'NO' : 'YES'}');
    print(directory.listSync().length);

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
        setState(() {
          emptyState = true;
          loading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        emptyState = true;
        loading = false;
      });
    }
  }

  checkPermission() async {
    var storageStatus = await Permission.storage.status;
    print(storageStatus);
    if (!storageStatus.isGranted) {
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
          key: key,
          backgroundColor: Colors.white,
          appBar: AppBar(
            bottom: TabBar(
              onTap: (index) {},
              tabs: [
                Tab(icon: Icon(LineIcons.image)),
                Tab(icon: Icon(LineIcons.video_camera)),
              ],
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            leading: CupertinoButton(
              child: Icon(LineIcons.comment, color: Colors.white),
              onPressed: ()=> key.currentState.openDrawer(),
            ),
            excludeHeaderSemantics: true,
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: Icon(LineIcons.share, color: Colors.white),
                onPressed: null,
              ),
              IconButton(
                icon: Icon(LineIcons.question_circle, color: Colors.white),
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
                      ? _EmptyView()
                      : GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 0.8,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          children: List.generate(imagesList.length, (index) {
                            return _ImageItem(imagesList[index].path);
                          }),
                        ),
              loading
                  ? Center(child: CircularProgressIndicator())
                  : emptyState
                      ? _EmptyView()
                      : GridView.count(
                          crossAxisCount: 1,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: List.generate(videosList.length, (index) {
                            return VideoItem(videosList[index].path);
                          }),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final File image;
  _ImageViewer(this.image);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Center(
        child: Hero(
          tag: image.path,
          child: Image.file(image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _ImageItem extends StatelessWidget {
  final String image;
  _ImageItem(this.image);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _ImageViewer(
            File(image),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  File(image),
                ),
              ),
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class VideoItem extends StatelessWidget {
  final String videoPath;
  VideoItem(this.videoPath);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(),
      child: Stack(
        children: [
          // Container(color:Colors.red, height:200.0, width:200.0),
          Positioned.fill(
            child: Chewie(
              controller: ChewieController(
                fullScreenByDefault: false,
                autoInitialize: true,
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                          color: Colors.white),
                    ),
                  );
                },
                videoPlayerController:
                VideoPlayerController.file(
                  File(
                    '/$videoPath',
                  ),
                ),
                aspectRatio: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('No Content')),
    );
  }
}


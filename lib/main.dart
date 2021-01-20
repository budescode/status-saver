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
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(4);
   
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
    var theindex = path.indexOf('/Android/data/com.example.whatsappsave/files');
    var substr = path.substring(1, theindex);
    var newdir = '$substr/WhatsApp/Media/.Statuses';
    var directory = new Directory(newdir);
    List<dynamic> thefile1 = directory.listSync();
    File newfile = thefile1[1];
    List<FileSystemEntity> videos = thefile1.where((f) => f.path.endsWith('.mp4')).toList();
    List<FileSystemEntity> jpgimage = thefile1.where((f) => f.path.endsWith('.jpg')).toList();
    List<FileSystemEntity> pngimage = thefile1.where((f) => f.path.endsWith('.png')).toList();
    File newvideo = videos[1];
    File myfile = File(newvideo.path);
    print(newvideo);
    //print(videos);

    setState((){
      firstimage = newfile.path;    
      videoslist = videos;
      imageslist = jpgimage + pngimage;
      _controller = VideoPlayerController.file(File('/${newvideo.path}')); 
      print('/${newvideo.path}'); 
       _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(1.0);
      _controller.play();
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
  return DefaultTabController(
  length: 2,
  child: MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          onTap: (index) {
          },
          tabs: [
            Tab(icon: Icon(Icons.image)),
            Tab(icon: Icon(Icons.video_library)),
          ],
        ),
        
        title: Text(widget.title),
          actions: [
            IconButton(icon: Icon(Icons.share, color:Colors.white), onPressed: null),
            IconButton(icon: Icon(Icons.help, color:Colors.white), onPressed: null),            
          ],
          backgroundColor: Color.fromRGBO(18, 140, 126, 1),
      ),
      drawer: Drawer(),
      body: TabBarView(
        children: [
                      loading ?CircularProgressIndicator() : GridView.count(
  crossAxisCount: 2 ,
  children: List.generate(imageslist.length,(index){
    return Padding(
      padding: const EdgeInsets.only(bottom:5.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(       
                  image: DecorationImage(
                        image: FileImage(File(imageslist[index].path))
           )
      )
        // child: Text('yayaya')
      ),
    );
  }),
),
          Center(
              child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  ClosedCaption(text: _controller.value.caption.text),
                  VideoProgressIndicator(_controller),
                ],
              ),
            ),
          )
          
        ],
      ),
    ),
  ),
);

  }
}

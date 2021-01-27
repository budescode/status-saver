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
  Future userFuture;
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
    List<FileSystemEntity> videos1 = thefile1.where((f) => f.path.endsWith('.gif')).toList();
    List<FileSystemEntity> jpgimage = thefile1.where((f) => f.path.endsWith('.jpg')).toList();
    List<FileSystemEntity> pngimage = thefile1.where((f) => f.path.endsWith('.png')).toList();
    // File newvideo = videos[1];
    // File myfile = File(newvideo.path);
    // print(newvideo);
    //print(videos);

    setState((){
      firstimage = newfile.path;    
      videoslist = videos + videos1;
      imageslist = jpgimage + pngimage;
      // _controller = VideoPlayerController.file(File('/${newvideo.path}')); 
      // print('/${newvideo.path}'); 
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
       var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
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
                        fit:BoxFit.cover,
                        image: FileImage(File(imageslist[index].path))
                )
            )
              // child: Text('yayaya')
            ),
          );
        }),
      ),

      loading ?CircularProgressIndicator() : GridView.count(
        crossAxisCount: 2 ,

        children: List.generate(videoslist.length,(index){
          return Padding(
            padding: const EdgeInsets.only(bottom:5.0),
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
                   autoInitialize : true,
                     errorBuilder: (context, errorMessage) {
                     return Center(
                     child: Text(
                     errorMessage,
                     style: TextStyle(color: Colors.white),
                     ),
                     );
                   },
                   videoPlayerController:
                    VideoPlayerController.file(File('/${videoslist[index].path}')),
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

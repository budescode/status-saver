import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String firstimage;

  Future<void> getFilePath() async {
    Directory appDocDir1 = await getExternalStorageDirectory();
    String appDocPath1 = appDocDir1.path;
    String path = appDocPath1.toString();
    var theindex = path.indexOf('/Android/data/com.example.whatsappsave/files');
    var substr = path.substring(1, theindex);
    var newdir = '$substr/WhatsApp/Media/.Statuses';
    var directory = new Directory(newdir);
    List<dynamic> thefile1 = directory.listSync();
    File newfile = thefile1[1];
    setState((){
      firstimage = newfile.path;          
    });
    print(firstimage);
  }

  checkPermission() async {
    var storageStatus = await Permission.storage.status;
    if (storageStatus == false){
      await Permission.storage.request() ;
    }
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
          Center(
            child: GestureDetector(
            onTap: () async {
              //getFilePath();
              await checkPermission();
              getFilePath();
              
            },
            child: Icon(Icons.delete)),
            ),
          Center(
              child: Container(
                height:180,
                width:100,
                decoration: BoxDecoration(       
                image: DecorationImage(
                      image: FileImage(File('$firstimage'))
         )
    )
)
          ),
        ],
      ),
    ),
  ),
);
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //       actions: [
    //         IconButton(icon: Icon(Icons.share, color:Colors.white), onPressed: null),
    //         IconButton(icon: Icon(Icons.help, color:Colors.white), onPressed: null),
            
    //       ],
    //     backgroundColor: Color.fromRGBO(18, 140, 126, 1),
    //   ),
    //   drawer: Drawer(),
    //   body: Center(     
    //   ),
    // );
  }
}

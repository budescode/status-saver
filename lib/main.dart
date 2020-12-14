import 'package:flutter/material.dart';
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
  String firstImage;

  Future<void> getFilePath() async {
    Directory appDocDir1 = await getExternalStorageDirectory();
    String appDocPath1 = appDocDir1.path;
    String path = appDocPath1.toString();
    var theIndex = path.indexOf('/Android/data/com.example.whatsappsave/files');
    var subStr = path.substring(1, theIndex);
    var newDir = '$subStr/WhatsApp Business/Media/.Statuses';
    var directory = new Directory(newDir);
    List<dynamic> theFile1 = directory.listSync();
    File newFile = theFile1[1];
    setState(() {
      firstImage = newFile.path;
    });
    print(firstImage);
  }

  checkPermission() async {
    var storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Color.fromRGBO(18, 140, 126, 1),
              bottom: TabBar(
                onTap: (index) {},
                tabs: [
                  Tab(icon: Icon(Icons.image)),
                  Tab(icon: Icon(Icons.video_library)),
                ],
              ),
              title: Text(widget.title),
              pinned: true,
              floating: true,
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
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5 - 50,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await checkPermission();
                          getFilePath();
                        },
                        child: Icon(Icons.delete),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      height: 180,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File('$firstImage')),
                        ),
                      ),
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

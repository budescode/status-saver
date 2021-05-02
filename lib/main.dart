import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsappsave/videolist.dart';
import 'package:whatsappsave/videoplay.dart';
import 'imageview.dart';
//import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void main() {
  runApp(MyApp());
}


enum WhatsAppType {
  OfficialWhatsApp,
  GBWhatsApp,
  BusinessWhatsApp,
  WhatsApp
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
    getTemporaryDirectory().then((d) => _tempDir = d.path);
    getFilePath(WhatsAppType.OfficialWhatsApp);
    super.initState();
  }

  String _tempDir;
  
  List <GenThumbnailImage> finalvideos;
   ImageFormat _format = ImageFormat.JPEG;
  int _quality = 50;
  int _sizeH = 0;
  int _sizeW = 0;
  int _timeMs = 0;


  List<FileSystemEntity> videosList;
  List<FileSystemEntity> imagesList;
  bool loading = true;
  bool emptyState = false;

  Future<void> getFilePath(WhatsAppType whatsApp) async {
    await checkPermission();
    setState(() {
      loading = true;
    });
    var newDir = '/storage/emulated//0/${whatAppType(whatsApp)}/Media/.Statuses';
    var directory = Directory(newDir);
    print(directory);
    print('${!directory.existsSync() ? 'NO' : 'YES'}');
    print(directory.listSync().length);

    try {
      List<dynamic> theFile1 = directory.listSync();
      theFile1.sort((a,b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
      // print(theFile1[0]);
      if (theFile1.isNotEmpty) {
        List<FileSystemEntity> videos =
            theFile1.where((f) => f.path.endsWith('.mp4')).toList();
        List<FileSystemEntity> videos1 =
            theFile1.where((f) => f.path.endsWith('.gif')).toList();
        List<FileSystemEntity> jpgImage =
            theFile1.where((f) => f.path.endsWith('.jpg')).toList();
        List<FileSystemEntity> pngImage =
            theFile1.where((f) => f.path.endsWith('.png')).toList();

              var newfile = videos[1];
              print(newfile);
              print('newwwwwwwwwwwwwwwww');
              var  _futreImage1 = GenThumbnailImage(
              thumbnailRequest: ThumbnailRequest(
              video: newfile.path,
              thumbnailPath: _tempDir,
              imageFormat: _format,
              maxHeight: _sizeH,
              maxWidth: _sizeW,
              timeMs: _timeMs,
              quality: _quality));
              List finalvideos1 = videos.map((e) =>               
              GenThumbnailImage(
              thumbnailRequest: ThumbnailRequest(
              video: e.path,
              thumbnailPath: _tempDir,
              imageFormat: _format,
              maxHeight: _sizeH,
              maxWidth: _sizeW,
              timeMs: _timeMs,
              quality: _quality))
              ).toList();
                         
                           
                         
        setState(() {
          
           finalvideos = finalvideos1;
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


  String whatAppType (WhatsAppType type) {
    if(type == WhatsAppType.GBWhatsApp) return 'GBWhatsApp';
    if(type == WhatsAppType.BusinessWhatsApp) return 'WhatsApp Business';
    return 'WhatsApp';
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
              indicatorColor: Colors.amber,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            leading: CupertinoButton(
              child: Icon(LineIcons.bars, color: Colors.white),
              onPressed: ()=> key.currentState.openDrawer(),
            ),
            excludeHeaderSemantics: true,
            title: Text(widget.title, style: GoogleFonts.montserrat()),
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
                      : RefreshIndicator(
                            onRefresh: () async {
                              
                              getFilePath(WhatsAppType.WhatsApp);
                            },
                            child: GridView.count(
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
                      ),
              loading
                  ? Center(child: CircularProgressIndicator())
                  : emptyState
                      ? _EmptyView():
     
                      GridView.count(
                          crossAxisCount: 2,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          addAutomaticKeepAlives: true,
                          children: List.generate(finalvideos.length, (index) {
                            return (finalvideos != null) ? GestureDetector(
                              onTap: (){
                                print(finalvideos[index].thumbnailRequest.video);
                                  Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                  builder: (context) => VideoItem(finalvideos[index].thumbnailRequest.video.toString()),
                                  ));
                              },
                              child: finalvideos[index]) : Text('Loading...');
                          }),
                        ),
                      
            ],
          ),
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
          builder: (_) => ImageViewer(
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



class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('No Content')),
    );
  }
}


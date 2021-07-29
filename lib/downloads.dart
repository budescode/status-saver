import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsappsaver/drawer.dart';
import 'package:whatsappsaver/models/model.dart';
import 'package:whatsappsaver/utils.dart';
import 'package:whatsappsaver/videolist.dart';
import 'package:whatsappsaver/videoplay.dart';
import 'imageview.dart';
import 'package:video_thumbnail/video_thumbnail.dart';



// ignore: must_be_immutable
class Downloads extends StatefulWidget {
  Downloads({Key key, this.title, @required this.whatsappType}) : super(key: key);
  Future userFuture;
  final String title;
  final WhatsAppType whatsappType;

  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {

  final key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getTemporaryDirectory().then((d) => _tempDir = d.path);
    getFilePath(widget.whatsappType);
    super.initState();
  }

  String _tempDir;
  
  Future getThumbnail(String str) async {
  final uint8list = await VideoThumbnail.thumbnailData(
  video: str,
  imageFormat: ImageFormat.JPEG,
  maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
  quality: 25,
  );
  return uint8list;
  }
  List<FileModel> videoList;
  


  // List<FileSystemEntity> videosList;
  List<FileSystemEntity> imagesList;
  bool loading = true;
  bool emptyState = false;

  Future<void> getFilePath(WhatsAppType whatsApp) async {
    await checkPermission();
    setState(() {
      loading = true;
    });

  Directory appDocDirectory = await getExternalStorageDirectory();
  String thepath2 = appDocDirectory.parent.parent.parent.parent.path.toString() + '/Whatsappsaver';
  Directory(thepath2).create().then((value) async =>{});
    var newDir = appDocDirectory.parent.parent.parent.parent.path.toString() + '/Whatsappsaver';
    var directory = Directory(newDir);

    try {
      List<dynamic> theFile1 = directory.listSync();
      theFile1.sort((a,b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
        List<FileModel> filelist = theFile1.map((data)=> FileModel(fileUrl:File(data.path), hold:false)).toList();
      if (theFile1.isNotEmpty) {
        // List<FileSystemEntity> videos =
        //     theFile1.where((f) => f.path.endsWith('.mp4')).toList();
        List<FileModel> videos =
            filelist.where((f) => f.fileUrl.path.endsWith('.mp4')).toList();

        List<FileSystemEntity> videos1 =
            theFile1.where((f) => f.path.endsWith('.gif')).toList();
        List<FileSystemEntity> jpgImage =
            theFile1.where((f) => f.path.endsWith('.jpg')).toList();
        List<FileSystemEntity> pngImage =
            theFile1.where((f) => f.path.endsWith('.png')).toList();
            //  List finalvideos1 = videos.map((e) =>               
            //   GenThumbnailImage(
            //     fileModel: e,
            //   thumbnailRequest: ThumbnailRequest(
                
            //   video: e.fileUrl.path,
            //   thumbnailPath: _tempDir,
            //   imageFormat: _format,
            //   maxHeight: _sizeH,
            //   maxWidth: _sizeW,
            //   timeMs: _timeMs,
            //   quality: _quality))
            //   ).toList();
                         
        setState(() {          
          //  finalvideos = finalvideos1;
          imagesList = jpgImage + pngImage;
          videoList = videos; // videos with videomodel
          loading = false;
        });
      } else {
        setState(() {
          emptyState = true;
          loading = false;
        });
      }
    } catch (e) {
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
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
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
                Tab(icon: Icon(LineIcons.video)),
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
                icon: Icon(LineIcons.questionCircle, color: Colors.white),
                onPressed: null,
              ),
            ],
            backgroundColor: Color.fromRGBO(14, 169, 14, 1),
          ),
          drawer: myDrawer(context),
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
                            child: 
                            GridView.count(
                            crossAxisCount: 2 ,
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
                            crossAxisCount: 2 ,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 0.8,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          children: List.generate(videoList.length, (index) {
                            return (videoList != null) ? 
                            GestureDetector(
                                  onTap: (){                                
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                          builder: (context) => 
                                          VideoItem(FileModel(fileUrl: videoList[index].fileUrl, hold: false)),
                                          ));
                                      },
                              child: 

Stack(
  children: [
    Positioned(child: 
    
    
                                  Container(
                                margin: EdgeInsets.all(10),
                                // height: 150,
                                // width: 150,                                
                                 child: FutureBuilder(
                                   initialData: Center(child: Text('Loading')),
                                   future: getThumbnail(videoList[index].fileUrl.path) ,
                                   builder: (context, snapshot){
                                   if(snapshot.hasData){
                                    return Container(
                                //        height: 150,
                                // width: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(snapshot.data),
                                    fit: BoxFit.cover
                                    ),
                                    borderRadius: BorderRadius.circular(10)
                                  
                                ),
                                    );
                                   }else{
                                     return Text('No data');
                                   }
                                 },),
                                // child: finalvideos[index],
                              ),
                            ),

                            Positioned(
                              top: 65,
                              right: 65,
                              child: Icon(Icons.play_arrow, size: 45, color: Colors.black,))
  ],
))


                             : Text('Loading...')
                             ;
                          }),
                        )
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


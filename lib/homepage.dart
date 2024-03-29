import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsappsaver/drawer.dart';
import 'package:whatsappsaver/main.dart';
import 'package:whatsappsaver/models/model.dart';
import 'package:whatsappsaver/provider/provider.dart';
import 'package:whatsappsaver/utils.dart';
import 'package:whatsappsaver/videoplay.dart';
import 'imageview.dart';
import 'package:video_thumbnail/video_thumbnail.dart';



// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.whatsappType}) : super(key: key);
  Future userFuture;
  final String title;
  final WhatsAppType whatsappType;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getTemporaryDirectory().then((d) => _tempDir = d.path);
    getFilePath(widget.whatsappType);
    super.initState();
  }


Future getThumbnail(String str) async {
  final uint8list = await VideoThumbnail.thumbnailData(
  video: str,
  imageFormat: ImageFormat.JPEG,
  maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
  quality: 25,
  );
  return uint8list;
  }
  String _tempDir;
  
  List<FileModel> imagesList;
  List<FileModel> videoList;
  bool loading = true;
  bool emptyState = false;

  Future<void> getFilePath(WhatsAppType whatsApp) async {
    await checkPermission();
    setState(() {
      loading = true;
    });
    var newDir = '/storage/emulated//0/${whatAppType(whatsApp)}/Media/.Statuses';
    var directory = Directory(newDir);

    try {
      List<FileSystemEntity> theFile1 = directory.listSync();
      theFile1.sort((a,b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
       List<FileModel> filelist = theFile1.map((data)=> FileModel(fileUrl:File(data.path), hold:false)).toList();
      
      if (theFile1.isNotEmpty) {
        List<FileModel> videos =
            filelist.where((f) => f.fileUrl.path.endsWith('.mp4')).toList();
        List<FileSystemEntity> videos1 =
            theFile1.where((f) => f.path.endsWith('.gif')).toList();
        List<FileModel> jpgImage =
            filelist.where((f) => f.fileUrl.path.endsWith('.jpg')).toList();
        List<FileModel> pngImage =
            filelist.where((f) => f.fileUrl.path.endsWith('.png')).toList();

        var imageList = jpgImage + pngImage;        
        getIt<SaverProvider>().updateImage(imageList, 'image');  
        getIt<SaverProvider>().updateImage(videos, 'video');  
                         
        setState(() {     
          videoList = videos;   
          //  finalvideos = finalvideos1;
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
    SaverProvider saverProvider = Provider.of<SaverProvider>(context);
    return DefaultTabController(
      length: 2,
      child: MaterialApp(
        home: Scaffold(
          key: key,
          backgroundColor: Colors.white,
          appBar: saverProvider.imagefilesSaved.isEmpty?
           AppBar(
            bottom: TabBar(
              
              onTap: (index) {
                print(index);
                print('yayaya');
              },
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
          ):
           AppBar(
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
            //title: Text(widget.title, style: GoogleFonts.montserrat()),
            actions: [
              IconButton(
                icon: Icon(LineIcons.borderAll, color: Colors.white),
                onPressed: (){
                  saverProvider.highlightAll('image');
                },
              ),
              IconButton(
                icon: Icon(LineIcons.save, color: Colors.white),
                onPressed: (){
                  saverProvider.saveFiles('image');
                },
              ),
              IconButton(
                icon: Icon(LineIcons.share, color: Colors.white),
                onPressed: (){
                  saverProvider.shareFiles('image');
                },
              ),
              IconButton(
                icon: Icon(LineIcons.trash, color: Colors.white),
                 onPressed: (){
                  saverProvider.deleteFiles('image');
                },
              ),
            ],
            backgroundColor: Color.fromRGBO(14, 169, 14, 1),
          )
          ,
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
                            children: List.generate(saverProvider.fileModelImageList.length, (index) {
                              return _ImageItem(saverProvider.fileModelImageList[index]);
                            }),
                          ),
                      ),
              loading
                  ? Center(child: CircularProgressIndicator())
                  : emptyState
                      ? _EmptyView():
                      RefreshIndicator(
                        onRefresh: () async {
                              
                              getFilePath(WhatsAppType.WhatsApp);
                            },
                      child: GridView.count(                               
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
                              onLongPress: (){
                                saverProvider.removeImageFilesToSave();
                                setState(() {
                                videoList[index].hold = !videoList[index].hold;                                  
                                });
                                
                              },
                                  onTap: (){  
                                    
                                    if(videoList.any((element) => element.hold == true)){
                                      setState(() {
                                      videoList[index].hold = !videoList[index].hold;                                     
                                    });
                                    }else{
                                       setState(() {
                                        videoList[index].hold = false;                                  
                                        });
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                          builder: (context) => 
                                          VideoItem(FileModel(fileUrl: videoList[index].fileUrl, hold: false)),
                                          ));
                                    }

                                      },
                              child: 

Stack(
  children: [
    Positioned(child:       Container(
                                margin: EdgeInsets.all(10),
                                
                                 child: FutureBuilder(
                                   initialData: Center(child: Text('Loading')),
                                   future: getThumbnail(videoList[index].fileUrl.path) ,
                                   builder: (context, snapshot){
                                   if(snapshot.hasData){
                                    return Container(
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
                              child: Icon(Icons.play_arrow, size: 45, color: Colors.black,)),
                              videoList[index].hold ?
                              Positioned(child: Container(
                                //height: 150,
                                color: Color.fromRGBO(124,252,0,.4),
                              )): SizedBox()
  ],
))


                             : Text('Loading...')
                             ;
                          }),
                        )
                        ,)
                      
            ],
          ),
        ),
      ),
    );
  }
}


class _ImageItem extends StatefulWidget {
  final FileModel fileModel;
  _ImageItem(this.fileModel);

  @override
  __ImageItemState createState() => __ImageItemState();
}


saveData(SaverProvider saverProvider, FileModel file)async { // add data to file to be saved   
  List<FileModel> file1 = saverProvider.imagefilesSaved;  
  file1.add(file);
  getIt<SaverProvider>().updateimagefilesSaved(file1, 'image'); 
  print(saverProvider.imagefilesSaved);
}

removeData(SaverProvider saverProvider, FileModel file)async { //remove data from file to be saved   
  List<FileModel> file1 = saverProvider.imagefilesSaved;  
  file1.remove(file);
   getIt<SaverProvider>().updateimagefilesSaved(file1, 'image'); 
  print(saverProvider.imagefilesSaved);  
}

class __ImageItemState extends State<_ImageItem> {
  bool pressed = false;

  @override
  void dispose() {
    getIt<SaverProvider>().updateimagefilesSaved([], 'image');
    super.dispose();
    }
    
  @override
  Widget build(BuildContext context) {
    SaverProvider saverProvider = Provider.of<SaverProvider>(context);
    return GestureDetector(
      onLongPress:() async {        
        if(widget.fileModel.hold == false){
          await saveData(saverProvider, widget.fileModel);
        setState(() {
          widget.fileModel.hold = true ;
        });
        }else{
          await removeData(saverProvider, widget.fileModel);
        setState(() {
          widget.fileModel.hold = false ;
        });
        }
      },
      onTap: () async {
      if(saverProvider.imagefilesSaved.isEmpty == true){
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImageViewer(
                File(widget.fileModel.fileUrl.path),
              ),
            ),
          );
      }else{
        if(widget.fileModel.hold == false){
          await saveData(saverProvider, widget.fileModel);
        setState(() {
          widget.fileModel.hold = true ;
        });
        }else{
          await removeData(saverProvider, widget.fileModel);
        setState(() {
          widget.fileModel.hold = false ;
        });
        }
      }
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Stack(
          children: <Widget>[
            Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  File(widget.fileModel.fileUrl.path),
                ),
              ),
              borderRadius: BorderRadius.circular(10)),
        ),
        widget.fileModel.hold ?
            Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(124,252,0,.4),
              borderRadius: BorderRadius.circular(10)),
        ): SizedBox(),
        // Text('Hello worlddd')
          ]
        )
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


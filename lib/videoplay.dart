import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:whatsappsaver/drawer.dart';
import 'package:whatsappsaver/models/model.dart';

class VideoItem extends StatefulWidget {
  
  final FileModel fileModel;
  VideoItem(this.fileModel);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  checkPermission() async {
    var storageStatus = await Permission.storage.status;
    if (storageStatus != true){
      await Permission.storage.request() ;
    }
  }

   void showToast(themsg) {
    Fluttertoast.showToast(
        msg: themsg,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Color.fromRGBO(14, 169, 14, 1),
        textColor: Colors.white);
  }
  @override
  void initState(){     
_controller = ChewieController(
              autoPlay: true,
              fullScreenByDefault: false,
              autoInitialize: true,
              errorBuilder: (context, errorMessage) => Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              videoPlayerController: VideoPlayerController.file(
                File(
                  '/${widget.fileModel.fileUrl.path}',
                ),
              ),
              showControls: true,
              // aspectRatio: 16 / 9,
            );

    super.initState();
  }
ChewieController _controller;

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Video', style: GoogleFonts.montserrat()),
          actions: [
            // IconButton(
            //   icon: Icon(LineIcons.share, color: Colors.white),
            //   onPressed: null,
            // ),
            // IconButton(
            //   icon: Icon(LineIcons.question_circle, color: Colors.white),
            //   onPressed: null,
            // ),
          ],
          backgroundColor: Color.fromRGBO(14, 169, 14, 1),
        ),
        drawer: myDrawer(context),
        body: Center(
          child: Chewie(
            controller: _controller
          ),
        ),
              floatingActionButton: FloatingActionButton(
        onPressed: () {
           showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: new Icon(Icons.save_alt_rounded),
                            title: new Text('Save'),
                            onTap: () async {
                              await checkPermission();
                              Directory appDocDirectory = await getExternalStorageDirectory();
                              String thepath2 = appDocDirectory.parent.parent.parent.parent.path.toString() + '/Whatsappsaver';
                              String video = this.widget.fileModel.fileUrl.path;      
                              File videofile = File(this.widget.fileModel.fileUrl.path);  
                              int indexname = video.indexOf('.Statuses/');
                              String name = video.substring(indexname+10);
                              String finalname='';
                              Directory(thepath2).create().then((value) async =>                               
                              {
                                 finalname = thepath2 +'/'+ name,
                                await videofile.copy('$thepath2/$name.mp4'),
                                
                              }
                              );
                              Navigator.pop(context);
                              showToast('Saved!');
                            },
                          ),
                          ListTile(
                            leading: new Icon(Icons.share),
                            title: new Text('Share'),
                            onTap: () {                                  
                              File videofile = File(this.widget.fileModel.fileUrl.path); 
                              Share.shareFiles([videofile.path.toString()], text: '');
                              Navigator.pop(context);
                            },
                          ),
                          // ListTile(
                          //   leading: new Icon(Icons.send_rounded),
                          //   title: new Text('Repost'),
                          //   onTap: () async {
                          //     File videofile = File(this.widget.videoPath); 
                          //     List<int> imageBytes = await videofile.readAsBytes();
                          //     String base64Image = base64Encode(imageBytes);
                          //     print(imageBytes);
                          //     await FlutterShareMe().shareToWhatsApp(base64Image: base64Image);
                              
                          //     Navigator.pop(context);
                          //   },
                          // ),
                          ListTile(
                            leading: new Icon(Icons.delete_forever_outlined),
                            title: new Text('Delete'),
                            onTap: () {                                  
                                  File videofile = File(this.widget.fileModel.fileUrl.path); 
                                  videofile.delete();
                                  showToast('Deleted!');
                                  Navigator.pop(context);
                            },
                          ),

                        ],
                      );
                    });

        },
        child: const Icon(Icons.add),
        backgroundColor: Color.fromRGBO(14, 169, 14, 1),
      ),

      ),
    );
  }
}

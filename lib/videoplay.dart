import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:whatsappsave/main.dart';

class VideoItem extends StatelessWidget {
  final String videoPath;
  VideoItem(this.videoPath);

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
        backgroundColor: Colors.green,
        textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Video', style: GoogleFonts.montserrat()),
          // actions: [
          //   IconButton(
          //     icon: Icon(LineIcons.share, color: Colors.white),
          //     onPressed: null,
          //   ),
          //   IconButton(
          //     icon: Icon(LineIcons.question_circle, color: Colors.white),
          //     onPressed: null,
          //   ),
          // ],
          backgroundColor: Color.fromRGBO(18, 140, 126, 1),
        ),
        drawer: Drawer(),
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(
              controller: ChewieController(
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
                    '/$videoPath',
                  ),
                ),
                showControls: true,
                aspectRatio: 16 / 9,
              ),
            ),
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
                              String thepath2 = appDocDirectory.parent.parent.parent.parent.path.toString() + '/Whatsappsave';
                              String video = this.videoPath;      
                              File videofile = File(this.videoPath);  
                              int indexname = video.indexOf('.Statuses/');
                              String name = video.substring(indexname+10);
                              String finalname='';
                              Directory(thepath2).create().then((value) async =>                               
                              {
                                 finalname = thepath2 +'/'+ name,
                                await videofile.copy('$thepath2/$name.mp4'),
                                print(finalname)
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
                              File videofile = File(this.videoPath); 
                              Share.shareFiles([videofile.path.toString()], text: '');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: new Icon(Icons.send_rounded),
                            title: new Text('Repost'),
                            onTap: () async {
                              File videofile = File(this.videoPath); 
                              List<int> imageBytes = await videofile.readAsBytes();
                              String base64Image = base64Encode(imageBytes);
                              print(imageBytes);
                              await FlutterShareMe().shareToWhatsApp(base64Image: base64Image);
                              
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: new Icon(Icons.delete_forever_outlined),
                            title: new Text('Delete'),
                            onTap: () {                                  
                                  File videofile = File(this.videoPath); 
                                  videofile.delete();
                                  showToast('Deleted!');
                                  Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                  builder: (context) => MyHomePage(title:'WhatsApp Status Saver'),
                                  ));
                            },
                          ),

                        ],
                      );
                    });

        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),

      ),
    );
  }
}

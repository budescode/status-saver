import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';



class ImageViewer extends StatefulWidget {
  final File image;
  ImageViewer(this.image);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with SingleTickerProviderStateMixin {
  Animation<double> _animation;

  AnimationController _animationController;

  @override
  void initState(){       
 
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

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
  List<FileSystemEntity> videosList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: 
      Center(
        child: Hero(
          tag: widget.image.path,
          child: Image.file(widget.image, fit: BoxFit.cover),
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
                              int indexname = widget.image.toString().indexOf('.Statuses/');
                              String name = widget.image.toString().substring(indexname+10);
                              String finalname='';
                              Directory(thepath2).create().then((value) async =>                               
                              {
                                 finalname = thepath2 +'/'+ name,
                                await widget.image.copy('$thepath2/$name.jpg'),
                                
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
                              Share.shareFiles([widget.image.path.toString()], text: '');
                              Navigator.pop(context);
                            },
                          ),
                          // ListTile(
                          //   leading: new Icon(Icons.send_rounded),
                          //   title: new Text('Repost'),
                          //   onTap: () async {
                          //     List<int> imageBytes = await widget.image.readAsBytes();
                          //     String base64Image = base64Encode(imageBytes);
                          //     print(imageBytes);
                          //     FlutterShareMe().shareToWhatsApp(base64Image: base64Image);
                              
                          //     // Navigator.pop(context);
                          //   },
                          // ),
                          ListTile(
                            leading: new Icon(Icons.delete_forever_outlined),
                            title: new Text('Delete'),
                            onTap: () {
                                  widget.image.delete();
                                  showToast('Deleted!');
                                  Navigator.pop(context);
                                  // Navigator.pushReplacement(
                                  // context,
                                  // MaterialPageRoute(
                                  // builder: (context) => MyHomePage(title:'WhatsApp Status Saver'),
                                  // ));
                            },
                          ),

                        ],
                      );
                    });

        },
        child: const Icon(Icons.add),
        backgroundColor: Color.fromRGBO(14, 169, 14, 1),
      ),


    );
  }
}

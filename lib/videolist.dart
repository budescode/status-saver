import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsappsaver/main.dart';
import 'package:whatsappsaver/models/model.dart';
import 'package:whatsappsaver/provider/provider.dart';
import 'package:whatsappsaver/videoplay.dart';


class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {this.video,
      this.thumbnailPath,
      this.imageFormat,
      this.maxHeight,
      this.maxWidth,
      this.timeMs,
      this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;
  const ThumbnailResult({this.image, this.dataSize, this.height, this.width});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Uint8List bytes;
  final Completer<ThumbnailResult> completer = Completer();
  if (r.thumbnailPath != null) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: r.video,
        thumbnailPath: r.thumbnailPath,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);

    // print("thumbnail file is located: $thumbnailPath");

    final file = File(thumbnailPath);
    bytes = file.readAsBytesSync();
  } else {
    bytes = await VideoThumbnail.thumbnailData(
        video: r.video,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);
  }

  int _imageDataSize = bytes.length;
  // print("image size: $_imageDataSize");

  final _image = Image.memory(bytes);
  _image.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
    ));
  }));
  return completer.future;
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;
  final FileModel fileModel;

  const GenThumbnailImage({Key key, this.thumbnailRequest, this.fileModel}) : super(key: key);

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  
  @override
  void dispose() {
    getIt<SaverProvider>().updateimagefilesSaved([], 'image');
    super.dispose();
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
  
  @override
  Widget build(BuildContext context) {
    SaverProvider saverProvider = Provider.of<SaverProvider>(context);
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
         
          final _image = snapshot.data.image;

          final _width = snapshot.data.width;
          final _height = snapshot.data.height;
          final _dataSize = snapshot.data.dataSize;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: [
                Positioned(
                child: Stack(children: <Widget>[
                  GestureDetector(
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
              builder: (_) => VideoItem(widget.fileModel),
            ),
          );
      }else{
        if(widget.fileModel.hold == false){
          //await saveData(saverProvider, widget.fileModel);
        setState(() {
          widget.fileModel.hold = true ;
        });
        }else{
         // await removeData(saverProvider, widget.fileModel);
        setState(() {
          widget.fileModel.hold = false ;
        });
        }
      }
      },
                              // onTap: (){                                
                              //     Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //     builder: (context) => 
                              //     VideoItem(saverProvider.fileModelVideoList[index]),
                              //     ));
                              // },
                    child: _image
                  ),

               widget.fileModel.hold ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Color.fromRGBO(124,252,0,.4)
                  ): SizedBox(),
                  
                ],),
                ),
                  Positioned(
                left: MediaQuery.of(context).size.width/5,
                top: MediaQuery.of(context).size.height/12,
                child: Icon(Icons.play_arrow_rounded, size: 60, color: Colors.white),
                )
                ],
              ),
              
            ],
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.red,
            child: Text(
              "Error:\n${snapshot.error.toString()}",
            ),
          );
        } else {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    "loading..."),
                SizedBox(
                  height: 10.0,
                ),
                CircularProgressIndicator(),
              ]);
        }
      },
    );
  }
}

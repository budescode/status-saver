

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:whatsappsaver/models/model.dart';


class SaverProvider with ChangeNotifier {

List<FileModel> fileModelImageList;
List<FileModel> imagefilesSaved = []; //list of files to be saved
List<FileModel> fileModelVideoList;
List<FileModel> videofilesSaved = []; //list of files to be saved
String selected; //video or image selected

checkPermission() async {
  var storageStatus = await Permission.storage.status;
  if (storageStatus != true){
    await Permission.storage.request() ;
  }
}
  
bool allImageHighlight = false; //to check if all files are highlighted or not
bool allVideoHighlight = false; //to check if all files are highlighted or not

void showToast(themsg) {
Fluttertoast.showToast(
      msg: themsg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

updateimagefilesSaved(List<FileModel> fileList, String datatype){
  if(datatype=='image'){
  imagefilesSaved = fileList;
  notifyListeners();
  } else{
    videofilesSaved = fileList;
    notifyListeners();
  }
}

updateImage(List<FileModel> fileList, String datatype){
  if(datatype=='image'){
  fileModelImageList = fileList;
  notifyListeners();
  } else{
    fileModelVideoList = fileList;
    notifyListeners();
  }
}

  highlightAll(String datatype){    
    if(datatype=='image'){
    allImageHighlight = !allImageHighlight;
    notifyListeners();
    for(var i=0; i<fileModelImageList.length; i++){
      fileModelImageList[i].hold = allImageHighlight;
      notifyListeners();      
    }
    if(allImageHighlight == true){
    imagefilesSaved=fileModelImageList;
    notifyListeners();
    }else{
      imagefilesSaved=[];
      notifyListeners();
    }
    } else{
        
      allVideoHighlight = !allVideoHighlight;
      notifyListeners();
      for(var i=0; i<fileModelImageList.length; i++){
      fileModelImageList[i].hold = allVideoHighlight;
      notifyListeners();      
      }
      if(allVideoHighlight == true){
      imagefilesSaved=fileModelImageList;
      notifyListeners();
      }else{
      imagefilesSaved=[];
      notifyListeners();
      } 

    }

  }


  deleteFiles(String datatype) async{
    await checkPermission();
    if (datatype == 'image'){
    for(var i=0; i<imagefilesSaved.length; i++){
      File newfile = File(imagefilesSaved[i].fileUrl.path);
      imagefilesSaved[i].hold=false;
      // imagefilesSaved.removeAt(i);
      fileModelImageList.removeWhere((element) => element.fileUrl == imagefilesSaved[i].fileUrl);
      newfile.delete();
      
      }
      imagefilesSaved = [];
      notifyListeners();
    } else{
          for(var i=0; i<videofilesSaved.length; i++){
      File newfile = File(videofilesSaved[i].fileUrl.path);
      videofilesSaved[i].hold=false;
      // videofilesSaved.removeAt(i);
      fileModelVideoList.removeWhere((element) => element.fileUrl == videofilesSaved[i].fileUrl);
      newfile.delete();
      notifyListeners();
      }
      videofilesSaved = [];
      notifyListeners();
    }
      


      showToast('Deleted!');
  }
  saveFiles(String datatype) async{
      await checkPermission();
      if(datatype == 'image'){
        
      for(int i=0; i<imagefilesSaved.length; i++){
      Directory appDocDirectory = await getExternalStorageDirectory();
      String thepath2 = appDocDirectory.parent.parent.parent.parent.path.toString() + '/Whatsappsaver';
      int indexname = imagefilesSaved[i].fileUrl.toString().indexOf('.Statuses/');
      String name = imagefilesSaved[i].fileUrl.toString().substring(indexname+10);
      String finalname='';
      File newfile = File(imagefilesSaved[i].fileUrl.path);
      
      await Directory(thepath2).create().then((value) async =>                               
      {
          finalname = thepath2 +'/'+ name,          
        await newfile.copy('$thepath2/$name.jpg'),
        
      });
      imagefilesSaved[i].hold = false;
     
      }
      imagefilesSaved = [];
      notifyListeners();
      } else{
              for(var i=0; i<videofilesSaved.length; i++){
      Directory appDocDirectory = await getExternalStorageDirectory();
      String thepath2 = appDocDirectory.parent.parent.parent.parent.path.toString() + '/Whatsappsaver';
      int indexname = videofilesSaved[i].fileUrl.toString().indexOf('.Statuses/');
      String name = videofilesSaved[i].fileUrl.toString().substring(indexname+10);
      String finalname='';
      File newfile = File(videofilesSaved[i].fileUrl.path);
      Directory(thepath2).create().then((value) async =>                               
      {
          finalname = thepath2 +'/'+ name,          
        await newfile.copy('$thepath2/$name.jpg'),
        
      });
      videofilesSaved[i].hold = false;
      
      }
      videofilesSaved = [];
      notifyListeners();
      }
      
      showToast('Saved!');
  }

  shareFiles(String datatype){
    if (datatype == 'image'){
    List files = imagefilesSaved.map((e) => e.fileUrl.path.toString()).toList();
    Share.shareFiles(files, text: '');
    } else{
        List files = videofilesSaved.map((e) => e.fileUrl.path.toString()).toList();
        Share.shareFiles(files, text: '');
    }

  }
}

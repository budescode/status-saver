import 'package:flutter/material.dart';
import 'package:whatsappsaver/downloads.dart';
import 'package:whatsappsaver/homepage.dart';
import 'package:package_info/package_info.dart';
import 'package:whatsappsaver/utils.dart';

Color thecolor = Color.fromRGBO(14, 169, 14, 1);
String version = '';

getData() async {
PackageInfo packageInfo = await PackageInfo.fromPlatform();
version = packageInfo.version.toString();

}
Widget myDrawer(BuildContext context){
  getData();
  return Drawer(            
 child: ListView(
    padding: EdgeInsets.zero,
   children: [
      DrawerHeader(
        padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: thecolor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Image.asset(
                     'assets/images/logo.png',
                     height: 70,
                   ),
                  Text('Whatsapp Save'),
                  Text('$version'),
                ],
              ),
      ),
      Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child: Column(
  children: [
        ListTile(
        leading: Icon(Icons.download_done_outlined, color: Colors.white,),
        title: Text('Downloads', style: TextStyle(color: Colors.white,)),
        onTap: () {
             Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => 
            Downloads(title: 'Downloads',whatsappType: WhatsAppType.OfficialWhatsApp)
            ));
          
        },
        ),

        ListTile(
        leading: Icon(Icons.star, color: Colors.white,),
        title: Text('Statuses', style: TextStyle(color: Colors.white,)),
        onTap: () {          
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => 
            MyHomePage(title: 'WhatsApp Status Saver',  whatsappType: WhatsAppType.OfficialWhatsApp,)
            ));
          
        },
        ),
        ListTile(
        leading: Icon(Icons.star, color: Colors.white,),
        title: Text('Business Whatsapp', style: TextStyle(color: Colors.white,)),
        onTap: () {          
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => 
            MyHomePage(title: 'Business WhatsApp Status Saver',  whatsappType: WhatsAppType.BusinessWhatsApp,)
            ));
          
        },
        ),
        ListTile(
        leading: Icon(Icons.star, color: Colors.white,),
        title: Text('GB Whatsapp', style: TextStyle(color: Colors.white,)),
        onTap: () {          
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => 
            MyHomePage(title: 'GB WhatsApp Status Saver',  whatsappType: WhatsAppType.GBWhatsApp,)
            ));
          
        },
        ),

        Divider(color:Colors.white)

],
        ),
      )

   ],
 )
        
  );
}
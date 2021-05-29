import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:whatsappsaver/homepage.dart';
import 'package:whatsappsaver/provider/provider.dart';
import 'package:whatsappsaver/utils.dart';
import 'package:get_it/get_it.dart';
GetIt getIt = GetIt.instance;
void main() {
  getIt.registerLazySingleton<SaverProvider>(() => SaverProvider());
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SaverProvider>(create: (context) => getIt<SaverProvider>()),
      ],
       child: MaterialApp(
        title: 'WhatsApp Status Saver',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.montserratAlternatesTextTheme()
        ),
        home: MyHomePage(title: 'WhatsApp Status Saver',  whatsappType: WhatsAppType.OfficialWhatsApp,),
      ),
    );
  }
}

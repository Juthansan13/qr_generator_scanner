
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr12/home_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner and Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(brightness: Brightness.light,
        seedColor: Colors.indigo
        ),
      ),
      home: const MyHomePage(),
      
     
    );
  }
}

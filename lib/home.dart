

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr12/qr_generator.dart';
import 'package:qr12/qr_scanner.dart';


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo, 
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(24),
                child: Text("QR Code Pro",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold
                        ),
                        ),
              ),
              SizedBox(height: 50),
              Center(
                child: Container(
                 padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildFeatureButton(
                        context,
                        "Generate QR Code",
                        Icons.qr_code,
                        () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:(context) => const QrGeneratorScreen()))), 
                      SizedBox(height: 20),
                      _buildFeatureButton(
                        context,
                        "Sacn QR Code",
                        Icons.qr_code_scanner,
                        () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:(context) => const QrScannerScreen()))), 
                              
                        
                     
                    ],
                  ), 
                ),
              ),
            ],
          ),
          ),
          );
  }
  Widget _buildFeatureButton(BuildContext context,String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 90,
            ),
            //SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        )
      ),
    );
  }
}

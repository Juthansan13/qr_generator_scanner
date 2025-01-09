import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String qrData = "";
  String selectedType = "text";
  final Map<String, TextEditingController> _controller = {
    "name": TextEditingController(),
    "email": TextEditingController(),
    "phone": TextEditingController(),
    "text": TextEditingController(),
    "url": TextEditingController(),
  };

  String _generatorQRDate() {
    switch (selectedType) {
      case "contact":
        return '''BEGIN:VCARD
        VERSION:3.0
        FN:${_controller["name"]?.text}
        EMAIL:${_controller["email"]?.text}
        TEL:${_controller["phone"]?.text}
        END:VCARD''';

      case "url":
        String url = _controller["url"]?.text ?? "";
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
          url = "http://$url";
        }
        return url;

      default:
        return _textController.text;
    }
  }

  Future<void> _shareQrCode() async {
    final directory = await getApplicationCacheDirectory();
    final imagePath = '${directory.path}/qr_code.png';
    final capture = await _screenshotController.capture();
    if (capture == null) return;

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    await Share.shareXFiles([XFile(imagePath)], text: "Share QR Code");
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (_) {
          setState(() {
            qrData = _generatorQRDate();
          });
        },
      ),
    );
  }

  Widget _buildInputFields() {
    switch (selectedType) {
      case "contact":
        return Column(
          children: [
            _buildTextField(_controller["name"]!, "Name"),
            _buildTextField(_controller["email"]!, "Email"),
            _buildTextField(_controller["phone"]!, "Phone"),
          ],
        );
      case "url":
        return _buildTextField(_controller["url"]!, "URL");
      default:
        return TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: "Enter Text",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              qrData = value;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          "QR Code Generator",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        selected: {selectedType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            selectedType = selection.first;
                            qrData = '';
                          });
                        },
                        segments: const [
                          ButtonSegment(
                            value: 'text',
                            label: Text('Text'),
                            icon: Icon(Icons.text_fields),
                          ),
                          ButtonSegment(
                            value: 'url',
                            label: Text('URL'),
                            icon: Icon(Icons.link),
                          ),
                          ButtonSegment(
                            value: 'contact',
                            label: Text('Cont'),
                            icon: Icon(Icons.contact_page),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInputFields(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (qrData.isNotEmpty)
                Column(
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Screenshot(
                              controller: _screenshotController,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _shareQrCode,
                      icon: const Icon(Icons.share),
                      label: const Text("Share QR Code"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

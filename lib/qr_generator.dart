import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String qrData = "";
  String selectedType = "";
  final Map<String, TextEditingController> _controller = {
    "email": TextEditingController(),
    "contacts": TextEditingController(),
    "phone": TextEditingController(),
    "url": TextEditingController(),
    "message": TextEditingController(),
    "wifi": TextEditingController(),
    "clipboard": TextEditingController(),
    "location": TextEditingController(),
    "wallet": TextEditingController(),
    "amount": TextEditingController(),
    "eventTitle": TextEditingController(),
    "startDate": TextEditingController(),
    "endDate": TextEditingController(),
  };
  File? imageFile;
  File? file;

  String _generateQRData() {
    switch (selectedType) {
      case "email":
        return "mailto:${_controller["email"]?.text}";
      case "contacts":
        return "BEGIN:VCARD\nFN:${_controller["contacts"]?.text}\nTEL:${_controller["phone"]?.text}\nEMAIL:${_controller["email"]?.text}\nEND:VCARD";
     case "phone":
        return "tel:${_controller["phone"]?.text}";
      case "url":
        return _controller["url"]?.text ?? "";
      case "message":
        return "sms:${_controller["message"]?.text}";
      case "wifi":
        return "WIFI:T:WPA;S:${_controller["wifi"]?.text};;";
      case "clipboard":
        return _controller["clipboard"]?.text ?? "";
      case "location":
        return "geo:${_controller["location"]?.text}";
      case "image":
        return imageFile != null
            ? "file://${imageFile!.path}"
            : "No Image Selected";

      case "file":
        return file != null ? "file://${file!.path}" : "";
      case "bitcoin":
        return "bitcoin:${_controller["wallet"]?.text}?amount=${_controller["amount"]?.text}";
      case "event":
        return "BEGIN:VEVENT\nSUMMARY:${_controller["eventTitle"]?.text}\nDTSTART:${_controller["startDate"]?.text}\nDTEND:${_controller["endDate"]?.text}\nLOCATION:${_controller["eventLocation"]?.text}\nEND:VEVENT";
      case "twitter":
      default:
        return "";
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

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

/*
  Future<void> _downloadQrCode() async {
    final directory = await getExternalStorageDirectory();
    final imagePath = '${directory?.path}/qr_code.png';
    final capture = await _screenshotController.capture();
    if (capture == null) return;

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('QR Code downloaded!')));
  }
  */
  Future<void> _downloadQrCode() async {
    // Request storage permission
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Storage permission is required to download QR Code')),
      );
      return;
    }

    try {
      // Get the directory for storing the file
      final directory = await getApplicationDocumentsDirectory();

      // Create the file path for saving the QR code
      final imagePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';

      // Capture the QR code
      final capture = await _screenshotController.capture();
      if (capture == null) {
        throw Exception("Failed to capture QR Code");
      }

      // Save the file
      final file = File(imagePath);
      await file.writeAsBytes(capture);

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code downloaded to: $imagePath')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading QR Code: $e')),
      );
    }
  }

  Widget _buildInputField(String type, String label) {
    return TextField(
      controller: _controller[type],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        setState(() {
          qrData = _generateQRData();
        });
      },
    );
  }

  Widget _buildContent() {
    switch (selectedType) {
      case "email":
        return _buildInputField("email", "Enter Email Address");

      case "phone":
        return _buildInputField("phone", "Enter Phone Number");

      case "url":
        return _buildInputField("url", "Enter Website URL");

      case "message":
        return _buildInputField("message", "Enter Message");

      case "wifi":
        return _buildInputField("wifi", "Enter WiFi Network Name");

      case "clipboard":
        return _buildInputField("clipboard", "Enter Clipboard URL");

      case "location":
        return _buildInputField(
            "location", "Enter Location Coordinates (lat,long)");

      case "bitcoin":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("wallet", "Enter Bitcoin Wallet Address"),
            const SizedBox(height: 8),
            _buildInputField("amount", "Enter Amount (BTC)"),
          ],
        );

      case "event":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("eventTitle", "Enter Event Title"),
            const SizedBox(height: 8),
            _buildInputField("startDate", "Enter Start Date (YYYYMMDD)"),
            const SizedBox(height: 8),
            _buildInputField("endDate", "Enter End Date (YYYYMMDD)"),
          ],
        );

      case "contacts":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("contacts", "Enter Contact Name"),
            const SizedBox(height: 8),
            _buildInputField("phone", "Enter Phone Number"),
            const SizedBox(height: 8),
            _buildInputField("email", "Enter Email Address"),
          ],
        );

      case "image":
        return Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (imageFile != null) Text("Selected Image: ${imageFile!.path}"),
          ],
        );

      case "file":
        return Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Pick File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (file != null) Text("Selected File: ${file!.path}"),
          ],
        );

      default:
        return const Text(
          "Select a type to generate QR code.",
          style: TextStyle(fontSize: 16),
        );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path); // Assign the selected file
          qrData = _generateQRData(); // Update QR data
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
        qrData = _generateQRData();
      });
    }
  }

  Widget _buildGridItem(String type, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
          qrData = _generateQRData();
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor:
                selectedType == type ? Colors.indigo : Colors.grey[200],
            child: Icon(icon,
                color: selectedType == type ? Colors.white : Colors.indigo,
                size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          "Generate",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _buildGridItem("email", Icons.email, "Email"),
                  _buildGridItem("contacts", Icons.contacts, "Contacts"),
                  _buildGridItem("phone", Icons.phone, "Phone Number"),
                  _buildGridItem("url", Icons.link, "Website URL"),
                  _buildGridItem("message", Icons.message, "Message"),
                  _buildGridItem("wifi", Icons.wifi, "WiFi"),
                  _buildGridItem(
                      "clipboard", Icons.content_copy, "Clipboard URL"),
                  _buildGridItem("location", Icons.location_on, "Location"),
                  _buildGridItem("image", Icons.image, "Image"),
                  _buildGridItem("file", Icons.file_copy, "File"),
                  _buildGridItem("bitcoin", Icons.monetization_on, "Bitcoin"),
                  _buildGridItem("event", Icons.event, "Event"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 16),
            if (qrData.isNotEmpty)
              Column(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 150.0,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _downloadQrCode,
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        label: const Text("Download"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton.icon(
                        onPressed: _shareQrCode,
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text("Share QR Code"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

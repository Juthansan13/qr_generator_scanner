import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool hasPermission = false;
  bool isFlashOn = false;
  late MobileScannerController scannerController;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController();
    _checkPermission();
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

 Future<void> _processScannedData(String? data) async {
  if (data == null) return;

  scannerController.stop(); // Pause the scanner after detecting data

  String type = 'text'; // Default to text
  if (data.startsWith('BEGIN:VCARD')) {
    type = 'contact'; // Detect vCard
  } else if (data.startsWith('http://') || data.startsWith('https://')) {
      type = 'url'; // Detect URLs
    } else if (data.startsWith('www.')) {
    type = 'url'; // Detect URLs starting with "www."
    data = 'https://$data'; // Prepend "https://" to make it a valid URL
  } else if (data.startsWith('tel:') || RegExp(r'^\+?[0-9\s-]+$').hasMatch(data)) {
    type = 'phone'; // Detect phone numbers
  } else if (data.startsWith('mailto:') || data.contains('@')) {
    type = 'email'; // Detect emails
  }

  _showBottomSheet(data, type);


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Scanned Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text(
              "Type: ${type.toUpperCase()}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      data!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 24),
                    if (type == 'url')
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(data!),
                        icon: Icon(Icons.open_in_new),
                        label: Text('Open URL'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                        ),
                      ),
                    if (type == 'phone')
                      ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(data!),
                        icon: Icon(Icons.phone),
                        label: Text('Call Number'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                        ),
                      ),
                    if (type == 'email')
                      ElevatedButton.icon(
                        onPressed: () => _sendEmail(data!),
                        icon: Icon(Icons.email),
                        label: Text('Send Email'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                        ),
                      ),
                    if (type == 'contact')
                      ElevatedButton.icon(
                        onPressed: () => _saveContact(data!),
                        icon: Icon(Icons.contact_page),
                        label: Text('Save Contact'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Share.share(data!);
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      scannerController.start();
                    },
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Scan Again'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

void _showBottomSheet(String data, String type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Scanned Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text(
              "Type: ${type.toUpperCase()}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      data,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 24),
                    if (type == 'url')
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(data),
                        icon: Icon(Icons.open_in_new),
                        label: Text('Open URL'),
                      ),
                    if (type == 'phone')
                      ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(data),
                        icon: Icon(Icons.phone),
                        label: Text('Call Number'),
                      ),
                    if (type == 'email')
                      ElevatedButton.icon(
                        onPressed: () => _sendEmail(data),
                        icon: Icon(Icons.email),
                        label: Text('Send Email'),
                      ),
                    if (type == 'contact')
                      ElevatedButton.icon(
                        onPressed: () => _saveContact(data),
                        icon: Icon(Icons.contact_page),
                        label: Text('Save Contact'),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Share.share(data);
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      scannerController.start();
                    },
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Scan Again'),
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


Future<void> _makePhoneCall(String phone) async {
  final uri = Uri.parse(phone);
  if (await canLaunch(uri.toString())) {
    await launch(uri.toString());
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to make a call')),
    );
  }
}

Future<void> _sendEmail(String email) async {
  final uri = Uri.parse(email);
  if (await canLaunch(uri.toString())) {
    await launch(uri.toString());
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to send an email')),
    );
  }
}


  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open URL')),
      );
    }
  }

  Future<void> _saveContact(String vCardData) async {
    final lines = vCardData.split('\n');
    String? name, phone, email;
    for (var line in lines) {
      if (line.startsWith('FN:')) {
        name = line.substring(3);
      } else if (line.startsWith('TEL:')) {
        phone = line.substring(4);
      } else if (line.startsWith('EMAIL:')) {
        email = line.substring(6);
      }
    }

    final contact = contacts.Contact()
      ..name.first = name ?? ''
      ..phones = [contacts.Phone(phone ?? '')]
      ..emails = [contacts.Email(email ?? '')];

    try {
      await contact.insert();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text('QR Scanner'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SizedBox(
            height: 350,
            child: Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Camera Permission Required'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Allow Camera Permission'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text('Scan QR Code'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                  scannerController.toggleTorch();
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null) {
                  final String code = barcode.rawValue!;
                  _processScannedData(code);
                }
              },
            ),
            Center(
              child: CustomPaint(
                size: Size(300, 300),
                painter: ScannerBoxPainter(),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Align QR Code within the frame to scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class ScannerBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);

    final cornerLength = 20.0;
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), cornerPaint);

    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), cornerPaint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), cornerPaint);

    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), cornerPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), cornerPaint);

    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

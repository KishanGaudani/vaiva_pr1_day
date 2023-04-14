import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

 void main(){
   runApp(MaterialApp(debugShowCheckedModeBanner: false,home: PdfGeneratorPage(),));
 }

class PdfGeneratorPage extends StatefulWidget {
  @override
  _PdfGeneratorPageState createState() => _PdfGeneratorPageState();
}

class _PdfGeneratorPageState extends State<PdfGeneratorPage> {
  File? _pickedImage;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = File(pickedImage!.path);
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pdfLib.Document();

    final pageFormat = PdfPageFormat(8.5 * PdfPageFormat.cm, 11.0 * PdfPageFormat.cm);

    final bytes = await _pickedImage!.readAsBytes();
    final image = PdfImage.file(
      pdf.document,
      bytes: bytes,
    );

    pdf.addPage(pdfLib.Page(
      pageFormat: pageFormat,
      build: (context) {
        return pdfLib.Center(
          child: pdfLib.Image(image as pdfLib.ImageProvider),
        );
      },
    ));

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/generated.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    final status = await Permission.storage.request();
    if (status.isGranted) {
      await file.copy('${dir.path}/generated.pdf');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF generated and saved successfully.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission denied.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('PDF Generator'),
        ),
        body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.0),
                Center(
                  child: _pickedImage == null
                      ? Text('No image picked')
                      : Image.file(_pickedImage!),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickedImage == null ? null : _generatePdf,
                  child: Text('Generate PDF'),
                ),
              ],
            ),
            ),
    );
    }
}
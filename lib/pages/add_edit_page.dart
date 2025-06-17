import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class AddEditPage extends StatefulWidget {
  final Map? data;

  AddEditPage({this.data});

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final formKey = GlobalKey<FormState>();
  final kodeController = TextEditingController();
  final judulController = TextEditingController();
  final penciptaController = TextEditingController();
  final penyanyiController = TextEditingController();
  final jenisController = TextEditingController();
  File? gambar;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      kodeController.text = widget.data!['kode_lagu'];
      judulController.text = widget.data!['judul_lagu'];
      penciptaController.text = widget.data!['pencipta'];
      penyanyiController.text = widget.data!['penyanyi'];
      jenisController.text = widget.data!['jenis'];
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => gambar = File(picked.path));
  }

  Future<void> submit() async {
    final uri =
        widget.data == null
            ? Uri.parse("http://17.1.17.32:3030/lagu")
            : Uri.parse(
              "http://17.1.17.32:3030/lagu/${widget.data!['kode_lagu']}",
            );

    final request = http.MultipartRequest(
      widget.data == null ? "POST" : "PUT",
      uri,
    );

    request.fields['kode_lagu'] = kodeController.text;
    request.fields['judul_lagu'] = judulController.text;
    request.fields['pencipta'] = penciptaController.text;
    request.fields['penyanyi'] = penyanyiController.text;
    request.fields['jenis'] = jenisController.text;

    if (gambar != null) {
      final mimeType = lookupMimeType(gambar!.path)?.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          gambar!.path,
          contentType: MediaType(mimeType![0], mimeType[1]),
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context as BuildContext);
    } else {
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? "Tambah Lagu" : "Edit Lagu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: kodeController,
                decoration: InputDecoration(labelText: "Kode Lagu"),
              ),
              TextFormField(
                controller: judulController,
                decoration: InputDecoration(labelText: "Judul Lagu"),
              ),
              TextFormField(
                controller: penciptaController,
                decoration: InputDecoration(labelText: "Pencipta"),
              ),
              TextFormField(
                controller: penyanyiController,
                decoration: InputDecoration(labelText: "Penyanyi"),
              ),
              TextFormField(
                controller: jenisController,
                decoration: InputDecoration(labelText: "Jenis Lagu"),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text("Pilih Gambar"),
              ),
              if (gambar != null) Image.file(gambar!, height: 100),
              SizedBox(height: 20),
              ElevatedButton(onPressed: submit, child: Text("Simpan")),
            ],
          ),
        ),
      ),
    );
  }
}

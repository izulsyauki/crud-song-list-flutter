import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Lagu',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DatabaseListView(),
    );
  }
}

class DatabaseListView extends StatefulWidget {
  const DatabaseListView({super.key});

  @override
  State<DatabaseListView> createState() => _DatabaseListViewState();
}

class _DatabaseListViewState extends State<DatabaseListView> {
  List<dynamic> lagu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLagu();
  }

  Future<void> getLagu() async {
    try {
      final response = await http.get(Uri.parse('http://17.1.17.32:3030/lagu'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          lagu = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> tambahLagu(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://17.1.17.32:3030/lagu'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'judul_lagu': data['judul'] ?? '',
          'pencipta': data['pencipta'] ?? '',
          'penyanyi': data['penyanyi'] ?? '',
          'jenis': data['jenis'] ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        await getLagu(); // Refresh the list
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lagu berhasil ditambahkan')),
        );
        Navigator.of(context).pop(); // Close the dialog
      } else {
        final responseData = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${responseData['message'] ?? 'Gagal menambahkan lagu'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> updateLagu(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('http://17.1.17.32:3030/lagu/${data['kode_lagu']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'judul_lagu': data['judul'] ?? '',
          'pencipta': data['pencipta'] ?? '',
          'penyanyi': data['penyanyi'] ?? '',
          'jenis': data['jenis'] ?? '',
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        await getLagu(); // Refresh the list
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lagu berhasil diperbarui')),
        );
        Navigator.of(context).pop(); // Close the dialog
      } else {
        final responseData = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${responseData['message'] ?? 'Gagal memperbarui lagu'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> hapusLagu(String kode) async {
    try {
      final response = await http.delete(
        Uri.parse('http://17.1.17.32:3030/lagu/$kode'),
      );

      if (response.statusCode == 200) {
        getLagu(); // Refresh the list
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lagu berhasil dihapus')));
      } else {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${data['message'] ?? 'Gagal menghapus lagu'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Lagu')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final value = await showDialog(
            context: context,
            builder: (context) => const InputLaguDialog(),
          );

          if (value != null && mounted) {
            await tambahLagu(value);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.lightBlueAccent,
            child: ListTile(
              title: const Text(
                'Daftar Lagu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : lagu.isEmpty
                    ? const Center(child: Text('Tidak ada lagu'))
                    : ListView.builder(
                      itemCount: lagu.length,
                      itemBuilder:
                          (context, index) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DetailPage(lagu: lagu[index]),
                                ),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                leading: const Icon(Icons.music_note),
                                title: Text(lagu[index]['judul_lagu']),
                                subtitle: Text(
                                  'Penyanyi: ${lagu[index]['penyanyi']}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final updatedData = await showDialog(
                                          context: context,
                                          builder:
                                              (context) => EditLaguDialog(
                                                lagu: lagu[index],
                                              ),
                                        );
                                        if (updatedData != null && mounted) {
                                          await updateLagu(updatedData);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Konfirmasi Hapus',
                                                ),
                                                content: const Text(
                                                  'Apakah Anda yakin ingin menghapus lagu ini?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const Text(
                                                      'Batal',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      hapusLagu(
                                                        lagu[index]['kode_lagu'],
                                                      );
                                                    },
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    child: const Text(
                                                      'Hapus',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}

class InputLaguDialog extends StatelessWidget {
  const InputLaguDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Tambah Lagu'),
      content: _InputLaguDialogContent(),
    );
  }
}

class _InputLaguDialogContent extends StatefulWidget {
  const _InputLaguDialogContent();

  @override
  State<_InputLaguDialogContent> createState() =>
      _InputLaguDialogContentState();
}

class _InputLaguDialogContentState extends State<_InputLaguDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _penciptaController = TextEditingController();
  final _penyanyiController = TextEditingController();
  final _jenisController = TextEditingController();

  @override
  void dispose() {
    _judulController.dispose();
    _penciptaController.dispose();
    _penyanyiController.dispose();
    _jenisController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _gambar = File(pickedFile.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _judulController,
            decoration: const InputDecoration(labelText: 'Judul Lagu'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Judul lagu tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _penciptaController,
            decoration: const InputDecoration(labelText: 'Pencipta'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pencipta tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _penyanyiController,
            decoration: const InputDecoration(labelText: 'Penyanyi'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Penyanyi tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _jenisController,
            decoration: const InputDecoration(labelText: 'Jenis'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis tidak boleh kosong';
              }
              return null;
            },
          ),

          // ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'judul': _judulController.text,
                      'pencipta': _penciptaController.text,
                      'penyanyi': _penyanyiController.text,
                      'jenis': _jenisController.text,
                    });
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> lagu;

  const DetailPage({super.key, required this.lagu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Lagu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      lagu['gambar'] != null
                          ? DecorationImage(
                            image: NetworkImage(
                              'http://17.1.17.32:3030/uploads/${lagu['gambar']}',
                            ),
                            fit: BoxFit.cover,
                          )
                          : DecorationImage(
                            image: AssetImage('images/default-image.jpg'),
                            fit: BoxFit.cover,
                          ),
                ),
                child:
                    lagu['gambar'] == null
                        ? const Icon(Icons.music_note, size: 100)
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lagu['judul_lagu'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Pencipta: ${lagu['pencipta']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Penyanyi: ${lagu['penyanyi']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Jenis: ${lagu['jenis']}',
              style: const TextStyle(fontSize: 18),
            ),
            // const SizedBox(height: 16),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       showDialog(
            //         context: context,
            //         builder: (context) => EditLaguDialog(lagu: lagu),
            //       ).then((value) {
            //         if (value != null) {
            //           Navigator.pop(context, value);
            //         }
            //       });
            //     },
            //     child: const Text('Edit'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class EditLaguDialog extends StatelessWidget {
  final Map<String, dynamic> lagu;

  const EditLaguDialog({super.key, required this.lagu});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Lagu'),
      content: _EditLaguDialogContent(lagu: lagu),
    );
  }
}

class _EditLaguDialogContent extends StatefulWidget {
  final Map<String, dynamic> lagu;

  const _EditLaguDialogContent({required this.lagu});

  @override
  State<_EditLaguDialogContent> createState() => _EditLaguDialogContentState();
}

class _EditLaguDialogContentState extends State<_EditLaguDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _penciptaController = TextEditingController();
  final _penyanyiController = TextEditingController();
  final _jenisController = TextEditingController();
  // File? _gambar;
  String? _kodeLagu;

  @override
  void initState() {
    super.initState();
    _judulController.text = widget.lagu['judul_lagu'] ?? '';
    _penciptaController.text = widget.lagu['pencipta'] ?? '';
    _penyanyiController.text = widget.lagu['penyanyi'] ?? '';
    _jenisController.text = widget.lagu['jenis'] ?? '';
    _kodeLagu = widget.lagu['kode_lagu'];
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penciptaController.dispose();
    _penyanyiController.dispose();
    _jenisController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _gambar = File(pickedFile.path);
  //     });
  //   }
  // }

  void _updateData() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'kode_lagu': _kodeLagu,
        'judul': _judulController.text,
        'pencipta': _penciptaController.text,
        'penyanyi': _penyanyiController.text,
        'jenis': _jenisController.text,
        // 'gambar': _gambar,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Lagu',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul lagu tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _penciptaController,
              decoration: const InputDecoration(
                labelText: 'Pencipta',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pencipta tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _penyanyiController,
              decoration: const InputDecoration(
                labelText: 'Penyanyi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Penyanyi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jenisController,
              decoration: const InputDecoration(
                labelText: 'Jenis Lagu',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jenis lagu tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _updateData,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

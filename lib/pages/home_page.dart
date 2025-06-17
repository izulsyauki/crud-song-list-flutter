import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List> fetchData() async {
    final response = await http.get(Uri.parse("http://17.1.17.32:3030/lagu"));
    return json.decode(response.body);
  }

  void deleteLagu(String kodeLagu) async {
    final response = await http.delete(
      Uri.parse("http://17.1.17.32:3030/lagu/$kodeLagu"),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lagu dihapus")));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Lagu")),
      body: FutureBuilder<List>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error"));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final lagu = data[index];
              return ListTile(
                leading:
                    lagu['gambar'] != null
                        ? Image.network(
                          "http://17.1.17.32:3030/uploads/${lagu['gambar']}",
                          width: 50,
                        )
                        : Icon(Icons.music_note),
                title: Text(lagu['judul_lagu']),
                subtitle: Text("${lagu['penyanyi']} - ${lagu['jenis']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditPage(data: lagu),
                            ),
                          ).then((_) => setState(() {})),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteLagu(lagu['kode_lagu']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditPage()),
            ).then((_) => setState(() {})),
        child: Icon(Icons.add),
      ),
    );
  }
}

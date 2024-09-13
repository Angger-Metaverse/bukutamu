import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bukutamu/config/server.dart';
import 'package:bukutamu/config/palette.dart';
import 'tambah_tamu_page.dart';
import 'detail_tamu.dart';
import 'model_tamu.dart';
import 'edit_buku_tamu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ModelTamu> _listTamu = [];
  List<ModelTamu> _searchTamu = [];
  List<Map<String, dynamic>> _kecamatanList = [];
  List<Map<String, dynamic>> _kelurahanList = [];
  List<Map<String, dynamic>> _pegawaiList = [];
  bool loading = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    _listTamu.clear();
    await Future.wait([
      fetchDataTamu(),
      _fetchKecamatan(),
      _fetchKelurahan(),
      _fetchPegawai()
    ]);
    setState(() => loading = false);
  }

  Future<void> fetchDataTamu() async {
    final response = await http.post(
      Uri.parse(Server.network + "api/get_data_buku_tamu.php"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        _listTamu = data.map((json) => ModelTamu.fromJson(json)).toList();
      });
    } else {
      print("Failed to fetch data from get_data_buku_tamu.php");
    }
  }

  Future<void> _fetchData(
      String endpoint, List<Map<String, dynamic>> targetList) async {
    final response = await http.get(Uri.parse(Server.network + endpoint));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        targetList.addAll(data.map((item) => item as Map<String, dynamic>));
      });
    } else {
      print("Failed to load data from $endpoint");
    }
  }

  Future<void> _fetchKecamatan() async {
    try {
      await _fetchData("api/kecamatan_api.php", _kecamatanList);
    } catch (e) {
      print("Failed to fetch data from kecamatan_api.php: $e");
    }
  }

  Future<void> _fetchKelurahan() async {
    try {
      await _fetchData("api/kelurahan_api.php", _kelurahanList);
    } catch (e) {
      print("Failed to fetch data from kelurahan_api.php: $e");
    }
  }

  Future<void> _fetchPegawai() async {
    try {
      await _fetchData("api/pegawai_api.php", _pegawaiList);
    } catch (e) {
      print("Failed to fetch data from pegawai_api.php: $e");
    }
  }

  void onSearchTamu(String text) {
    setState(() {
      _searchTamu =
          _listTamu.where((tamu) => tamu.nama!.contains(text)).toList();
    });
  }

  void confirmDelete(String id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Are you sure want to delete $nama?"),
        actions: [
          ElevatedButton(
            child: Text("OK DELETE!"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _deleteTamu(id);
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: Text("Cancel"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTamu(String id) async {
    final uri = Uri.parse(Server.network + "api/delete_tamu.php");
    await http.MultipartRequest("POST", uri)
      ..fields['id'] = id;
    fetchDataTamu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tamu"),
        automaticallyImplyLeading: false,
        backgroundColor: Palette.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataTamu,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                    controller: controller,
                    onChanged: onSearchTamu,
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () => setState(() => _searchTamu.clear()),
                  ),
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchTamu.isEmpty
                          ? _listTamu.length
                          : _searchTamu.length,
                      itemBuilder: (context, i) {
                        final tamu =
                            _searchTamu.isEmpty ? _listTamu[i] : _searchTamu[i];
                        return _buildTamuCard(tamu);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TambahTamuPage())),
        child: Icon(Icons.add),
        backgroundColor: Palette.primaryColor,
      ),
    );
  }

  Widget _buildTamuCard(ModelTamu tamu) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            children: [
              _buildAvatar(),
              SizedBox(width: 20),
              _buildTamuInfo(tamu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(Server.network + "uploads/user_icon.png"),
        ),
      ),
    );
  }

  Widget _buildTamuInfo(ModelTamu tamu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 140,
          child: Text(tamu.nama!, style: TextStyle(fontSize: 17)),
        ),
        SizedBox(height: 10),
        Text(tamu.noHp!, style: TextStyle(fontSize: 17)),
        SizedBox(height: 10),
        Row(
          children: [
            _buildActionButton(Icons.info, Colors.white, Palette.primaryColor,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetailTamu(
                            nama: tamu.nama!,
                            tanggal: tamu.tanggal!,
                            alamat: tamu.alamat!,
                            kelurahan: tamu.kelurahan!,
                            kecamatan: tamu.kecamatan!,
                            noHp: tamu.noHp!,
                            tujuan: tamu.tujuan!,
                            foto: tamu.foto!,
                          )));
            }),
            SizedBox(width: 5),
            _buildActionButton(Icons.edit, Colors.black, Colors.yellow, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditBukuTamu(
                            id: tamu.id!,
                            tanggal: tamu.tanggal!,
                            namaTamu: tamu.nama!,
                            alamat: tamu.alamat!,
                            kelurahan: tamu.kelurahan!,
                            kecamatan: tamu.kecamatan!,
                            noHp: tamu.noHp!,
                            tujuan: tamu.tujuan!,
                            foto: tamu.foto!,
                            kecamatanList: _kecamatanList,
                            kelurahanList: _kelurahanList,
                            pegawaiList: _pegawaiList,
                            namaPegawai: tamu.namaPegawai ?? '',
                          )));
            }),
            SizedBox(width: 5),
            _buildActionButton(
                Icons.restore_from_trash, Colors.white, Colors.red, () {
              confirmDelete(tamu.id!, tamu.nama!);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, Color iconColor, Color bgColor, VoidCallback onPressed) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}

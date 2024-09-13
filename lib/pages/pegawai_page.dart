import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model_pegawai.dart';
import 'package:bukutamu/config/server.dart';
import 'package:bukutamu/config/palette.dart';
import 'tambah_pegawai_page.dart';
import 'detail_pegawai_page.dart';
import 'edit_pegawai_page.dart';

class PegawaiPage extends StatefulWidget {
  @override
  _PegawaiPageState createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  List<ModelPegawai> _listPegawai = [];
  List<ModelPegawai> _searchPegawai = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchDataPegawai();
  }

  Future<void> fetchDataPegawai() async {
    setState(() => loading = true);
    _listPegawai.clear();
    final response =
        await http.post(Uri.parse(Server.network + "api/get_data_pegawai.php"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        _listPegawai = data.map((json) => ModelPegawai.fromJson(json)).toList();
        loading = false;
      });
    }
  }

  void onSearchPegawai(String text) {
    setState(() {
      _searchPegawai = _listPegawai
          .where((pegawai) => pegawai.namaPegawai!.contains(text))
          .toList();
    });
  }

  void confirmDelete(String id, String namaPegawai) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Are you sure want to delete $namaPegawai?"),
        actions: [
          ElevatedButton(
            child: Text("OK DELETE!"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _deletePegawai(id);
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

  Future<void> _deletePegawai(String id) async {
    final uri = Uri.parse(Server.network + "api/delete_pegawai.php");
    await http.MultipartRequest("POST", uri)
      ..fields['id'] = id;
    fetchDataPegawai();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pegawai"),
        backgroundColor: Palette.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataPegawai,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                    onChanged: onSearchPegawai,
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () => setState(() => _searchPegawai.clear()),
                  ),
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchPegawai.isEmpty
                          ? _listPegawai.length
                          : _searchPegawai.length,
                      itemBuilder: (context, i) {
                        final pegawai = _searchPegawai.isEmpty
                            ? _listPegawai[i]
                            : _searchPegawai[i];
                        return _buildPegawaiCard(pegawai);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TambahPegawaiPage())),
        child: Icon(Icons.add),
        backgroundColor: Palette.primaryColor,
      ),
    );
  }

  Widget _buildPegawaiCard(ModelPegawai pegawai) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            children: [
              _buildAvatar(),
              SizedBox(width: 20),
              _buildPegawaiInfo(pegawai),
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

  Widget _buildPegawaiInfo(ModelPegawai pegawai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 140,
          child: Text(pegawai.namaPegawai!, style: TextStyle(fontSize: 17)),
        ),
        SizedBox(height: 10),
        Text(pegawai.noWhatsapp!, style: TextStyle(fontSize: 17)),
        SizedBox(height: 10),
        Row(
          children: [
            _buildActionButton(Icons.info, Colors.white, Palette.primaryColor,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetailPegawaiPage(
                            namaPegawai: pegawai.namaPegawai!,
                            noWhatsapp: pegawai.noWhatsapp!,
                          )));
            }),
            SizedBox(width: 5),
            _buildActionButton(Icons.edit, Colors.black, Colors.yellow, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditPegawaiPage(
                            id: pegawai.id!,
                            namaPegawai: pegawai.namaPegawai!,
                            noWhatsapp: pegawai.noWhatsapp!,
                          )));
            }),
            SizedBox(width: 5),
            _buildActionButton(
                Icons.restore_from_trash, Colors.white, Colors.red, () {
              confirmDelete(pegawai.id!, pegawai.namaPegawai!);
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

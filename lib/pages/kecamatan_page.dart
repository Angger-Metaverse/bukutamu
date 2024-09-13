import 'package:bukutamu/config/server.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model_kecamatan.dart';
import 'model_kelurahan.dart';

class KecamatanPage extends StatefulWidget {
  @override
  _KecamatanPageState createState() => _KecamatanPageState();
}

class _KecamatanPageState extends State<KecamatanPage> {
  List<ModelKecamatan> _kecamatanList = [];
  List<ModelKelurahan> _kelurahanList = [];
  ModelKecamatan? _selectedKecamatan;
  ModelKelurahan? _selectedKelurahan;

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
  }

  Future<void> _fetchKecamatan() async {
    final response =
        await http.get(Uri.parse(Server.network + 'tamu/getKecamatan.php'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      setState(() {
        _kecamatanList =
            jsonResponse.map((data) => ModelKecamatan.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load kecamatan');
    }
  }

  Future<void> _fetchKelurahan(int kecamatanId) async {
    final response = await http.get(Uri.parse( Server.network +
        'tamu/getKelurahan.php?kecamatan_id=$kecamatanId'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      setState(() {
        _kelurahanList =
            jsonResponse.map((data) => ModelKelurahan.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load kelurahan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Kecamatan dan Kelurahan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<ModelKecamatan>(
              hint: Text('Pilih Kecamatan'),
              value: _selectedKecamatan,
              onChanged: (ModelKecamatan? newValue) {
                setState(() {
                  _selectedKecamatan = newValue;
                  _selectedKelurahan = null;
                  _kelurahanList = [];
                });
                if (newValue != null) {
                  _fetchKelurahan(newValue.id);
                }
              },
              items: _kecamatanList.map((ModelKecamatan kec) {
                return DropdownMenuItem<ModelKecamatan>(
                  value: kec,
                  child: Text(kec.nama),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            DropdownButton<ModelKelurahan>(
              hint: Text('Pilih Kelurahan'),
              value: _selectedKelurahan,
              onChanged: (ModelKelurahan? newValue) {
                setState(() {
                  _selectedKelurahan = newValue;
                });
              },
              items: _kelurahanList.map((ModelKelurahan kel) {
                return DropdownMenuItem<ModelKelurahan>(
                  value: kel,
                  child: Text(kel.nama),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

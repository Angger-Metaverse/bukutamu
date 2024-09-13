import 'package:bukutamu/config/server.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedKecamatan;
  String? selectedKelurahan;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> kecamatanList = [];
  List<Map<String, dynamic>> kelurahanList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
  }

  Future<void> _fetchKecamatan() async {
    final response =
        await http.get(Uri.parse(Server.network + "api/kecamatan_api.php"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        kecamatanList =
            data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Failed to load kecamatan');
    }
  }

  Future<void> _fetchKelurahan(int kecamatanId) async {
    final response = await http.get(Uri.parse(
        Server.network + "api/kelurahan_api.php?kecamatan_id=$kecamatanId"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        kelurahanList =
            data.map((item) => item as Map<String, dynamic>).toList();
        selectedKelurahan = null;
      });
    } else {
      throw Exception('Failed to load kelurahan');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void predict() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse(Server.network +
        'api/prediksi.php?id_kecamatan=$selectedKecamatan&id_kelurahan=$selectedKelurahan&tanggal=${selectedDate.toIso8601String()}'));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Prediksi Tamu'),
          content: Text(result.toString()),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to get prediction');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Kecamatan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            DropdownSearch<Map<String, dynamic>>(
              mode: Mode.BOTTOM_SHEET,
              isFilteredOnline: true,
              showClearButton: true,
              showSearchBox: true,
              items: kecamatanList,
              itemAsString: (item) => item?['nama'],
              onChanged: (value) {
                setState(() {
                  selectedKecamatan = value?['id'].toString();
                  if (value != null) {
                    _fetchKelurahan(int.parse(value['id'].toString()));
                  } else {
                    kelurahanList = [];
                    selectedKelurahan = null;
                  }
                });
              },
              selectedItem: selectedKecamatan != null
                  ? kecamatanList.firstWhere(
                      (item) => item['id'].toString() == selectedKecamatan)
                  : null,
              dropdownBuilder: (context, selectedItem) {
                return Text(selectedItem?['nama'] ?? 'Pilih Kecamatan');
              },
              popupItemBuilder: (context, item, isSelected) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: !isSelected
                      ? null
                      : BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                  child: ListTile(
                    selected: isSelected,
                    title: Text(item['nama']),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Pilih Kelurahan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            DropdownSearch<Map<String, dynamic>>(
              mode: Mode.BOTTOM_SHEET,
              isFilteredOnline: true,
              showClearButton: true,
              showSearchBox: true,
              items: kelurahanList,
              itemAsString: (item) => item?['nama'],
              onChanged: (value) {
                setState(() {
                  selectedKelurahan = value?['id'].toString();
                });
              },
              selectedItem: selectedKelurahan != null
                  ? kelurahanList.firstWhere(
                      (item) => item['id'].toString() == selectedKelurahan)
                  : null,
              dropdownBuilder: (context, selectedItem) {
                return Text(selectedItem?['nama'] ?? 'Pilih Kelurahan');
              },
              popupItemBuilder: (context, item, isSelected) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: !isSelected
                      ? null
                      : BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                  child: ListTile(
                    selected: isSelected,
                    title: Text(item['nama']),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Pilih Tanggal:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Pilih Tanggal'),
                )
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed:
                    selectedKecamatan != null && selectedKelurahan != null
                        ? predict
                        : null,
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Prediksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

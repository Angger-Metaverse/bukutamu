import 'dart:convert';
import 'dart:io';
import 'package:bukutamu/main.dart';
import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';
import 'package:bukutamu/config/server.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import library untuk DateFormat
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';

import 'package:dropdown_search/dropdown_search.dart';

class TambahPegawaiPage extends StatefulWidget {
  @override
  _TambahTamuPageState createState() => _TambahTamuPageState();
}

class _TambahTamuPageState extends State<TambahPegawaiPage> {
  TextEditingController namaPegawaiController = TextEditingController();
  TextEditingController noWhatsappController = TextEditingController();

  Future uploadImage() async {
    final uri = Uri.parse(Server.network + "api/upload_pegawai.php");
    var request = http.MultipartRequest("POST", uri);
    request.fields['nama_pegawai'] = namaPegawaiController.text;
    request.fields['no_whatsapp'] = noWhatsappController.text;

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Data Terkirim');
    } else {
      print('Data Gagal Dikirim');
    }
  }

  @override
  void initState() {
    super.initState();
    // getAllDivisi();
    // getAllPegawai();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Pegawai"),
        backgroundColor: Palette.primaryColor,
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildBody(screenHeight, screenWidth),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildBody(double screenHeight, double screenWidth) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: namaPegawaiController,
                    decoration: new InputDecoration(
                      hintText: "Nama Pegawai",
                      labelText: "Nama Pegawai",
                      border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  TextFormField(
                    controller: noWhatsappController,
                    decoration: new InputDecoration(
                      hintText: "No. Whatsapp",
                      labelText: "No. Whatsapp",
                      border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  // Tambahkan DropdownSearch di sini

                  ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Palette.primaryColor,
                          fixedSize: Size(screenWidth, 54.0)),
                      child: const Text('Submit'),
                      onPressed: () => {
                            uploadImage(),
                            Navigator.pop(context),
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavBar(
                                        currentIndex: 1,
                                      )),
                            ).then((value) => setState(() {}))
                          }),
                ]),
          ],
        ),
      ),
    );
  }
}

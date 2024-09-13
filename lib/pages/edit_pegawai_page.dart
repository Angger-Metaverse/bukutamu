import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';

import 'package:bukutamu/config/server.dart';

import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Import library untuk DateFormat
import '../main.dart';

class EditPegawaiPage extends StatefulWidget {
  EditPegawaiPage(
      {Key? key,
      required this.id,
      required this.namaPegawai,
      required this.noWhatsapp})
      : super(key: key);

  String id;
  String namaPegawai;
  String noWhatsapp;

  @override
  _EditPegawaiPageState createState() => _EditPegawaiPageState();
}

class _EditPegawaiPageState extends State<EditPegawaiPage> {
  TextEditingController? namaPegawaiController;
  TextEditingController? noWhatsappController;

  @override
  void initState() {
    super.initState();
    namaPegawaiController = TextEditingController(text: widget.namaPegawai);
    noWhatsappController = TextEditingController(text: widget.noWhatsapp);
  }

  Future uploadImage() async {
    final uri = Uri.parse(Server.network + "api/update_pegawai.php");
    var request = http.MultipartRequest("POST", uri);

    request.fields['id'] = widget.id;
    request.fields['nama_pegawai'] = namaPegawaiController!.text;
    request.fields['no_whatsapp'] = noWhatsappController!.text;

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Data Berhasil dikirim');
    } else {
      print('Data Gagal Dikirim');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaPegawai),
        backgroundColor: Palette.primaryColor,
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildBody(screenWidth),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildBody(double screenWidth) {
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
                  decoration: InputDecoration(
                    hintText: "Nama Pegawai",
                    labelText: "Nama Pegawai",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                TextFormField(
                  controller: noWhatsappController,
                  decoration: InputDecoration(
                    hintText: "No. Whatsapp",
                    labelText: "No. Whatsapp",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Palette.primaryColor,
                    fixedSize: Size(screenWidth, 54.0),
                  ),
                  child: const Text('Submit'),
                  onPressed: () {
                    uploadImage();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBar(currentIndex: 0),
                      ),
                    ).then((value) => setState(() {}));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';
import 'package:bukutamu/config/server.dart';

// import 'package:jurusan/screens/tes_kejurusan_screen2.dart';

class DetailPegawaiPage extends StatefulWidget {
  @override
  _DetailPegawaiPageState createState() => _DetailPegawaiPageState();

  final String namaPegawai;
  final String noWhatsapp;

  // receive data from the FirstScreen as a parameter
  DetailPegawaiPage(
      {Key? key, required this.namaPegawai, required this.noWhatsapp})
      : super(key: key);
}

class _DetailPegawaiPageState extends State<DetailPegawaiPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Pegawai"),
        backgroundColor: Palette.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: screenHeight * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(Server.network +
                      "uploads/user_icon.png"), // Ganti dengan path foto default Anda
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      widget.namaPegawai,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Nomor Whatsapp : ' + widget.noWhatsapp,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';
import 'package:bukutamu/config/server.dart';

class DetailTamu extends StatefulWidget {
  @override
  _DetailTamuState createState() => _DetailTamuState();

  final String tanggal;
  final String nama;
  final String alamat;
  final String kelurahan;
  final String kecamatan;
  final String noHp;
  final String tujuan;
  final String foto;

  DetailTamu({
    Key? key,
    required this.tanggal,
    required this.nama,
    required this.alamat,
    required this.kelurahan,
    required this.kecamatan,
    required this.noHp,
    required this.tujuan,
    required this.foto,
  }) : super(key: key);
}

class _DetailTamuState extends State<DetailTamu> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Tamu"),
        backgroundColor: Palette.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: screenHeight * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      widget.foto.isNotEmpty
                          ? Server.network + "uploads/" + widget.foto
                          : Server.network + "uploads/user_icon.png",
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.nama,
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
              ),
              SizedBox(height: 20),
              buildDetailCard(
                context,
                icon: Icons.date_range,
                label: 'Tanggal',
                value: widget.tanggal,
              ),
              buildDetailCard(
                context,
                icon: Icons.home,
                label: 'Alamat',
                value: widget.alamat,
              ),
              buildDetailCard(
                context,
                icon: Icons.location_city,
                label: 'Kelurahan',
                value: widget.kelurahan,
              ),
              buildDetailCard(
                context,
                icon: Icons.location_on,
                label: 'Kecamatan',
                value: widget.kecamatan,
              ),
              buildDetailCard(
                context,
                icon: Icons.phone,
                label: 'Nomor HP',
                value: widget.noHp,
              ),
              buildDetailCard(
                context,
                icon: Icons.business,
                label: 'Tujuan',
                value: widget.tujuan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailCard(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Palette.primaryColor, size: 30),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

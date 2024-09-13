import 'dart:convert';
import 'dart:io';
import 'package:bukutamu/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';
import 'package:http/http.dart' as http;
import 'package:bukutamu/config/server.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class PublicPage extends StatefulWidget {
  @override
  _PublicPageState createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _namaTamuController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _kecamatanList = [];
  List<Map<String, dynamic>> _kelurahanList = [];
  List<Map<String, dynamic>> _pegawaiList = [];
  Map<String, dynamic>? _selectedKecamatan;
  Map<String, dynamic>? _selectedKelurahan;
  Map<String, dynamic>? _selectedPegawai;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
    _fetchPegawai();
  }

  Future<void> _fetchKecamatan() async {
    final response =
        await http.get(Uri.parse(Server.network + "api/kecamatan_api.php"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _kecamatanList =
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
        _kelurahanList =
            data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Failed to load kelurahan');
    }
  }

  Future<void> _fetchPegawai() async {
    final response =
        await http.get(Uri.parse(Server.network + "api/pegawai_api.php"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _pegawaiList =
            data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Failed to load pegawai');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse(Server.network + "api/upload_tamu.php");
      var request = http.MultipartRequest("POST", uri);

      request.fields['tanggal'] = _tanggalController.text;
      request.fields['nama'] = _namaTamuController.text;
      request.fields['alamat'] = _alamatController.text;
      request.fields['id_kelurahan'] = _selectedKelurahan!['id'].toString();
      request.fields['id_kecamatan'] = _selectedKecamatan!['id'].toString();
      request.fields['no_hp'] = _noHpController.text;
      request.fields['tujuan'] = _tujuanController.text;
      request.fields['id_pegawai'] = _selectedPegawai!['id'].toString();

      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil Diupload.')),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data gagal Diupload.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua data sebelum mengirim.')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _tanggalController.clear();
      _namaTamuController.clear();
      _alamatController.clear();
      _noHpController.clear();
      _tujuanController.clear();
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _selectedPegawai = null;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public Page'),
        backgroundColor: Palette.primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text(
              'Admin Login',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _image != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Gambar',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                    : Container(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Palette.primaryColor,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Upload Foto Wajah Tamu'),
                  onPressed: _chooseImage,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _tanggalController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong isi tanggal';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _namaTamuController,
                  labelText: 'Nama Tamu',
                  icon: Icons.person,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _alamatController,
                  labelText: 'Alamat',
                  icon: Icons.location_on,
                ),
                SizedBox(height: 20),
                DropdownSearch<Map<String, dynamic>>(
                  mode: Mode.BOTTOM_SHEET,
                  isFilteredOnline: true,
                  showClearButton: true,
                  showSearchBox: true,
                  label: "Pilih Kecamatan",
                  items: _kecamatanList,
                  onChanged: (Map<String, dynamic>? newValue) {
                    setState(() {
                      _selectedKecamatan = newValue;
                      if (newValue != null) {
                        _fetchKelurahan(int.parse(newValue['id'].toString()));
                      } else {
                        _selectedKelurahan = null;
                        _kelurahanList = [];
                      }
                    });
                  },
                  selectedItem: _selectedKecamatan,
                  dropdownBuilder: (context, selectedItem) {
                    if (selectedItem == null) {
                      return Text('Pilih Kecamatan');
                    } else {
                      return Text(selectedItem['nama']);
                    }
                  },
                  popupItemBuilder: (context, item, isSelected) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: !isSelected
                          ? null
                          : BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                      child: ListTile(
                        selected: isSelected,
                        title: Text(item['nama']),
                      ),
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Tolong pilih kecamatan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownSearch<Map<String, dynamic>>(
                  mode: Mode.BOTTOM_SHEET,
                  isFilteredOnline: true,
                  showClearButton: true,
                  showSearchBox: true,
                  label: "Pilih Kelurahan",
                  items: _kelurahanList,
                  onChanged: (Map<String, dynamic>? newValue) {
                    setState(() {
                      _selectedKelurahan = newValue;
                    });
                  },
                  selectedItem: _selectedKelurahan,
                  dropdownBuilder: (context, selectedItem) {
                    if (selectedItem == null) {
                      return Text('Pilih Kelurahan');
                    } else {
                      return Text(selectedItem['nama']);
                    }
                  },
                  popupItemBuilder: (context, item, isSelected) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: !isSelected
                          ? null
                          : BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                      child: ListTile(
                        selected: isSelected,
                        title: Text(item['nama']),
                      ),
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Tolong pilih kelurahan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _noHpController,
                  labelText: 'No. HP',
                  icon: Icons.phone,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _tujuanController,
                  labelText: 'Alasan Bertamu',
                  icon: Icons.description,
                ),
                SizedBox(height: 20),
                DropdownSearch<Map<String, dynamic>>(
                  mode: Mode.BOTTOM_SHEET,
                  isFilteredOnline: true,
                  showClearButton: true,
                  showSearchBox: true,
                  label: "Pilih Pegawai",
                  items: _pegawaiList,
                  onChanged: (Map<String, dynamic>? newValue) {
                    setState(() {
                      _selectedPegawai = newValue;
                    });
                  },
                  selectedItem: _selectedPegawai,
                  dropdownBuilder: (context, selectedItem) {
                    if (selectedItem == null) {
                      return Text('Pilih Pegawai yang Ditemui');
                    } else {
                      return Text(selectedItem['nama_pegawai']);
                    }
                  },
                  popupItemBuilder: (context, item, isSelected) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: !isSelected
                          ? null
                          : BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                      child: ListTile(
                        selected: isSelected,
                        title: Text(item['nama_pegawai']),
                      ),
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Tolong pilih pegawai';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Palette.primaryColor,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Submit'),
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tolong isi $labelText';
        }
        return null;
      },
    );
  }
}

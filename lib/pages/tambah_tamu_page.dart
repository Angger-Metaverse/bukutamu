import 'dart:convert';
import 'dart:io';
import 'package:bukutamu/main.dart';
import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';
import 'package:bukutamu/config/server.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';
import 'package:dropdown_search/dropdown_search.dart';

class TambahTamuPage extends StatefulWidget {
  @override
  _TambahTamuPageState createState() => _TambahTamuPageState();
}

class _TambahTamuPageState extends State<TambahTamuPage> {
  File? _image;
  Map<String, dynamic>? _selectedPegawai;
  Map<String, dynamic>? _selectedKecamatan;
  Map<String, dynamic>? _selectedKelurahan;

  List<Map<String, dynamic>> _kecamatanList = [];
  List<Map<String, dynamic>> _kelurahanList = [];

  DateTime selectedDate = DateTime.now();

  TextEditingController tanggalController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController kelurahanController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController noHpController = TextEditingController();
  TextEditingController tujuanController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
        _selectedKelurahan = null; // Reset selected kelurahan
      });
    } else {
      throw Exception('Failed to load kelurahan');
    }
  }

  Future choiceImage() async {
    PickedFile? image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 10);
    setState(() {
      _image = File(image!.path);
    });
  }

  Future uploadImage() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final uri = Uri.parse(Server.network + "api/upload_tamu.php");
      var request = http.MultipartRequest("POST", uri);
      request.fields['tanggal'] = tanggalController.text;
      request.fields['nama'] = namaController.text;
      request.fields['alamat'] = alamatController.text;
      request.fields['id_kelurahan'] = _selectedKelurahan!['id'].toString();
      request.fields['id_kecamatan'] = _selectedKecamatan!['id'].toString();
      request.fields['no_hp'] = noHpController.text;
      request.fields['tujuan'] = tujuanController.text;
      request.fields['id_pegawai'] = _selectedPegawai!['id'].toString();
      var pic = await http.MultipartFile.fromPath("image", _image!.path);
      request.files.add(pic);
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Data Terkirim');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil dikirim.'),
          ),
        );
        Navigator.pop(context, true); // Return true on successful upload
      } else {
        print('Data Gagal Dikirim');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data gagal dikirim.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua data sebelum mengirim.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Tamu"),
        backgroundColor: Palette.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            _buildBody(screenHeight, screenWidth),
          ],
        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: screenWidth / 3 * 1.3,
                        color: Colors.white,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Wajah Tamu",
                            style: const TextStyle(
                              color: Palette.primaryColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      width: screenWidth / 3 * 1.3,
                      height: screenWidth / 5 * 1.5,
                      color: Colors.grey[200],
                      child: Center(
                        child: _image == null
                            ? Text(
                                "Tolong Upload Gambar",
                                style: TextStyle(color: Colors.red),
                              )
                            : Image.file(
                                _image ?? File("path_to_default_image")),
                      ),
                    ),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Palette.primaryColor,
                            fixedSize: Size((screenWidth / 3) * 1.3,
                                (screenWidth / 20) * 1.5)),
                        child: const Text('Foto Wajah Tamu'),
                        onPressed: () {
                          choiceImage();
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: tanggalController,
                        decoration: new InputDecoration(
                          hintText: "Isi Tanggal",
                          labelText: "Tanggal",
                          border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: new InputDecoration(
                      hintText: "Isi Nama Tamu",
                      labelText: "Nama Tamu",
                      border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong isi nama tamu';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  TextFormField(
                    controller: alamatController,
                    decoration: new InputDecoration(
                      hintText: "Alamat",
                      labelText: "Alamat",
                      border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong isi alamat';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  // Dropdown Kecamatan dengan Pencarian
                  DropdownSearch<Map<String, dynamic>>(
                    mode: Mode.BOTTOM_SHEET,
                    isFilteredOnline: true,
                    showClearButton: true,
                    showSearchBox: true,
                    label: "Pilih Kecamatan",
                    onFind: (String? filter) async {
                      final response = await http.get(Uri.parse(Server.network +
                          "api/kecamatan_api.php?search=$filter"));
                      if (response.statusCode == 200) {
                        final List<dynamic> data = json.decode(response.body);
                        return data
                            .map((item) => item as Map<String, dynamic>)
                            .toList();
                      } else {
                        throw Exception('Failed to load kecamatan');
                      }
                    },
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  // Dropdown Kelurahan dengan Pencarian
                  DropdownSearch<Map<String, dynamic>>(
                    mode: Mode.BOTTOM_SHEET,
                    isFilteredOnline: true,
                    showClearButton: true,
                    showSearchBox: true,
                    label: "Pilih Kelurahan",
                    onFind: (String? filter) async {
                      final response = await http.get(Uri.parse(Server.network +
                          "api/kelurahan_api.php?kecamatan_id=${_selectedKecamatan != null ? _selectedKecamatan!['id'] : ''}&search=$filter"));
                      if (response.statusCode == 200) {
                        final List<dynamic> data = json.decode(response.body);
                        return data
                            .map((item) => item as Map<String, dynamic>)
                            .toList()
                            .take(5)
                            .toList();
                      } else {
                        throw Exception('Failed to load kelurahan');
                      }
                    },
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  TextFormField(
                    controller: noHpController,
                    decoration: new InputDecoration(
                      hintText: "No. HP",
                      labelText: "No. HP",
                      border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong isi no. HP';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  TextFormField(
                    controller: tujuanController,
                    decoration: new InputDecoration(
                      hintText: "Alasan Bertamu",
                      labelText: "Isi Alasan Bertamu",
                      border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong isi alasan bertamu';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  DropdownSearch<Map<String, dynamic>>(
                    mode: Mode.BOTTOM_SHEET,
                    isFilteredOnline: true,
                    showClearButton: true,
                    showSearchBox: true,
                    label: "Pilih Pegawai",
                    onFind: (String? filter) async {
                      final response = await http.get(Uri.parse(
                          Server.network + 'api/api.php?search=$filter'));
                      if (response.statusCode == 200) {
                        final List<dynamic> data = json.decode(response.body);
                        return data
                            .map((item) => item as Map<String, dynamic>)
                            .toList()
                            .take(5)
                            .toList();
                      } else {
                        throw Exception('Failed to load items');
                      }
                    },
                    onChanged: (Map<String, dynamic>? data) {
                      setState(() {
                        _selectedPegawai = data;
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),

                  ElevatedButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Palette.primaryColor,
                        fixedSize: Size(screenWidth, 54.0)),
                    child: const Text('Submit'),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _image != null) {
                        uploadImage();
                      } else if (_image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tolong upload gambar.'),
                          ),
                        );
                      }
                    },
                  ),
                ]),
          ],
        ),
      ),
    );
  }

  Widget _customDropDownExample(
      BuildContext context, Map<String, dynamic>? item) {
    if (item == null) {
      return ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text("Pilih Item"),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(item['nama']),
    );
  }

  Widget _customPopupItemBuilderExample(
      BuildContext context, Map<String, dynamic> item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item['nama']),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }
}

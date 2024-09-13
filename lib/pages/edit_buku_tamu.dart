import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bukutamu/config/palette.dart';
import 'package:bukutamu/config/server.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class EditBukuTamu extends StatefulWidget {
  EditBukuTamu(
      {Key? key,
      required this.id,
      required this.tanggal,
      required this.namaTamu,
      required this.alamat,
      required this.kelurahan,
      required this.kecamatan,
      required this.noHp,
      required this.tujuan,
      required this.foto,
      required this.kecamatanList,
      required this.kelurahanList,
      required this.pegawaiList,
      required this.namaPegawai})
      : super(key: key);

  final String id;
  final String tanggal;
  final String namaTamu;
  final String alamat;
  final String kelurahan;
  final String kecamatan;
  final String noHp;
  final String tujuan;
  final String foto;
  final List<Map<String, dynamic>> kecamatanList;
  final List<Map<String, dynamic>> kelurahanList;
  final List<Map<String, dynamic>> pegawaiList;
  final String namaPegawai;

  @override
  _EditBukuTamuState createState() => _EditBukuTamuState();
}

class _EditBukuTamuState extends State<EditBukuTamu> {
  File? _image;
  Map<String, dynamic>? _selectedPegawai;
  Map<String, dynamic>? _selectedKecamatan;
  Map<String, dynamic>? _selectedKelurahan;

  List<Map<String, dynamic>> _kelurahanList = [];

  DateTime selectedDate = DateTime.now();

  TextEditingController? tanggalController;
  TextEditingController? namaTamuController;
  TextEditingController? alamatController;
  TextEditingController? kelurahanController;
  TextEditingController? kecamatanController;
  TextEditingController? noHpController;
  TextEditingController? tujuanController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    tanggalController = TextEditingController(text: widget.tanggal);
    namaTamuController = TextEditingController(text: widget.namaTamu);
    alamatController = TextEditingController(text: widget.alamat);
    kelurahanController = TextEditingController(text: widget.kelurahan);
    kecamatanController = TextEditingController(text: widget.kecamatan);
    noHpController = TextEditingController(text: widget.noHp);
    tujuanController = TextEditingController(text: widget.tujuan);

    _selectedKecamatan = widget.kecamatanList.firstWhere(
      (kecamatan) => kecamatan['nama'] == widget.kecamatan,
      orElse: () => <String, dynamic>{},
    );
    if (_selectedKecamatan!.isNotEmpty) {
      _fetchKelurahan(int.parse(_selectedKecamatan!['id'].toString()));
    }

    _selectedPegawai = widget.pegawaiList.firstWhere(
      (pegawai) => pegawai['nama_pegawai'] == widget.namaPegawai,
      orElse: () => <String, dynamic>{},
    );
    if (_selectedPegawai!.isEmpty) {
      _selectedPegawai = null;
    }

    print(
        'Selected Pegawai: $_selectedPegawai'); // Debug: Print selected pegawai
  }

  Future<void> _fetchKelurahan(int kecamatanId) async {
    final response = await http.get(Uri.parse(
        Server.network + "api/kelurahan_api.php?kecamatan_id=$kecamatanId"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _kelurahanList =
            data.map((item) => item as Map<String, dynamic>).toList();
        _selectedKelurahan = _kelurahanList.firstWhere(
          (kelurahan) => kelurahan['nama'] == widget.kelurahan,
          orElse: () => <String, dynamic>{},
        );
        if (_selectedKelurahan!.isEmpty) {
          _selectedKelurahan = null;
        }
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
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse(Server.network + "api/update_tamu.php");
      var request = http.MultipartRequest("POST", uri);
      request.fields['id'] = widget.id;
      request.fields['tanggal'] = tanggalController!.text;
      request.fields['nama'] = namaTamuController!.text;
      request.fields['alamat'] = alamatController!.text;
      request.fields['id_kelurahan'] = _selectedKelurahan!['id'].toString();
      request.fields['id_kecamatan'] = _selectedKecamatan!['id'].toString();
      request.fields['no_hp'] = noHpController!.text;
      request.fields['tujuan'] = tujuanController!.text;
      request.fields['foto'] = widget.foto;
      request.fields['id_pegawai'] = _selectedPegawai!['id']
          .toString(); // Tambahkan selected untuk pegawai
      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Data Berhasil Dikirim');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diupdate.'),
          ),
        );
        Navigator.pop(context, true); // Return true on successful upload
      } else {
        print('Data Gagal Dikirim');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data gagal diupdate.'),
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
        title: Text("Edit Tamu"),
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
                          ? widget.foto.isEmpty
                              ? Text(
                                  "Tolong Upload Gambar",
                                  style: TextStyle(color: Colors.red),
                                )
                              : Image.network(
                                  Server.network + "uploads/" + widget.foto)
                          : Image.file(_image ?? File("path_to_default_image")),
                    ),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Palette.primaryColor,
                        fixedSize: Size(
                            (screenWidth / 3) * 1.3, (screenWidth / 20) * 1.5),
                      ),
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
                          borderRadius: new BorderRadius.circular(5.0),
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                TextFormField(
                  controller: namaTamuController,
                  decoration: new InputDecoration(
                    hintText: "Isi Nama Tamu",
                    labelText: "Nama Tamu",
                    border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
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
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
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
                  items: widget.kecamatanList,
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
                  items: _kelurahanList,
                  onFind: (String? filter) async {
                    return _kelurahanList
                        .where((kelurahan) => kelurahan['nama']
                            .toLowerCase()
                            .contains(filter!.toLowerCase()))
                        .toList();
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
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
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
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
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
                  items: widget.pegawaiList,
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Palette.primaryColor,
                    fixedSize: Size(screenWidth, 54.0),
                  ),
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      uploadImage();
                    } else if (widget.foto.isEmpty && _image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tolong upload gambar.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
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
        tanggalController!.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }
}

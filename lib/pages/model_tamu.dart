class ModelTamu {
  String? id;
  String? tanggal;
  String? nama;
  String? alamat;
  String? kelurahan;
  String? kecamatan;
  String? noHp;
  String? tujuan;
  String? foto;
  String? namaPegawai; // Tambahkan properti ini

  ModelTamu({
    this.id,
    this.tanggal,
    this.nama,
    this.alamat,
    this.kelurahan,
    this.kecamatan,
    this.noHp,
    this.tujuan,
    this.foto,
    this.namaPegawai, // Inisialisasi properti ini
  });

  ModelTamu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tanggal = json['tanggal'];
    nama = json['nama'];
    alamat = json['alamat'];
    kelurahan = json['kelurahan'];
    kecamatan = json['kecamatan'];
    noHp = json['no_hp'];
    tujuan = json['tujuan'];
    foto = json['foto'];
    namaPegawai = json['nama_pegawai']; // Mapping dari JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tanggal'] = this.tanggal;
    data['nama'] = this.nama;
    data['alamat'] = this.alamat;
    data['kelurahan'] = this.kelurahan;
    data['kecamatan'] = this.kecamatan;
    data['no_hp'] = this.noHp;
    data['tujuan'] = this.tujuan;
    data['foto'] = this.foto;
    data['nama_pegawai'] = this.namaPegawai; // Tambahkan ke mapping JSON
    return data;
  }
}

class ModelKelurahan {
  final int id;
  final String nama;
  final int kecamatanId;

  ModelKelurahan(
      {required this.id, required this.nama, required this.kecamatanId});

  factory ModelKelurahan.fromJson(Map<String, dynamic> json) {
    return ModelKelurahan(
      id: json['id'],
      nama: json['nama'],
      kecamatanId: json['kecamatan_id'],
    );
  }
}

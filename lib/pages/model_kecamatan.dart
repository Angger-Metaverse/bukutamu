class ModelKecamatan {
  final int id;
  final String nama;

  ModelKecamatan({required this.id, required this.nama});

  factory ModelKecamatan.fromJson(Map<String, dynamic> json) {
    return ModelKecamatan(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

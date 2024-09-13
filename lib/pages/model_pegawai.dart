class ModelPegawai {
  String? id;
  String? namaPegawai;
  String? noWhatsapp;

  ModelPegawai({this.id, this.namaPegawai, this.noWhatsapp});

  ModelPegawai.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaPegawai = json['nama_pegawai'];
    noWhatsapp = json['no_whatsapp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama_pegawai'] = this.namaPegawai;
    data['no_whatsapp'] = this.noWhatsapp;
    return data;
  }
}

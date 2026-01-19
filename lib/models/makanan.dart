class Makanan {
  final String id;
  final String nama;
  final String deskripsi;
  final double harga;
  final String kategori;
  final String imageUrl;

  Makanan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.imageUrl,
  });

  // 1. Konversi dari Map (Database/JSON) ke Object Makanan
  // Ditambahkan validasi nilai default agar tidak error jika ada data null
  factory Makanan.fromMap(Map<String, dynamic> map) {
    return Makanan(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      harga: (map['harga'] is int)
          ? (map['harga'] as int).toDouble()
          : (map['harga'] ?? 0.0),
      kategori: map['kategori'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // 2. Konversi dari Object Makanan ke Map (Untuk disimpan ke SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'imageUrl': imageUrl,
    };
  }

  // 3. Method copyWith (Sangat berguna untuk fitur UPDATE/Edit data)
  // Menambahkan parameter opsional agar hanya field tertentu yang diubah
  Makanan copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    double? harga,
    String? kategori,
    String? imageUrl,
  }) {
    return Makanan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      kategori: kategori ?? this.kategori,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

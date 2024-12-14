class Hotel {
  final int id;
  final String namaHotel;
  final String kategori;
  final String alamat;
  final String harga;
  final String imageUrl;
  final String deskripsi;
  final String no_hp;

  /// Konstruktor untuk membuat instance dari [Hotel].
  Hotel({
    required this.id,
    required this.namaHotel,
    required this.kategori,
    required this.alamat,
    required this.harga,
    required this.imageUrl,
    required this.deskripsi,
    required this.no_hp,
    
  });

  /// Factory method untuk membuat instance [Hotel] dari JSON.
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      namaHotel: json['nama_hotel'],
      kategori: json['kategori'],
      alamat: json['alamat'],
      harga: json['harga'],
      imageUrl: json['image_url'],
      deskripsi: json['deskripsi'],
      no_hp: json['no_hp'],
      
    );
  }
}

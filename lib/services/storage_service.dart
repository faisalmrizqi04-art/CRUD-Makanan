import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/makanan.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const String _key = 'makanan_list';

  // Inisialisasi - Pastikan dipanggil di main.dart sebelum runApp
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ambil semua makanan (Read)
  static Future<List<Makanan>> getAllMakanan() async {
    try {
      final jsonString = _prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) return [];

      // Perbaikan: Pastikan hasil decode adalah List
      final dynamic decodedData = jsonDecode(jsonString);
      if (decodedData is List) {
        return decodedData
            .map((e) => Makanan.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      // Log error jika perlu: print('Error getAllMakanan: $e');
      return [];
    }
  }

  // Tambah makanan baru (Create)
  static Future<void> addMakanan(Makanan makanan) async {
    try {
      final makananList = await getAllMakanan();
      makananList.add(makanan);
      await _saveMakanan(makananList);
    } catch (e) {
      throw Exception('Gagal menambah makanan: $e');
    }
  }

  // Perbarui makanan (Update)
  static Future<void> updateMakanan(Makanan makanan) async {
    try {
      final makananList = await getAllMakanan();
      final index = makananList.indexWhere((m) => m.id == makanan.id);

      if (index != -1) {
        makananList[index] = makanan;
        await _saveMakanan(makananList);
      } else {
        throw Exception('Data makanan tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Gagal mengupdate makanan: $e');
    }
  }

  // Hapus makanan (Delete)
  static Future<void> deleteMakanan(String id) async {
    try {
      final makananList = await getAllMakanan();
      // Menggunakan length sebelum dan sesudah untuk validasi
      final initialLength = makananList.length;
      makananList.removeWhere((m) => m.id == id);

      if (initialLength != makananList.length) {
        await _saveMakanan(makananList);
      }
    } catch (e) {
      throw Exception('Gagal menghapus makanan: $e');
    }
  }

  // Cari makanan berdasarkan ID
  static Future<Makanan?> getMakananById(String id) async {
    try {
      final makananList = await getAllMakanan();
      // Perbaikan: Gunakan cast .firstWhereOrNull (jika pakai collection)
      // atau manual seperti ini agar lebih efisien:
      for (var item in makananList) {
        if (item.id == id) return item;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Hapus semua data
  static Future<void> deleteAllMakanan() async {
    try {
      await _prefs.remove(_key);
    } catch (e) {
      throw Exception('Gagal menghapus semua data: $e');
    }
  }

  // Helper - Fungsi internal untuk simpan ke SharedPreferences
  static Future<void> _saveMakanan(List<Makanan> makananList) async {
    try {
      final String jsonString = jsonEncode(
        makananList.map((m) => m.toMap()).toList(),
      );
      await _prefs.setString(_key, jsonString);
    } catch (e) {
      throw Exception('Gagal menyimpan ke storage: $e');
    }
  }
}

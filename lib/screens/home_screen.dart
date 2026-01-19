import 'package:flutter/material.dart';
import '../models/makanan.dart';
import '../services/storage_service.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Inisialisasi Future agar tidak null
  late Future<List<Makanan>> _makananList;

  @override
  void initState() {
    super.initState();
    _loadMakanan();
  }

  // 2. PERBAIKAN: Fungsi ini harus memberikan nilai ke _makananList
  void _loadMakanan() {
    setState(() {
      _makananList = StorageService.getAllMakanan();
    });
  }

  void _goTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _loadMakanan());
  }

  void _deleteMakanan(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus'),
        content: const Text('Yakin ingin menghapus makanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.deleteMakanan(id);
              if (!mounted) return;
              Navigator.pop(ctx);
              _loadMakanan(); // Refresh list setelah hapus
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Makanan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Makanan>>(
        future: _makananList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data makanan.\nKlik + untuk menambah.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) =>
                              const Icon(Icons.fastfood),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.orange.shade100,
                          child: Center(child: Text(item.nama[0])),
                        ),
                ),
                title: Text(
                  item.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Rp ${item.harga.toStringAsFixed(0)}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') _goTo(AddEditScreen(makanan: item));
                    if (val == 'hapus') _deleteMakanan(item.id);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                  ],
                ),
                onTap: () => _goTo(DetailScreen(makanan: item)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goTo(const AddEditScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/makanan.dart';
import '../services/storage_service.dart';

class AddEditScreen extends StatefulWidget {
  final Makanan? makanan;

  const AddEditScreen({Key? key, this.makanan}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaController;
  late TextEditingController _imageUrlController;
  late String _kategori;
  final _formKey = GlobalKey<FormState>();

  final List<String> _kategoriList = ['Makanan', 'Minuman', 'Dessert', 'Snack'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.makanan?.nama ?? '');
    _deskripsiController = TextEditingController(
      text: widget.makanan?.deskripsi ?? '',
    );
    _hargaController = TextEditingController(
      text: widget.makanan?.harga.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.makanan?.imageUrl ?? '',
    );
    _kategori = widget.makanan?.kategori ?? 'Makanan';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveMakanan() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final makanan = widget.makanan != null
          ? widget.makanan!.copyWith(
              nama: _namaController.text,
              deskripsi: _deskripsiController.text,
              harga: double.parse(_hargaController.text),
              kategori: _kategori,
              imageUrl: _imageUrlController.text,
            )
          : Makanan(
              id: const Uuid().v4(),
              nama: _namaController.text,
              deskripsi: _deskripsiController.text,
              harga: double.parse(_hargaController.text),
              kategori: _kategori,
              imageUrl: _imageUrlController.text,
            );

      if (widget.makanan != null) {
        await StorageService.updateMakanan(makanan);
      } else {
        await StorageService.addMakanan(makanan);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Makanan berhasil ${widget.makanan != null ? 'diupdate' : 'ditambahkan'}',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.makanan != null ? 'Edit Makanan' : 'Tambah Makanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Makanan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Deskripsi tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Harga tidak boleh kosong';
                  if (double.tryParse(value ?? '') == null)
                    return 'Harga harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _kategoriList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _kategori = value ?? 'Makanan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'URL tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveMakanan,
                  child: Text(widget.makanan != null ? 'Update' : 'Tambahkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

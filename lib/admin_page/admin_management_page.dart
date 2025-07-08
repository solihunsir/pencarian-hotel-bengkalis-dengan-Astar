import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Halaman untuk manajemen hotel oleh admin.
class AdminManagementPage extends StatefulWidget {
  @override
  _AdminManagementPageState createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage>
    with SingleTickerProviderStateMixin {
  static const String URL_READ =
      'http://192.168.0.132/hotel_bengkalis/api/read_hotel.php';
  static const String URL_CREATE =
      'http://192.168.0.132/hotel_bengkalis/api/create_hotel.php';
  static const String URL_UPDATE =
      'http://192.168.0.132/hotel_bengkalis/api/update_hotel.php';
  static const String URL_DELETE_BASE =
      'http://192.168.0.132/hotel_bengkalis/api/delete_hotel.php?id=';

  List _recipes = [];
  List _filteredRecipes = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Hotel', 'Wisma'];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isSuccess) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _fetchRecipes() async {
    try {
      final response = await http.get(Uri.parse(URL_READ));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _recipes = json.decode(response.body)['data'];
            _filterRecipes();
          });
        }
      } else {
        _showSnackBar('Gagal memuat hotel', false);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat memuat hotel', false);
    }
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _recipes.where((recipe) {
        final nameMatch = recipe['nama_hotel']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final categoryMatch = _selectedCategory == 'Semua' ||
            recipe['kategori'] == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();
    });
  }

  Future<void> _createRecipe(Map<String, String> recipe) async {
    var request = http.MultipartRequest('POST', Uri.parse(URL_CREATE));
    recipe.forEach((key, value) {
      request.fields[key] = value;
    });
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        _showSnackBar('Hotel berhasil ditambahkan', true);
        _fetchRecipes();
      } else {
        _showSnackBar('Gagal menambahkan hotel', false);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat menambahkan hotel', false);
    }
  }

  Future<void> _updateRecipe(Map<String, String> recipe) async {
    var request = http.MultipartRequest('POST', Uri.parse(URL_UPDATE));
    recipe.forEach((key, value) {
      request.fields[key] = value;
    });
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        _showSnackBar('Hotel berhasil diperbarui', true);
        _fetchRecipes();
      } else {
        _showSnackBar('Gagal memperbarui hotel', false);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat memperbarui hotel', false);
    }
  }

  Future<void> _deleteRecipe(int id) async {
    try {
      final response = await http.get(Uri.parse('$URL_DELETE_BASE$id'));
      if (response.statusCode == 200) {
        _showSnackBar('Hotel berhasil dihapus', true);
        _fetchRecipes();
      } else {
        _showSnackBar('Gagal menghapus hotel', false);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat menghapus hotel', false);
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Penghapusan"),
          content: Text("Apakah kamu yakin ingin menghapus hotel ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Hapus"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecipe(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _showRecipeDialog({Map<String, dynamic>? recipe}) {
    final TextEditingController idController =
        TextEditingController(text: recipe?['id']?.toString() ?? '');
    final TextEditingController nameController =
        TextEditingController(text: recipe?['nama_hotel']);
    final TextEditingController categoryController =
        TextEditingController(text: recipe?['kategori']);
    final TextEditingController alamatController =
        TextEditingController(text: recipe?['alamat']);
    final TextEditingController hargaController =
        TextEditingController(text: recipe?['harga']);
    final TextEditingController deskripsiController =
        TextEditingController(text: recipe?['deskripsi']);
    final TextEditingController nohpController =
        TextEditingController(text: recipe?['no_hp']);
    final TextEditingController imageUrlController =
        TextEditingController(text: recipe?['image_url']);

    String selectedCategory = recipe?['kategori'] ?? _categories[1];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(recipe == null ? 'Tambah hotel' : 'Ubah hotel'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: idController,
                  decoration: InputDecoration(labelText: 'ID'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama hotel'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(labelText: 'Kategori'),
                  items: _categories.skip(1).map((String category) {
                    return DropdownMenuItem<String>( 
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedCategory = newValue!;
                  },
                ),
                TextField(
                  controller: alamatController,
                  decoration: InputDecoration(labelText: 'Alamat'),
                ),
                TextField(
                  controller: hargaController,
                  decoration: InputDecoration(labelText: 'Harga'),
                ),
                TextField(
                  controller: deskripsiController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
                TextField(
                  controller: nohpController,
                  decoration: InputDecoration(labelText: 'No Handphone'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final int id = int.tryParse(idController.text) ?? 0;
                final Map<String, String> newRecipe = {
                  'id': id.toString(),
                  'nama_hotel': nameController.text,
                  'kategori': selectedCategory,
                  'alamat': alamatController.text,
                  'harga': hargaController.text,
                  'deskripsi': deskripsiController.text,
                  'no_hp': nohpController.text,
                  'image_url': imageUrlController.text,
                };
                if (recipe == null) {
                  _createRecipe(newRecipe);
                } else {
                  _updateRecipe(newRecipe);
                }
                Navigator.pop(context);
              },
              child: Text(recipe == null ? 'Tambah' : 'Ubah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manajemen Hotel")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterRecipes();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Cari hotel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showRecipeDialog(),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                return ListTile(
                  title: Text(recipe['nama_hotel']),
                  subtitle: Text(recipe['kategori']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () =>
                        _showDeleteConfirmation(recipe['id']),
                  ),
                  onTap: () => _showRecipeDialog(recipe: recipe),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

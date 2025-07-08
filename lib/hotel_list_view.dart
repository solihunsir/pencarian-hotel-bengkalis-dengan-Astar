import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotel_bengkalis/map_screen.dart';
import 'package:http/http.dart' as http;
import 'package:string_extensions/string_extensions.dart';
import 'about_developer.dart';
import 'detail_hotel.dart';
import 'hotel.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class HotelListView extends StatefulWidget {
  final String username; // Menambahkan parameter username

  const HotelListView({Key? key, required this.username}) : super(key: key);

  @override
  HotelListViewState createState() => HotelListViewState();
}

class HotelListViewState extends State<HotelListView> {
  static const String URL = 'http://192.168.0.132/hotel_bengkalis/api/read_hotel.php';
  late Future<List<Hotel>> result_data;
  int _selectedIndex = 0;
  String _selectedCategory = 'hotel';
  bool _isGridView = false;
  final Color primaryColor = Color(0xFF1A237E);
  final Color accentColor = Color(0x7A989290);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedFilter = 'Harga Tertinggi';
  
  get highlightColor => null;

  @override
  void initState() {
    super.initState();
    result_data = _fetchHotel();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _selectedCategory = 'hotel';
          break;
        case 1:
          _selectedCategory = 'wisma';
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
          return;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutDeveloper()),
          );
          return;
      }
      result_data = _fetchHotel();
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'HOTEL BENGKALIS',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Image.network(
                'https://images.unsplash.com/photo-1614590370666-22e7beade570?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8aG9tZSUyMHN0YXl8ZW58MHx8MHx8fDA%3D',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Hotel & Wisma ...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular ${_selectedCategory.capitalize}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: <String>['Harga Tertinggi', 'Harga Terendah']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    onPressed: _toggleView,
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Hotel>>(
            future: result_data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text("Error: ${snapshot.error}")),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text("No data available")),
                );
              } else {
                List<Hotel> filteredData = snapshot.data!.where((hotel) {
                  return hotel.kategori.toLowerCase() == _selectedCategory &&
                      (hotel.namaHotel
                              .toLowerCase()
                              .contains(_searchText.toLowerCase()) ||
                          _searchText.isEmpty);
                }).toList();

                if (_selectedFilter == 'Harga Tertinggi') {
                  filteredData.sort((a, b) =>
                      _parsePrice(b.harga).compareTo(_parsePrice(a.harga)));
                } else {
                  filteredData.sort((a, b) =>
                      _parsePrice(a.harga).compareTo(_parsePrice(b.harga)));
                }

                return _isGridView
                    ? _hotelGridView(filteredData)
                    : _hotelListView(filteredData);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        primaryColor: primaryColor,
        accentColor: accentColor,
      ),
    );
  }

  Future<List<Hotel>> _fetchHotel() async {
    var uri = Uri.parse(URL);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List jsonData = jsonResponse['data'];
        return jsonData.map((hotel) => Hotel.fromJson(hotel)).toList();
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  int _parsePrice(String price) {
    String sanitizedPrice = price.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(sanitizedPrice) ?? 0;
  }

  SliverList _hotelListView(List<Hotel> data) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _tile(context, data[index]),
        childCount: data.length,
      ),
    );
  }

  SliverGrid _hotelGridView(List<Hotel> data) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _gridTile(context, data[index]),
        childCount: data.length,
      ),
    );
  }

  Widget _tile(BuildContext context, Hotel data) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToDetail(context, data),
        child: Container(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Image.network(
                  data.imageUrl,
                  width: 140,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.namaHotel,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rp. ${data.harga}',
                        style: TextStyle(
                          fontSize: 16,
                          color: highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          data.alamat,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridTile(BuildContext context, Hotel data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToDetail(context, data),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                data.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.namaHotel,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Rp. ${data.harga}',
                    style: TextStyle(
                      fontSize: 14,
                      color: highlightColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    data.alamat,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Hotel data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHotel(data: data),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color primaryColor;
  final Color accentColor;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.primaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Hotel',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Wisma',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_pin),
          label: 'Peta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Tentang',
        ),
      ],
      selectedItemColor: primaryColor,
      unselectedItemColor: accentColor,
    );
  }
}

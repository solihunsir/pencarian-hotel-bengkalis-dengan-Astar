import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'hotel.dart';

class DetailHotel extends StatelessWidget {
  final Hotel data;
  final Color primaryColor = Color(0xFF1A237E);
  final Color accentColor = Color(0xFF1A237E);
  final Color backgroundColor = Color(0xFFF5F5F5);

  DetailHotel({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                data.namaHotel,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.hotel,
                      color: accentColor,
                      size: 100,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard("Kategori", data.kategori, Icons.category),
                  SizedBox(height: 16),
                  _buildSectionCard(
                      "Deskripsi", data.deskripsi, Icons.description),
                  SizedBox(height: 16),
                  _buildSectionCard("Alamat", data.alamat, Icons.location_pin),
                  SizedBox(height: 16),
                  _buildSectionCard(
                      "Harga", "Rp ${data.harga}", Icons.monetization_on),
                  SizedBox(height: 16),
                  _buildSectionCard(
                      "No Handphone", data.no_hp, Icons.phone),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: accentColor),
            SizedBox(width: 12),
            Text(
              "$title: $content",
              style: TextStyle(
                fontSize: 16.0,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(color: backgroundColor),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }


}

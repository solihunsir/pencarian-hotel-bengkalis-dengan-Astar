import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_bengkalis/admin_page/admin_login_page.dart';
import 'package:hotel_bengkalis/admin_page/admin_management_page.dart';
import 'package:hotel_bengkalis/login_page.dart';

class Developer {
  final String name;
  final String role;
  final String quote;
  final String profileImageUrl;
  final String backgroundImageUrl;

  Developer({
    required this.name,
    required this.role,
    required this.quote,
    required this.profileImageUrl,
    required this.backgroundImageUrl,
  });
}

class AboutDeveloper extends StatefulWidget {
  const AboutDeveloper({Key? key}) : super(key: key);

  @override
  State<AboutDeveloper> createState() => _AboutDeveloperState();
}

class _AboutDeveloperState extends State<AboutDeveloper> {
  int _currentDeveloperIndex = 0;
  final Color primaryColor = Color(0xFF1A4B8D); // Enhanced primary color
  final Color accentColor = Color(0xFFFF6B6B); // Softer accent color
  final Color backgroundColor = Color(0xFFF0F4F8); // Lighter background
  String username = '';  

  final List<Developer> _developers = [
    Developer(
      name: 'Hotel Kecamatan Bengkalis',
      role: 'Menjadi Wisatawan yang Cerdas untuk Mencari Akomodasi',
      quote: 'Temukan Kenyamanan dan Keindahan di Bengkalis, Riau',
      profileImageUrl: 'assets/images/logoh.png',
      backgroundImageUrl: 'assets/images/hotel.png',
    ),
  ];
 
  void _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app_rounded,
                  color: accentColor,
                  size: 60,
                ),
                SizedBox(height: 20),
                Text(
                  'Konfirmasi Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Keluar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((confirmLogout) async {
      if (confirmLogout ?? false) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('username');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    });
  }
 
  void _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Pengguna';  
    });
  }

  @override
  void initState() {
    super.initState();
    _getUsername();  
  }

  void _navigateToLoginPage() async {
    bool? isAuthenticated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginPage()),
    );
    if (isAuthenticated ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminManagementPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Developer currentDeveloper = _developers[_currentDeveloperIndex];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Hai, ',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              username,  
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,  
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onLongPress: _navigateToLoginPage,
                    child: Hero(
                      tag: 'profileImage',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage:
                                AssetImage(currentDeveloper.profileImageUrl),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    currentDeveloper.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentDeveloper.role,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.format_quote,
                              color: accentColor, size: 40),
                          SizedBox(height: 8),
                          Text(
                            currentDeveloper.quote,
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

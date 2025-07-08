import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_bengkalis/auth_service.dart';
import 'package:hotel_bengkalis/hotel_list_view.dart';
import 'package:hotel_bengkalis/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  int _loginAttempts = 0; 
  DateTime? _lockoutTime; 
  bool _isInputEnabled = true; 

  void _showProfessionalNotification({
    required BuildContext context, 
    required String message, 
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle, 
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent[700] : Colors.greenAccent[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _login() async {
    if (_lockoutTime != null && DateTime.now().isBefore(_lockoutTime!)) {
      final remainingTime = _lockoutTime!.add(Duration(minutes: 5)).difference(DateTime.now()).inMinutes;
      _showProfessionalNotification(
        context: context,
        message: 'Anda harus menunggu $remainingTime menit lagi untuk mencoba login.',
        isError: true,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response['status'] == 'success') {
        String username = response['username'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);

        _showProfessionalNotification(
          context: context, 
          message: 'Selamat datang, $username!',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HotelListView(username: username),
          ),
        );

        _loginAttempts = 0;
        _lockoutTime = null;
        _isInputEnabled = true; 
      } else {
        _loginAttempts++;
        if (_loginAttempts >= 5) {
          _lockoutTime = DateTime.now(); 
          _isInputEnabled = false; 
          _showProfessionalNotification(
            context: context, 
            message: 'Anda telah mencoba login 5 kali gagal. Silakan tunggu 5 menit.',
            isError: true,
          );

          Future.delayed(Duration(minutes: 1), () {
            setState(() {
              _isInputEnabled = true; 
              _loginAttempts = 0; 
              _lockoutTime = null; 
            });
          });
        } else {
          _showProfessionalNotification(
            context: context, 
            message: 'Kesalahan login! Kesempatan tinggal ${5 - _loginAttempts} kali.',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal[800]!, 
              Colors.tealAccent[200]!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 12,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logoh.png', 
                          height: 100,  
                          width: 100,  
                          fit: BoxFit.cover,  
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hotel Bengkalis',
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: Icon(Icons.email, color: Colors.teal[800]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.teal[800]!, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email harus diisi';
                          }
                          if (!value.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                        enabled: _isInputEnabled, 
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: Icon(Icons.lock, color: Colors.teal[800]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: Colors.teal[800],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.teal[800]!, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password harus diisi';
                          }
                          if (value.length < 8) {
                            return 'Password harus minimal 8 karakter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password harus mengandung angka';
                          }
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password harus mengandung simbol';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password harus mengandung huruf kapital';
                          }
                          return null;
                        },
                        enabled: _isInputEnabled, 
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                            )
                          : ElevatedButton(
                              onPressed: _isInputEnabled ? _login : null, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60, 
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Belum punya akun? Daftar di sini',
                          style: GoogleFonts.poppins(
                            color: Colors.teal[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

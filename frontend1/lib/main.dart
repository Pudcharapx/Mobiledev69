import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Backend1App());

class Backend1App extends StatelessWidget {
  const Backend1App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Backend 1 JWT',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const LoginPage(),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _apiBaseUrl = 'http://127.0.0.1:8000';
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _dio = Dio();
  String? _accessToken;
  String _message = 'Sign in with a Backend 1 Django account.';
  List<dynamic> _bookings = [];
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _message = 'Signing in…';
    });
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiBaseUrl/api/token/',
        data: {'username': _username.text, 'password': _password.text},
      );
      _accessToken = response.data!['access'] as String;
      setState(() => _message = 'Signed in. Access token received.');
      await _loadBookings();
    } on DioException catch (error) {
      setState(() => _message =
          'Sign-in failed: ${error.response?.statusCode ?? error.message}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadBookings() async {
    if (_accessToken == null) return;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_apiBaseUrl/api/bookings/',
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );
      setState(() {
        _bookings = response.data!['bookings'] as List<dynamic>;
        _message = 'Loaded protected bookings successfully.';
      });
    } on DioException catch (error) {
      setState(() => _message = 'Could not load bookings: ${error.message}');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Frontend 1 · JWT')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _signIn,
                  child: Text(_loading ? 'Please wait…' : 'Sign in'),
                ),
                const SizedBox(height: 20),
                Text(_message),
                for (final booking in _bookings)
                  Card(
                    child: ListTile(
                      title: Text(booking['destination_name'] as String),
                      subtitle: Text('฿${booking['price']}'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Backend1App());

class Backend1App extends StatelessWidget {
  const Backend1App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Week 14 Demo',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
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
  String? _refreshToken;

  String _message = '';
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
      _accessToken = null;
      _refreshToken = null;
      _bookings = [];
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiBaseUrl/api/token/',
        data: {
          'username': _username.text,
          'password': _password.text,
        },
      );

      final data = response.data;

      if (data == null) {
        setState(() {
          _message = 'Sign-in failed: Empty response from server.';
        });
        return;
      }

      setState(() {
        _accessToken = data['access'] as String?;
        _refreshToken = data['refresh'] as String?;

        if (_accessToken != null && _refreshToken != null) {
          _message = 'Signed in. Access token and refresh token received.';
        } else if (_accessToken != null) {
          _message = 'Signed in. Access token received, but refresh token was not found.';
        } else {
          _message = 'Sign-in failed: Access token was not found.';
        }
      });

      await _loadBookings();
    } on DioException catch (error) {
      setState(() {
        _message =
            'Sign-in failed: ${error.response?.statusCode ?? error.message}';
      });
    } catch (error) {
      setState(() {
        _message = 'Sign-in failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadBookings() async {
    if (_accessToken == null) return;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_apiBaseUrl/api/bookings/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );

      final data = response.data;

      if (data == null) {
        setState(() {
          _message = 'Could not load bookings: Empty response from server.';
        });
        return;
      }

      setState(() {
        _bookings = data['bookings'] as List<dynamic>;
        _message = 'Loaded protected bookings successfully.';
      });
    } on DioException catch (error) {
      setState(() {
        _message = 'Could not load bookings: ${error.message}';
      });
    } catch (error) {
      setState(() {
        _message = 'Could not load bookings: $error';
      });
    }
  }

  Widget _buildTokenCard({
    required String title,
    required String? token,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: SelectableText(
                token ?? 'ยังไม่มี Token',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Frontend 1 · JWT'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _signIn,
                  child: Text(
                    _loading ? 'Please wait…' : 'Sign in',
                  ),
                ),
                const SizedBox(height: 20),

                // Message
                Text(
                  _message,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                // Access Token
                if (_accessToken != null)
                  _buildTokenCard(
                    title: 'Access Token',
                    token: _accessToken,
                  ),

                // Refresh Token
                if (_refreshToken != null)
                  _buildTokenCard(
                    title: 'Refresh Token',
                    token: _refreshToken,
                  ),

                const SizedBox(height: 8),

                // Bookings
                for (final booking in _bookings)
                  Card(
                    child: ListTile(
                      title: Text(
                        booking['destination_name'] as String,
                      ),
                      subtitle: Text(
                        '฿${booking['price']}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

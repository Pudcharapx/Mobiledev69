import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

import 'oidc_configuration.dart';

void main() => runApp(const Backend2App());

class Backend2App extends StatelessWidget {
  const Backend2App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Backend 2 OIDC',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const OidcLoginPage(),
      );
}

class OidcLoginPage extends StatefulWidget {
  const OidcLoginPage({super.key, this.autoReadCallback = true});

  final bool autoReadCallback;

  @override
  State<OidcLoginPage> createState() => _OidcLoginPageState();
}

class _OidcLoginPageState extends State<OidcLoginPage> {
  static final _issuerUri = Uri.parse(oidcIssuerUrl);
  String _status = 'Not signed in.';
  Map<String, dynamic>? _claims;

  @override
  void initState() {
    super.initState();
    if (widget.autoReadCallback) _readCallback();
  }

  Future<void> _readCallback() async {
    try {
      final issuer = await Issuer.discover(_issuerUri);
      final authenticator = Authenticator(
        Client(issuer, oidcClientId),
        scopes: const ['openid', 'profile', 'email'],
      );
      final credential = await authenticator.credential;
      if (credential != null && mounted) {
        setState(() {
          _claims = credential.idToken.claims.toJson();
          _status = 'OpenID Connect sign-in succeeded.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _status = 'Could not complete sign-in: $error');
    }
  }

  Future<void> _signIn() async {
    try {
      final issuer = await Issuer.discover(_issuerUri);
      final authenticator = Authenticator(
        Client(issuer, oidcClientId),
        scopes: const ['openid', 'profile', 'email'],
      );
      authenticator.authorize();
    } catch (error) {
      setState(() => _status = 'Could not start sign-in: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Frontend 2 · OpenID Connect')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Provider: http://127.0.0.1:8001'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _signIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Backend 2'),
                ),
                const SizedBox(height: 20),
                Text(_status),
                if (_claims != null) ...[
                  const SizedBox(height: 16),
                  const Text('ID-token claims', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SelectableText(_claims.toString()),
                ],
              ],
            ),
          ),
        ),
      );
}

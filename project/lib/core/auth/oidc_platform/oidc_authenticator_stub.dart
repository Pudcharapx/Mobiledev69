import 'package:openid_client/openid_client.dart';

/// Fallback / stub authenticator for non-web environments or tests.
Future<Credential?> authenticateBrowser(
  Client client,
  List<String> scopes,
) async {
  return null;
}

void authorizeBrowser(
  Client client,
  List<String> scopes,
) {
  // No-op on stub
}

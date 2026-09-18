import 'package:openid_client/openid_client.dart';

/// Fallback / stub authenticator for non-web environments or tests.
Future<Credential?> authenticateBrowser(
  Client client,
  List<String> scopes, {
  Uri? redirectUri,
}) async {
  return null;
}

void authorizeBrowser(
  Client client,
  List<String> scopes, {
  Uri? redirectUri,
}) {
  // No-op on stub
}

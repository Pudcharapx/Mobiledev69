import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;

/// Web browser authenticator utilizing `openid_client_browser`.
Future<Credential?> authenticateBrowser(
  Client client,
  List<String> scopes, {
  Uri? redirectUri,
}) async {
  final authenticator = browser.Authenticator(client, scopes: scopes);
  if (redirectUri != null) {
    authenticator.flow.redirectUri = redirectUri;
  }
  return authenticator.credential;
}

void authorizeBrowser(
  Client client,
  List<String> scopes, {
  Uri? redirectUri,
}) {
  final authenticator = browser.Authenticator(client, scopes: scopes);
  if (redirectUri != null) {
    authenticator.flow.redirectUri = redirectUri;
  }
  authenticator.authorize();
}

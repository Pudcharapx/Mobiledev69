import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;

/// Web browser authenticator utilizing `openid_client_browser`.
Future<Credential?> authenticateBrowser(
  Client client,
  List<String> scopes,
) async {
  final authenticator = browser.Authenticator(client, scopes: scopes);
  return authenticator.credential;
}

void authorizeBrowser(
  Client client,
  List<String> scopes,
) {
  final authenticator = browser.Authenticator(client, scopes: scopes);
  authenticator.authorize();
}

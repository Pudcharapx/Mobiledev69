import 'package:flutter_test/flutter_test.dart';
import 'package:frontend2/oidc_configuration.dart';

void main() {
  test('uses the Backend 2 OIDC provider and registered client', () {
    expect(oidcIssuerUrl, 'http://127.0.0.1:8001');
    expect(oidcClientId, 'mobiledev-frontend2');
  });
}

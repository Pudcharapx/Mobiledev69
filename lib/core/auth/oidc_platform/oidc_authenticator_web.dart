import 'dart:js_interop';
import 'dart:math';
import 'package:openid_client/openid_client.dart';
import 'package:web/web.dart' as web;

/// Random secure alphanumeric string generator for OIDC state & PKCE verifier.
String _randomString(int length) {
  const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final r = Random.secure();
  return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
}

const _kStateKey = 'dormmate:oidc:state';
const _kVerifierKey = 'dormmate:oidc:verifier';
const _kRedirectKey = 'dormmate:oidc:redirect_uri';

/// Web browser authenticator utilizing standard OIDC Authorization Code Flow + PKCE.
Future<Credential?> authenticateBrowser(
  Client client,
  List<String> scopes, {
  Uri? redirectUri,
}) async {
  final currentUri = Uri.parse(web.window.location.href);
  final queryParams = currentUri.queryParameters.containsKey('code')
      ? currentUri.queryParameters
      : (currentUri.fragment.isNotEmpty
          ? Uri(query: currentUri.fragment).queryParameters
          : const <String, String>{});

  if (!queryParams.containsKey('code')) {
    return null;
  }

  final savedState = web.window.localStorage.getItem(_kStateKey);
  final savedVerifier = web.window.localStorage.getItem(_kVerifierKey);
  final savedRedirect = web.window.localStorage.getItem(_kRedirectKey);

  final state = savedState ?? queryParams['state'];
  final flow = Flow.authorizationCodeWithPKCE(
    client,
    scopes: scopes,
    state: state,
    codeVerifier: savedVerifier,
  );

  if (savedRedirect != null && savedRedirect.isNotEmpty) {
    flow.redirectUri = Uri.parse(savedRedirect);
  } else if (redirectUri != null) {
    flow.redirectUri = redirectUri;
  }

  try {
    final responseMap = Map<String, String>.from(queryParams);
    if (state != null) {
      responseMap['state'] = state;
    }
    final credential = await flow.callback(responseMap);

    web.window.localStorage.removeItem(_kStateKey);
    web.window.localStorage.removeItem(_kVerifierKey);
    web.window.localStorage.removeItem(_kRedirectKey);

    // Reset browser pathname from /callback to / so logout won't detect /callback
    try {
      web.window.history.replaceState(''.toJS, '', '/');
    } catch (_) {}

    return credential;
  } catch (e) {
    return null;
  }
}

/// Redirect browser to OIDC authorization endpoint with PKCE parameters.
void authorizeBrowser(
  Client client,
  List<String> scopes, {
  Uri? redirectUri,
}) {
  final state = _randomString(24);
  final codeVerifier = _randomString(60);

  final flow = Flow.authorizationCodeWithPKCE(
    client,
    scopes: scopes,
    state: state,
    codeVerifier: codeVerifier,
  );
  if (redirectUri != null) {
    flow.redirectUri = redirectUri;
  }

  web.window.localStorage.setItem(_kStateKey, state);
  web.window.localStorage.setItem(_kVerifierKey, codeVerifier);
  web.window.localStorage.setItem(_kRedirectKey, flow.redirectUri.toString());

  web.window.location.href = flow.authenticationUri.toString();
}

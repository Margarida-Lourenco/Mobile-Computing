import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class SupabaseImages {
  static const projectUrl = 'https://zblkhkgpmbgwvcrbhokw.supabase.co';
  static const publishableKey =
      'sb_publishable_RWJ9cG7gipBdtchb4hZU9w_BIhmZAo8';
  static const maxBytes = 5 * 1024 * 1024;
  static final instance = SupabaseImages();
  final http.Client _client;
  final Future<String?> Function(bool) _token;
  final Map<String, ({String url, DateTime expires})> _cache = {};
  SupabaseImages({
    http.Client? client,
    Future<String?> Function(bool)? tokenProvider,
  })  : _client = client ?? http.Client(),
        _token = tokenProvider ?? _firebaseToken;
  static Future<String?> _firebaseToken(bool refresh) async =>
      FirebaseAuth.instance.currentUser?.getIdToken(refresh);

  static String contentType(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw StateError('Choose an image no larger than 5 MB.');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        base64Encode(bytes.sublist(0, 8)) == 'iVBORw0KGgo=') {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      return 'image/webp';
    }
    throw StateError('Choose a JPEG, PNG or WebP image.');
  }

  static bool isReference(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'supabase' &&
        const ['profile-images', 'event-images'].contains(uri.host) &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        uri.userInfo.isEmpty &&
        !uri.hasPort &&
        value == 'supabase://${uri.host}${uri.path}' &&
        RegExp(
          r'^/[A-Za-z0-9_-]{1,128}/[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\.(jpg|png|webp)$',
        ).hasMatch(uri.path);
  }

  Future<Map<String, dynamic>> _request(
    String action,
    Object body, {
    Map<String, String> headers = const {},
    bool allowGuest = false,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final token = await _token(attempt > 0);
      if (token == null && !allowGuest) {
        throw StateError('Sign in before using photos.');
      }
      final response = await _client
          .post(
            Uri.parse('$projectUrl/functions/v1/photo-api?action=$action'),
            headers: {
              'apikey': publishableKey,
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              ...headers,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 401 && attempt == 0 && token != null) continue;
      if (response.statusCode == 404) {
        throw StateError(
          'Photo service is not available yet. Please try again later.',
        );
      }
      Map<String, dynamic> result;
      try {
        result = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw StateError('Photo service could not complete the request.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          result['error'] as String? ?? 'Could not process photo.',
        );
      }
      return result;
    }
    throw StateError('Please sign in again before uploading a photo.');
  }

  Future<String> upload(String bucket, Uint8List bytes) async {
    if (!const ['profile-images', 'event-images'].contains(bucket)) {
      throw ArgumentError('Unknown image bucket.');
    }
    final result = await _request(
      'upload',
      bytes,
      headers: {'Content-Type': contentType(bytes), 'x-image-bucket': bucket},
    );
    final reference = result['reference'] as String;
    if (!isReference(reference)) throw StateError('Invalid image response.');
    return reference;
  }

  Future<String> signedUrl(String reference) async {
    if (!isReference(reference)) {
      throw StateError('This photo needs to be uploaded again.');
    }
    final guestReadable = Uri.parse(reference).host == 'event-images';
    if (!guestReadable && await _token(false) == null) {
      throw StateError('Sign in to view photos.');
    }
    final cached = _cache[reference];
    if (cached != null && cached.expires.isAfter(DateTime.now())) {
      return cached.url;
    }
    final result = await _request('read', jsonEncode({'reference': reference}),
        allowGuest: guestReadable);
    final url = result['url'] as String;
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' ||
        uri.host != Uri.parse(projectUrl).host ||
        !uri.path.startsWith('/storage/v1/object/sign/')) {
      throw StateError('Invalid photo URL.');
    }
    _cache[reference] = (
      url: url,
      expires: DateTime.now().add(const Duration(minutes: 50)),
    );
    return url;
  }

  Future<void> deleteOwned(String? reference) async {
    if (reference == null || !isReference(reference)) return;
    await _request('delete', jsonEncode({'reference': reference}));
    _cache.remove(reference);
  }
}

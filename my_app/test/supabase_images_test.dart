import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:good_together/services/supabase_images.dart';

void main() {
  const reference =
      'supabase://event-images/member/12345678-1234-1234-1234-123456789abc.jpg';
  test('uploads require image magic bytes and reject empty/oversized data', () {
    expect(
      SupabaseImages.contentType(Uint8List.fromList([255, 216, 255])),
      'image/jpeg',
    );
    expect(() => SupabaseImages.contentType(Uint8List(0)), throwsStateError);
    expect(
      () => SupabaseImages.contentType(Uint8List(SupabaseImages.maxBytes + 1)),
      throwsStateError,
    );
    expect(
      () =>
          SupabaseImages.contentType(Uint8List.fromList(utf8.encode('<svg/>'))),
      throwsStateError,
    );
    expect(SupabaseImages.isReference(reference), isTrue);
    expect(SupabaseImages.isReference('$reference?token=x'), isFalse);
    expect(
      SupabaseImages.isReference(
        reference.replaceFirst('event-images', 'unknown'),
      ),
      isFalse,
    );
  });
  test(
      'upload sends the Firebase ID token and binary image, never a privileged key',
      () async {
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer firebase-id-token');
      expect(request.headers['apikey'], SupabaseImages.publishableKey);
      expect(request.headers['x-image-bucket'], 'event-images');
      expect(request.headers['content-type'], 'image/jpeg');
      expect(request.bodyBytes, [255, 216, 255]);
      return http.Response(jsonEncode({'reference': reference}), 200);
    });
    final images = SupabaseImages(
      client: client,
      tokenProvider: (_) async => 'firebase-id-token',
    );
    expect(
      await images.upload('event-images', Uint8List.fromList([255, 216, 255])),
      reference,
    );
  });
  test('signed URLs are cached to avoid repeated function calls', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response(
        jsonEncode({
          'url':
              '${SupabaseImages.projectUrl}/storage/v1/object/sign/event-images/member/photo.jpg?token=temporary',
        }),
        200,
      );
    });
    final images = SupabaseImages(
      client: client,
      tokenProvider: (_) async => 'token',
    );
    final first = await images.signedUrl(reference);
    expect(await images.signedUrl(reference), first);
    expect(calls, 1);
  });
  test(
      'an expired login gets one token refresh; missing deployment reports clearly',
      () async {
    var attempts = 0;
    final refreshes = <bool>[];
    final images = SupabaseImages(
      client: MockClient((request) async {
        attempts++;
        return http.Response(
          jsonEncode({'error': 'not available'}),
          attempts == 1 ? 401 : 404,
        );
      }),
      tokenProvider: (refresh) async {
        refreshes.add(refresh);
        return 'token';
      },
    );
    await expectLater(
      images.upload('event-images', Uint8List.fromList([255, 216, 255])),
      throwsStateError,
    );
    expect(refreshes, [false, true]);
    expect(attempts, 2);
  });
  test(
    'signed-out callers cannot upload, even with the publishable key',
    () async {
      final images = SupabaseImages(
        client: MockClient(
          (_) async => throw StateError('Must not send request'),
        ),
        tokenProvider: (_) async => null,
      );
      await expectLater(
        images.upload('event-images', Uint8List.fromList([255, 216, 255])),
        throwsStateError,
      );
    },
  );
  test('guests can read and cache listing photos without an auth header',
      () async {
    var calls = 0;
    final images = SupabaseImages(
      client: MockClient((request) async {
        calls++;
        expect(request.headers.containsKey('authorization'), isFalse);
        expect(request.url.queryParameters['action'], 'read');
        expect(request.headers['apikey'], SupabaseImages.publishableKey);
        return http.Response(
            jsonEncode({
              'url':
                  '${SupabaseImages.projectUrl}/storage/v1/object/sign/event-images/member/photo.jpg?token=temporary'
            }),
            200);
      }),
      tokenProvider: (_) async => null,
    );
    final url = await images.signedUrl(reference);
    expect(await images.signedUrl(reference), url);
    expect(calls, 1);
    await expectLater(images.deleteOwned(reference), throwsStateError);
    expect(calls, 1);
  });
  test('guest profile reads are blocked even after warming a signed-in cache',
      () async {
    var signedIn = true;
    var calls = 0;
    final profile = reference.replaceFirst('event-images', 'profile-images');
    final images = SupabaseImages(
      client: MockClient((request) async {
        calls++;
        return http.Response(
            jsonEncode({
              'url':
                  '${SupabaseImages.projectUrl}/storage/v1/object/sign/profile-images/member/photo.jpg?token=temporary'
            }),
            200);
      }),
      tokenProvider: (_) async => signedIn ? 'token' : null,
    );
    await images.signedUrl(profile);
    signedIn = false;
    await expectLater(images.signedUrl(profile), throwsStateError);
    expect(calls, 1);
  });
  test('a rejected guest read does not retry or refresh an absent session',
      () async {
    var calls = 0;
    final images = SupabaseImages(
      client: MockClient((request) async {
        calls++;
        return http.Response(jsonEncode({'error': 'not deployed'}), 401);
      }),
      tokenProvider: (_) async => null,
    );
    await expectLater(images.signedUrl(reference), throwsStateError);
    expect(calls, 1);
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/services/account_registration.dart';
import 'package:good_together/services/member_registry.dart';

class _User extends Fake implements User {
  bool deleted = false;
  @override
  String? displayName;
  @override
  String get uid => 'new-member';
  @override
  Future<void> updateDisplayName(String? name) async {
    displayName = name;
  }

  @override
  Future<void> delete() async {
    deleted = true;
  }
}

class _Credential extends Fake implements UserCredential {
  final _User member;
  _Credential(this.member);
  @override
  User get user => member;
}

class _Auth extends Fake implements FirebaseAuth {
  final member = _User();
  @override
  Future<UserCredential> createUserWithEmailAndPassword(
          {required String email, required String password}) async =>
      _Credential(member);
}

// Test-only handles; all document operations are supplied by the fake transaction.
// ignore: subtype_of_sealed_class
class _Reference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final String path;
  _Reference(this.path);
}

// ignore: subtype_of_sealed_class
class _Snapshot<T extends Object?> extends Fake implements DocumentSnapshot<T> {
  @override
  final bool exists;
  _Snapshot(this.exists);
}

class _Transaction extends Fake implements Transaction {
  final _Store store;
  _Transaction(this.store);
  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
          DocumentReference<T> ref) async =>
      _Snapshot<T>(store.profile != null);
  @override
  Transaction set<T>(DocumentReference<T> ref, T data, [SetOptions? options]) {
    store.profile = Map<String, dynamic>.from(data as Map);
    return this;
  }
}

class _Store extends Fake implements FirebaseFirestore {
  final bool denyProfiles;
  Map<String, dynamic>? profile;
  final paths = <String>[];
  _Store({this.denyProfiles = false});
  @override
  DocumentReference<Map<String, dynamic>> doc(String path) {
    paths.add(path);
    if (denyProfiles || !path.startsWith('users/')) {
      throw FirebaseException(
          plugin: 'cloud_firestore', code: 'permission-denied');
    }
    return _Reference(path);
  }

  @override
  Future<T> runTransaction<T>(TransactionHandler<T> handler,
          {Duration timeout = const Duration(seconds: 30),
          int maxAttempts = 5}) =>
      handler(_Transaction(this));
}

void main() {
  test('new account succeeds even when member-counter access is denied',
      () async {
    final auth = _Auth();
    final store = _Store();
    await AccountRegistration.create(
        'member@example.com', 'password123', 'new_member',
        authentication: auth, database: store);
    expect(store.profile?['username'], 'new_member');
    expect(auth.member.deleted, isFalse);
    expect(AccountRegistration.inProgress.value, isFalse);
    expect(store.paths, ['users/new-member']);
    await expectLater(
        MemberRegistry.registerMember(store, auth.member.uid),
        throwsA(isA<FirebaseException>()
            .having((e) => e.code, 'code', 'permission-denied')));
    expect(auth.member.deleted, isFalse);
  });
  test('profile setup failure still rolls back the unfinished account',
      () async {
    final auth = _Auth();
    await expectLater(
        AccountRegistration.create(
            'member@example.com', 'password123', 'new_member',
            authentication: auth, database: _Store(denyProfiles: true)),
        throwsA(isA<FirebaseException>()
            .having((e) => e.code, 'code', 'permission-denied')));
    expect(auth.member.deleted, isTrue);
    expect(AccountRegistration.inProgress.value, isFalse);
  });
}

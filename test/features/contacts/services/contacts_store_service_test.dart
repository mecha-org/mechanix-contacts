import 'dart:io';

import 'package:mechanix_contacts/features/contacts/data/models/contacts.dart';
import 'package:mechanix_contacts/features/contacts/data/models/email.dart';
import 'package:mechanix_contacts/features/contacts/data/models/phone_numbers.dart';
import 'package:mechanix_contacts/features/contacts/data/models/sim_card.dart';
import 'package:mechanix_contacts/features/contacts/services/contacts_store_service.dart';
import 'package:mechanix_contacts/objectbox.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Store store;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('objectbox_store_service_test_');
    store = openStore(directory: tempDir.path);
  });

  tearDown(() async {
    ContactsStoreService.storeForTesting = null;
    store.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ContactsStoreService', () {
    test('storeForTesting assigns the store and exposes boxes', () {
      ContactsStoreService.storeForTesting = store;

      expect(ContactsStoreService.store, store);
      expect(ContactsStoreService.contacts, isA<Box<ContactEntity>>());
      expect(ContactsStoreService.phoneNumbers, isA<Box<PhoneNumberEntity>>());
      expect(ContactsStoreService.emails, isA<Box<EmailEntity>>());
      expect(ContactsStoreService.sims, isA<Box<SimCardEntity>>());
    });

    test('close clears the store', () {
      ContactsStoreService.storeForTesting = store;
      expect(ContactsStoreService.store, store);

      ContactsStoreService.close();
      expect(() => ContactsStoreService.store, throwsA(isA<TypeError>()));
    });
  });
}

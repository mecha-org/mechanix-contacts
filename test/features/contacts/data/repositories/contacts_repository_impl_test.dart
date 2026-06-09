import 'dart:io';

import 'package:mechanix_contacts/features/contacts/data/models/contacts.dart';
import 'package:mechanix_contacts/features/contacts/data/models/phone_numbers.dart';
import 'package:mechanix_contacts/features/contacts/data/models/email.dart';
import 'package:mechanix_contacts/features/contacts/data/models/sim_card.dart';
import 'package:mechanix_contacts/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:mechanix_contacts/objectbox.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Store store;
  late ContactsRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('objectbox_contacts_test_');
    store = openStore(directory: tempDir.path);
    repository = ContactsRepositoryImpl(store: store);
  });

  tearDown(() async {
    store.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ContactsRepositoryImpl', () {
    test('getAll returns contacts ordered by name', () async {
      final box = store.box<ContactEntity>();

      final c1 = ContactEntity(name: 'Charlie');
      final c2 = ContactEntity(name: 'Alice');
      final c3 = ContactEntity(name: 'Bob');

      box.putMany([c1, c2, c3]);

      final results = await repository.getAll();

      expect(results.length, 3);
      expect(results[0].name, 'Alice');
      expect(results[1].name, 'Bob');
      expect(results[2].name, 'Charlie');
    });

    test('getById returns correct contact or null', () async {
      final box = store.box<ContactEntity>();
      final contact = ContactEntity(name: 'David');
      final id = box.put(contact);

      final found = await repository.getById(id);
      expect(found, isNotNull);
      expect(found!.name, 'David');

      final notFound = await repository.getById(999);
      expect(notFound, isNull);
    });

    test('save saves contact and its numbers, emails', () async {
      final contact = ContactEntity(name: 'Eva');
      await repository.save(
        contact,
        ['123456', '987654'],
        ['eva@testemail.com'],
      );

      final saved = await repository.getById(contact.id);
      expect(saved, isNotNull);
      expect(saved!.name, 'Eva');
      expect(saved.phoneNumbers.length, 2);
      expect(
        saved.phoneNumbers.map((p) => p.number),
        containsAll(['123456', '987654']),
      );
      expect(saved.emails.length, 1);
      expect(
        saved.emails.map((e) => e.email),
        contains('eva@testemail.com'),
      );
    });

    test('save removes old numbers and emails when updating', () async {
      final contact = ContactEntity(name: 'Frank');
      await repository.save(contact, ['111111'], ['frank@old.com']);

      // update numbers and emails
      await repository.save(contact, ['222222', '333333'], ['frank@new.com']);

      final saved = await repository.getById(contact.id);
      expect(saved!.phoneNumbers.length, 2);
      expect(
        saved.phoneNumbers.map((p) => p.number),
        containsAll(['222222', '333333']),
      );
      expect(
        saved.phoneNumbers.map((p) => p.number),
        isNot(contains('111111')),
      );

      expect(saved.emails.length, 1);
      expect(
        saved.emails.map((e) => e.email),
        contains('frank@new.com'),
      );
      expect(
        saved.emails.map((e) => e.email),
        isNot(contains('frank@old.com')),
      );
    });

    test('delete removes contact, phone numbers, and emails', () async {
      final contact = ContactEntity(name: 'Grace');
      await repository.save(contact, ['999999'], ['grace@email.com']);

      final contactId = contact.id;
      final phoneBox = store.box<PhoneNumberEntity>();
      final emailBox = store.box<EmailEntity>();

      expect(phoneBox.query().build().find().length, 1);
      expect(emailBox.query().build().find().length, 1);

      await repository.delete(contactId);

      final deletedContact = await repository.getById(contactId);
      expect(deletedContact, isNull);
      expect(phoneBox.query().build().find().length, 0);
      expect(emailBox.query().build().find().length, 0);
    });

    test('search finds contact by name case insensitively', () async {
      final c1 = ContactEntity(name: 'John Doe');
      final c2 = ContactEntity(name: 'Jane Smith');

      await repository.save(c1, ['123'], []);
      await repository.save(c2, ['456'], []);

      final results = await repository.search('john');
      expect(results.length, 1);
      expect(results[0].name, 'John Doe');
    });

    test('search finds contact by phone number', () async {
      final c1 = ContactEntity(name: 'John Doe');
      final c2 = ContactEntity(name: 'Jane Smith');

      await repository.save(c1, ['123456789'], []);
      await repository.save(c2, ['987654321'], []);

      final results = await repository.search('456');
      expect(results.length, 1);
      expect(results[0].name, 'John Doe');
    });

    test('search returns all when query is empty', () async {
      final c1 = ContactEntity(name: 'Alice');
      final c2 = ContactEntity(name: 'Bob');

      await repository.save(c1, ['123'], []);
      await repository.save(c2, ['456'], []);

      final results = await repository.search('   ');
      expect(results.length, 2);
    });

    test('getSimCards seeds data on first access, returns saved sims on next', () async {
      final simsBox = store.box<SimCardEntity>();
      expect(simsBox.count(), 0);

      // Should seed
      final sims = await repository.getSimCards();
      expect(sims.length, 2);
      expect(sims[0].name, 'Primary');
      expect(sims[1].name, 'Secondary');

      // Clear repository sims to put custom, check it returns that without seeding
      simsBox.removeAll();
      final customSim = SimCardEntity(slot: '3', name: 'Custom SIM', number: '12345');
      simsBox.put(customSim);

      final fetchedSims = await repository.getSimCards();
      expect(fetchedSims.length, 1);
      expect(fetchedSims[0].name, 'Custom SIM');
    });
  });
}

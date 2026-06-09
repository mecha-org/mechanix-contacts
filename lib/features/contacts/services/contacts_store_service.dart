import 'dart:io';

import 'package:mechanix_contacts/core/constants/app_constants.dart';
import 'package:mechanix_contacts/core/exceptions/app_exception.dart';
import 'package:mechanix_contacts/core/utils/app_logger.dart';
import 'package:mechanix_contacts/features/contacts/data/models/contacts.dart';
import 'package:mechanix_contacts/features/contacts/data/models/email.dart';
import 'package:mechanix_contacts/features/contacts/data/models/phone_numbers.dart';
import 'package:mechanix_contacts/features/contacts/data/models/sim_card.dart';
import 'package:mechanix_contacts/objectbox.g.dart';

class ContactsStoreService {
  static Store? _store;
  static Future<void>? _initFuture;

  static Future<void> ensureConnected() async {
    if (_store != null && !_store!.isClosed()) {
      return;
    }

    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    try {
      _initFuture = _initialize();
      await _initFuture;
    } catch (e) {
      AppLogger.e('Failed to open contacts store: $e');
      rethrow;
    } finally {
      _initFuture = null;
    }
  }

  static Future<void> _initialize() async {
    try {
      if (!await AppConstants.contactsStoreDir.exists()) {
        await AppConstants.contactsStoreDir.create(recursive: true);
      }

      _store = openStore(directory: AppConstants.contactsStoreDir.path);

      AppLogger.i(
        '[ContactsStoreService] Opened store at '
        '${AppConstants.contactsStoreDir.path}',
      );
    } on FileSystemException catch (e) {
      if (e.message.contains('lock failed')) {
        throw const AppAlreadyRunningException();
      }

      throw const ContactsStoreInitializationException(
        'Failed to access contacts store directory.',
      );
    } catch (e) {
      throw ContactsStoreInitializationException(
        'Failed to initialize contacts store: $e',
      );
    }
  }

  static Store get store => _store!;

  static Box<ContactEntity> get contacts => store.box<ContactEntity>();

  static Box<PhoneNumberEntity> get phoneNumbers =>
      store.box<PhoneNumberEntity>();

  static Box<EmailEntity> get emails => store.box<EmailEntity>();

  static Box<SimCardEntity> get sims => store.box<SimCardEntity>();

  static set storeForTesting(Store? value) {
    _store = value;
  }

  static void close() {
    _store?.close();
    _store = null;
  }
}

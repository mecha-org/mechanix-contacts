import 'dart:io';

class AppConstants {
  static const int maxContactNameLength = 100;

  static final home = Platform.environment['HOME'];
  static final contactsStoreDir = Directory(
    '$home/.config/mechanix_contacts/objectbox',
  );
}
